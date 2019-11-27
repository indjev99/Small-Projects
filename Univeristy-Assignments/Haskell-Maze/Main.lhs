> import Geography
> import MyMazeBST
> import MazeGenerator
> import Data.List

======================================================================

Draw a maze.

***************************************
*              Question 2             *
* Complete the definition of drawMaze *
***************************************

> drawMaze :: Maze -> IO() --draws the maze
> drawMaze maze = putStr (mazeString maze)

> mazeString :: Maze -> String --returns a string of the maze
> mazeString maze = concat [horzWalls maze row ++ vertWalls maze row | row <- reverse [0..y-1]] ++ horzWalls maze (-1)
>     where (x,y) = sizeOf maze


> horzWalls :: Maze -> Int -> String --string of a horizontal wall
> horzWalls maze row = concat [horzWallPlus maze (col,row) : horzWallDashEndl maze (col,row) | col <- [0..x]]
>     where (x,y) = sizeOf maze

> horzWallPlus :: Maze -> (Int,Int) -> Char --plus or space in a position in a horizontal wall
> horzWallPlus maze (col,row) | hasWall maze (col,row) N || hasWall maze (col,row) W || hasWall maze (col-1,row+1) S || hasWall maze (col-1,row+1) E = '+'
>                             | otherwise                                                                                                            = ' '

> horzWallDashEndl :: Maze -> (Int,Int) -> String --dash or space or endl in a position in a horizontal wall
> horzWallDashEndl maze (col,row) | col == x                 = "\n" 
>                                 | hasWall maze (col,row) N = "--"
>                                 | otherwise                = "  "
>     where (x,y) = sizeOf maze

> vertWalls :: Maze -> Int -> String --string of a vertical wall
> vertWalls maze row = concat [vertWallLine maze (col,row) : vertWallEndl maze (col,row) | col <- [0..x]]
>     where (x,y) = sizeOf maze

> vertWallLine :: Maze -> (Int,Int) -> Char --line or space in a position in a vertical wall
> vertWallLine maze place | hasWall maze place W = '|'
>                         | otherwise            = ' '

> vertWallEndl :: Maze -> (Int,Int) -> String --space or endl in a position in a vertical wall
> vertWallEndl maze (col,row) | col == x  = "\n" 
>                             | otherwise = "  "
>     where (x,y) = sizeOf maze

======================================================================

Solve the maze, giving a result of type:

> type Path = [Direction]

***************************************
*            Questions 3--4           *
*     Complete the definition of      *
*              solveMaze              *
***************************************

> solveMaze :: Maze -> Place -> Place -> Path --solves a maze
> solveMaze maze start target = solveMazeIter maze target initialPartials
>     where initialPartials = [(start,[])]

> solveMazeIter :: Maze -> Place -> [(Place,Path)] -> Path --performs BFS
> solveMazeIter maze target partials = if pathFound then pathToTarget else solveMazeIter maze target newPartials
>     where (pathFound,pathToTarget) = extractPathToTarget target partials
>           newPartials              = concat (map (getNeighbours maze) partials) 

> extractPathToTarget :: Place -> [(Place,Path)] -> (Bool,Path) --returns (True, desired path) if the path to the target is found otherwise (False, [])
> extractPathToTarget target []                = (False,[])
> extractPathToTarget target ((place,path):xs) = if place == target then (True,path) else extractPathToTarget target xs

By the way this has the form of a fold <3

> {-extractPathToTarget target xs = foldr cons nill xs
>     where nill                          = (False,[])
>           cons (place,path) ansFromRest = if place == target then (True,path) else ansFromRest-}

> getNeighbours :: Maze -> (Place,Path) -> [(Place,Path)] --returns the partials that contniue from some place
> getNeighbours maze placePath = northNeighbour ++ westNeighbour ++ southNeighbour ++ eastNeighbour
>     where northNeighbour = getNeighbour maze N placePath
>           westNeighbour  = getNeighbour maze W placePath
>           southNeighbour = getNeighbour maze S placePath
>           eastNeighbour  = getNeighbour maze E placePath

> getNeighbour :: Maze -> Direction -> (Place,Path) -> [(Place,Path)] --returns the partial in some direciton
> getNeighbour maze direction (place,path) = if isAccessible maze place direction then [(move direction place,path ++ [direction])] else []

> isAccessible :: Maze -> Place -> Direction -> Bool --checks whether a neighbour is accessible
> isAccessible maze place direction = not (hasWall maze place direction)

