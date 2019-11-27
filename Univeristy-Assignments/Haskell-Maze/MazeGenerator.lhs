Module to generate mazes.

> module MazeGenerator (
>   generateMaze -- :: Size -> Int -> Maze
> )
> where

> import Geography
> import MyMazeBST
> import UnionFind
> import RNG


This function gives us the code of some place.

> toCode :: Size -> Place -> Int
> toCode (x,y) (i,j) = i*y+j

This function takes a size and a seed and generates a random solvable maze with that size.

> generateMaze :: Size -> Int -> Maze
> generateMaze (x,y) seed = makeMaze (x,y) (generateMazeIter (x,y) shuffledWalls components)
>     where rng                  = rngWithSeed seed
>           allWalls             = [((i,j),N) | i <- [0..(x-1)], j <- [0..(y-2)]] ++ [((i,j),W) | i <- [1..(x-1)], j <- [0..(y-1)]]
>           (shuffledWalls,rng2) = shuffleList allWalls rng
>           components           = initialComponents (x*y)

> generateMazeIter :: Size -> [Wall] -> Components -> [Wall]
> generateMazeIter s []             _  = []
> generateMazeIter s ((p,d):ws) cs = if united then nextWs else (p,d) : nextWs
>     where p1             = toCode s p
>           p2             = toCode s (move d p)
>           (united,newCs) = unite cs p1 p2
>           nextWs         = generateMazeIter s ws newCs

