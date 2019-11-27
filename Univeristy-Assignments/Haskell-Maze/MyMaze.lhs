Module to define the type of a maze

> module MyMaze (
>   Maze, 
>   makeMaze, -- :: Size -> [Wall] -> Maze
>   hasWall,  -- :: Maze -> Place -> Direction -> Bool
>   sizeOf    -- :: Maze -> Size
> )
> where

> import Geography

We will represent a maze by its size and lists of places where there are walls.

> data Maze = Maze Size [Place] [Place] [Place] [Place]

The list of walls will be complete in the sense that we record
both sides of the wall; for example, if the list includes 
((3,4), N), then it will also include ((3,5),S).

This function creates a 4-tuple of places corresponding to a complete list ofthe potentially incomplete list of walls it is given.

> makeCompleteWalls :: [Wall] -> ([Place],[Place],[Place],[Place])
> makeCompleteWalls []           = ([],[],[],[])
> makeCompleteWalls ((pos,d):ws) | d == N = (pos:newN, newW, move N pos:newS, newE)
>                                | d == W = (newN, pos:newW, newS, move W pos:newE)
>                                | d == S = (move S pos:newN, newW, pos:newS, newE)
>                                | d == E = (newN, move E pos:newW, newS, pos:newE)
>     where (newN,newW,newS,newE) = makeCompleteWalls ws

This function creates a maze given its size and a list of walls; 
the list of walls might not be complete in the above sense.

> makeMaze :: Size -> [Wall] -> Maze
> makeMaze (x,y) ws = Maze (x,y) wallsN wallsW wallsS wallsE
>     where (wallsN,wallsW,wallsS,wallsE) = makeCompleteWalls (ws ++ boundaries)
>           boundaries = -- the four boundaries
>            [((0,j),   W) | j <- [0..y-1]] ++ -- westerly boundary
>            [((x-1,j), E) | j <- [0..y-1]] ++ -- easterly boundary
>            [((i,0),   S) | i <- [0..x-1]] ++ -- southerly boundary
>            [((i,y-1), N) | i <- [0..x-1]]    -- northerly boundary

The following function tests whether the maze includes a wall in a particular
direction from a particular place:

> hasWall :: Maze -> Place -> Direction -> Bool
> hasWall (Maze _ wallsN wallsW wallsS wallsE) pos d | d == N = pos `elem` wallsN
>                                                    | d == W = pos `elem` wallsW
>                                                    | d == S = pos `elem` wallsS
>                                                    | d == E = pos `elem` wallsE

The following function returns the size of a maze:

> sizeOf :: Maze -> Size
> sizeOf (Maze size _ _ _ _) = size

Some performance tests:

With Maze:

*Main> length (fastSolveMaze largeMaze (0,0) (22,21))
271
(0.13 secs, 11,248,024 bytes)

*Main> length (fastSolveMaze largeMaze (22,0) (0,21))
101
(0.08 secs, 6,265,288 bytes)


With MyMaze:

*Main> length (fastSolveMaze largeMaze (0,0) (22,21))
271
(0.05 secs, 10,816,120 bytes)

*Main> length (fastSolveMaze largeMaze (22,0) (0,21))
101
(0.03 secs, 6,362,968 bytes)

We can see that MyMaze is about 2.5 times faster.