> fastSolveMaze :: Maze -> Place -> Place -> Path --solves a maze
> fastSolveMaze maze start target = fastSolveMazeIter maze target initialPartials initialVisited
>     where initialPartials = [(start,[])]
>           initialVisited  = updateVisited zeroVisited initialPartials
>           zeroVisited     = replicate m (replicate n False)
>           (m,n)           = sizeOf maze

> fastSolveMazeIter :: Maze -> Place -> [(Place,Path)] -> [[Bool]] -> Path --performs BFS
> fastSolveMazeIter _    _      []       _       = error "There is no path."
> fastSolveMazeIter maze target partials visited = if pathFound then pathToTarget else fastSolveMazeIter maze target newPartials newVisited
>     where (pathFound,pathToTarget) = extractPathToTarget target partials
>           newPartialsN             = concat (map (fastGetNeighbour maze visited N) partials)
>           newVisitedN              = updateVisited visited newPartialsN
>           newPartialsW             = concat (map (fastGetNeighbour maze newVisitedN W) partials)
>           newVisitedNW             = updateVisited newVisitedN newPartialsW
>           newPartialsS             = concat (map (fastGetNeighbour maze newVisitedNW S) partials)
>           newVisitedNWS            = updateVisited newVisitedNW newPartialsS
>           newPartialsE             = concat (map (fastGetNeighbour maze newVisitedNWS E) partials)
>           newVisited               = updateVisited newVisitedNWS newPartialsE
>           newPartials              = newPartialsN ++ newPartialsW ++ newPartialsS ++ newPartialsE

They are split up like that, so we don't get duplicated paths of equal length to some place at the same step, this is a huge problem on relatively empty mazes otherwise.

> fastGetNeighbour :: Maze -> [[Bool]] -> Direction -> (Place,Path) -> [(Place,Path)] --returns the partial in some direction
> fastGetNeighbour maze visited direction (place,path) = if isAccessible maze place direction && isNotVisited visited neighbour then [(neighbour,path ++ [direction])] else []
>     where neighbour = move direction place

> isNotVisited :: [[Bool]] -> Place -> Bool --checks whether a place is not visited
> isNotVisited visited (i,j) = not (visited !! i !! j)

> updateVisited :: [[Bool]] -> [(Place,Path)] -> [[Bool]] --updates the visited list
> updateVisited visited partials = updateVisitedIter visited (Data.List.sort (map f partials)) 0
>     where f (x,y) = x

> updateVisitedIter :: [[Bool]] -> [Place] -> Int -> [[Bool]] --goes trough all columns of visited to update them
> updateVisitedIter []       _  _    = []
> updateVisitedIter xss      [] _    = xss
> updateVisitedIter (xs:xss) ps col  = updateVisitedColumnIter xs ps1 0 : updateVisitedIter xss ps2 (col+1)
>     where ps1     = takeWhile f ps
>           ps2     = dropWhile f ps
>           f (i,j) = i == col

> updateVisitedColumnIter :: [Bool] -> [Place] -> Int -> [Bool] --goes trough all elements of a list to update them
> updateVisitedColumnIter []     _      _    = []
> updateVisitedColumnIter xs     []     _    = xs
> updateVisitedColumnIter (x:xs) (p:ps) row  = (x || f p) : updateVisitedColumnIter xs ps2 (row+1)
>     where ps2     = dropWhile f (p:ps)
>           f (i,j) = j == row

> emptyMaze :: Maze
> emptyMaze = makeMaze (22,22) []

======================================================================

Some test mazes.  In both cases, the task is to find a path from the bottom
left corner to the top right.

First a small one

> smallMaze :: Maze
> smallMaze = 
>   let walls = [((0,0), N), ((2,2), E), ((2,1),E), ((1,0),E), 
>                ((1,2), E), ((1,1), N)]
>   in makeMaze (4,3) walls

Now a large one.  Define a function to produce a run of walls:

> run (x,y) n E = [((x,y+i),E) | i <- [0..n-1]]
> run (x,y) n N = [((x+i,y),N) | i <- [0..n-1]]

And here is the maze.

