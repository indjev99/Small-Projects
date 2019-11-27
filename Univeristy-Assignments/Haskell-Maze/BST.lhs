Module with a BST.

> module BST (
>   BST, 
>   insertInBST, -- :: Ord a => a -> BST a -> BST a
>   isInBST,     -- :: Ord a => a -> BST a -> Bool
>   makeBST      -- :: Ord a => [a] -> BST a
> )
> where

> import RNG

> data BST a = Empty | Fork (BST a) a (BST a)

> insertInBST :: Ord a => a -> BST a -> BST a
> insertInBST x Empty                 = Fork Empty x Empty
> insertInBST x (Fork l y r) | x < y  = Fork (insertInBST x l) y r
>                            | x > y  = Fork l y (insertInBST x r)
>                            | x == y = Fork l y r

> isInBST :: Ord a => a -> BST a -> Bool
> isInBST x Empty                 = False
> isInBST x (Fork l y r) | x < y  = isInBST x l
>                        | x > y  = isInBST x r
>                        | x == y = True

> makeBST :: Ord a => [a] -> BST a
> makeBST xs = makeBSTIter shuffledList
>     where (shuffledList,_) = shuffleList xs (rngWithSeed 1337)

> makeBSTIter :: Ord a => [a] -> BST a
> makeBSTIter []     = Empty
> makeBSTIter (x:xs) = insertInBST x (makeBSTIter xs)

