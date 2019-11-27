Module to define the type of a maze

> module MyMazeBST (
>   Maze, 
>   makeMaze, -- :: Size -> [Wall] -> Maze
>   hasWall,  -- :: Maze -> Place -> Direction -> Bool
>   sizeOf    -- :: Maze -> Size
> )
> where

> import Geography
> import BST

We will represent a maze by its size and BSTs of places where there are walls.

> data Maze = Maze Size (BST Place) (BST Place) (BST Place) (BST Place)

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
> makeMaze (x,y) ws = Maze (x,y) (makeBST wallsN) (makeBST wallsW) (makeBST wallsS) (makeBST wallsE)
>     where (wallsN,wallsW,wallsS,wallsE) = makeCompleteWalls (ws ++ boundaries)
>           boundaries = -- the four boundaries
>            [((0,j),   W) | j <- [0..y-1]] ++ -- westerly boundary
>            [((x-1,j), E) | j <- [0..y-1]] ++ -- easterly boundary
>            [((i,0),   S) | i <- [0..x-1]] ++ -- southerly boundary
>            [((i,y-1), N) | i <- [0..x-1]]    -- northerly boundary

The following function tests whether the maze includes a wall in a particular
direction from a particular place:

> hasWall :: Maze -> Place -> Direction -> Bool
> hasWall (Maze _ wallsN wallsW wallsS wallsE) pos d | d == N = pos `isInBST` wallsN
>                                                    | d == W = pos `isInBST` wallsW
>                                                    | d == S = pos `isInBST` wallsS
>                                                    | d == E = pos `isInBST` wallsE

The following function returns the size of a maze:

> sizeOf :: Maze -> Size
> sizeOf (Maze size _ _ _ _) = size

Some performance tests:

A maze was generated like this:

*Main> m = generateMaze (50,50) 0
*Main> drawMaze m

Then it was solved with both:

With MyMaze:

*Main> fastSolveMaze m (0,0) (49,49)
[E,E,E,N,N,E,E,E,S,E,E,N,E,E,N,N,N,E,E,E,N,E,S,E,S,E,S,E,E,E,N,N,N,E,N,N,N,E,E,S,E,E,S,E,S,S,W,S,S,S,E,E,E,N,N,E,N,E,N,E,N,W,N,N,W,N,W,N,N,N,W,W,W,N,E,N,N,N,N,W,W,W,W,W,N,W,W,N,W,N,N,E,E,N,N,N,N,E,E,N,N,N,E,E,E,N,E,N,N,E,E,N,E,N,E,E,N,W,N,E,N,N,E,N,N,E,E,E,E,N,E,N,E,N,N,N,N,N,E,E,S,W,S,S,S,E,N,N,E,N,E,E,S,S,E,E,E,S,E,E,E,N,N,N,W,N,N,E,N,E]
(0.39 secs, 53,841,640 bytes)

With MyMazeBST:

*Main> fastSolveMaze m (0,0) (49,49)
[E,E,E,N,N,E,E,E,S,E,E,N,E,E,N,N,N,E,E,E,N,E,S,E,S,E,S,E,E,E,N,N,N,E,N,N,N,E,E,S,E,E,S,E,S,S,W,S,S,S,E,E,E,N,N,E,N,E,N,E,N,W,N,N,W,N,W,N,N,N,W,W,W,N,E,N,N,N,N,W,W,W,W,W,N,W,W,N,W,N,N,E,E,N,N,N,N,E,E,N,N,N,E,E,E,N,E,N,N,E,E,N,E,N,E,E,N,W,N,E,N,N,E,N,N,E,E,E,E,N,E,N,E,N,N,N,N,N,E,E,S,W,S,S,S,E,N,N,E,N,E,E,S,S,E,E,E,S,E,E,E,N,N,N,W,N,N,E,N,E]
(0.23 secs, 76,875,448 bytes)

MyMazeBST is clearly faster.