> largeMaze :: Maze 
> largeMaze =
>   let walls = 
>         run (0,0) 3 E ++ run (1,1) 3 E ++ [((1,3),N)] ++ run (0,4) 5 E ++
>         run (2,0) 5 E ++ [((2,4),N)] ++ run (1,5) 3 E ++
>         run (1,8) 3 N ++ run (2,6) 3 E ++
>         run (3,1) 7 E ++ run (4,0) 4 N ++ run (4,1) 5 E ++ run (5,2) 3 N ++
>         run (4,6) 2 N ++ run (5,4) 3 E ++ run (6,3) 5 N ++ run (8,0) 4 E ++
>         run (6,1) 3 N ++ run (0,9) 3 N ++ run (1,10) 3 N ++ run (0,11) 3 N ++
>         run (1,12) 6 N ++ run (3,9) 4 E ++ run (4,11) 2 N ++
>         run (5,9) 3 E ++ run (4,8) 3 E ++ run (5,7) 5 N ++ run (6,4) 9 E ++
>         run (7,5) 3 N ++ run (8,4) 4 N ++ run (8,6) 3 N ++ run (10,5) 7 E ++
>         run (9,8) 3 E ++ run (8,9) 3 E ++ run (7,8) 3 E ++ run (8,11) 3 N ++
>         run (0,13) 5 N ++ run (4,14) 2 E ++ run (0,15) 2 E ++ 
>         run (1,14) 3 N ++ run (3,15) 2 E ++ run (0,17) 2 N ++ 
>         run (1,16) 2 E ++ run (2,15) 1 N ++ run (3,16) 3 N ++
>         run (2,17) 2 E ++ run (1,18) 6 N ++ run (4,17) 3 N ++ 
>         run (6,14) 7 E ++ run (5,13) 4 E ++ run (7,12) 2 E ++
>         run (8,13) 3 N ++ run (7,14) 3 N ++ run (10,14) 2 E ++
>         run (8,15) 5 N ++ run (7,16) 5 N ++ run (9,1) 2 E ++
>         run (10,0) 12 N ++ run (21,1) 1 E ++ run (10,2) 2 E ++
>         run (11,1) 7 N ++ run (17,1) 1 E ++ run (11,3) 3 E ++
>         run (12,2) 7 N ++ run (18,2) 2 E ++ run (19,1) 2 N ++
>         run (15,3) 3 N ++ run (14,4) 3 E ++ run (13,3) 3 E ++
>         run (12,4) 3 E ++ run (12,6) 3 N ++ run (11,7) 8 E ++ 
>         run (9,12) 3 N ++ run (12,14) 1 N ++ run (12,8) 10 E ++
>         run (0,19) 6 N ++ run (1,20) 6 N ++ run (7,18) 8 E ++
>         run (8,17) 1 N ++ run (8,18) 3 E ++ run (9,17) 4 E ++ 
>         run (10,18) 2 E ++ run (11,17) 2 E ++ run (10,20) 3 N ++
>         run (11,19) 3 N ++ run (12,18) 2 N ++ run (13,17) 2 N ++
>         run (13,13) 4 E ++ run (14,12) 7 N ++ run (13,11) 2 N ++
>         run (14,10) 2 E ++ run (13,9)2 E ++ run (14,8) 3 N ++ 
>         run (13,7) 3 N ++ run (15,5) 3 E ++ run (16,6) 3 E ++
>         run (18,5) 4 N ++ run (16,4) 2 N ++ run (13,20) 2 E ++
>         run (14,18) 4 E ++ run (20,2) 3 N ++ run (19,3) 2 E ++
>         run (18,4) 2 E ++ run (23,4) 1 E ++ run (22,4) 1 N ++
>         run (21,3) 1 N ++ run (20,4) 2 E ++ run (17,6) 4 N ++ 
>         run (20,7) 2 E ++ run (21,7) 2 N ++ run (21,6) 1 E ++ 
>         run (15,9) 1 E ++ run (17,8) 2 E ++ run (18,7) 2 E ++ 
>         run (19,8) 2 E ++ run (21,9) 1 E ++ run (16,9) 6 N ++
>         run (16,10) 7 N ++ run (15,11) 2 E ++ run (17,11) 5 N ++ 
>         run (14,14) 3 E ++ run (15,15) 6 E ++ run (17,14) 4 E ++
>         run (16,18) 4 E ++ run (15,17) 1 N ++ run (17,17) 3 N ++
>         run (15,13) 7 N ++ run (21,12) 2 E ++ run (16,16) 1 N ++
>         run (16,14) 1 N ++ run (17,15) 3 N ++ run (19,14) 4 N ++
>         run (20,15) 5 E ++ run (19,16) 2 N ++ run (21,16) 5 E ++
>         run (17,19) 2 E ++ run (18,20) 2 E ++ run (19,19) 2 E ++
>         run (18,18) 2 N ++ run (20,20) 3 N
>   in makeMaze (23,22) walls

And now an impossible maze

> impossibleMaze :: Maze
> impossibleMaze =
>   let walls = [((0,1), E), ((1,0),N), ((1,2), E), ((2,1), N)]
>   in makeMaze (3,3) walls

