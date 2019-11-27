Module for union find.

> module UnionFind (
>   Components,
>   initialComponents, -- :: Components -> Int -> Components
>   unite              -- :: Components -> Int -> Int -> (Bool,Components)
> )
> where

> import KVBST

> type Components = KVBST Int (Int,Int)

> initialComponents :: Int -> Components
> initialComponents s = makeKVBST [(x,(x,1)) | x <- [0..(s-1)]]

> findTop :: Components -> Int -> (Int,Int)
> findTop cs x = if p == x then (p,d) else findTop cs p
>     where (p,d) = getValueInKVBST x cs

> unite :: Components -> Int -> Int -> (Bool,Components)
> unite cs x y = if xTop == yTop then (False,cs) else (True,updatedCs)
>     where (xTop,xD) = findTop cs x
>           (yTop,yD) = findTop cs y
>           updatedCs | xD > yD   = setValueInKVBST yTop (xTop,yD) cs
>                     | yD > xD   = setValueInKVBST xTop (yTop,xD) cs
>                     | otherwise = setValueInKVBST yTop (xTop,yD) (setValueInKVBST xTop (xTop,xD + 1) cs)

