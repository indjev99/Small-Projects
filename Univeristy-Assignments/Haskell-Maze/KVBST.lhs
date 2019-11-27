Module with a key value BST.

> module KVBST (
>   KVBST, 
>   setValueInKVBST, -- :: Ord a => (a, b) -> KVBST a b -> KVBST a b
>   getValueInKVBST, -- :: Ord a => a -> KVBST a b -> b
>   makeKVBST        -- :: Ord a => [(a,b)] -> KVBST a b
> )
> where

> import RNG

> data KVBST a b = Empty | Fork (KVBST a b) (a, b) (KVBST a b)

> setValueInKVBST :: Ord a => a -> b -> KVBST a b -> KVBST a b
> setValueInKVBST k v Empty                     = Fork Empty (k,v) Empty
> setValueInKVBST k v (Fork l (y,z) r) | k < y  = Fork (setValueInKVBST k v l) (y,z) r
>                                      | k > y  = Fork l (y,z) (setValueInKVBST k v r)
>                                      | k == y = Fork l (y,v) r

> getValueInKVBST :: Ord a => a -> KVBST a b -> b
> getValueInKVBST k Empty                     = error "No element with such key in the treeQ"
> getValueInKVBST k (Fork l (y,z) r) | k < y  = getValueInKVBST k l
>                                    | k > y  = getValueInKVBST k r
>                                    | k == y = z

> makeKVBST :: Ord a => [(a,b)] -> KVBST a b
> makeKVBST xs = makeKVBSTIter shuffledList
>     where (shuffledList,_) = shuffleList xs (rngWithSeed 1337)

> makeKVBSTIter :: Ord a => [(a,b)] -> KVBST a b
> makeKVBSTIter []         = Empty
> makeKVBSTIter ((k,v):xs) = setValueInKVBST k v (makeKVBSTIter xs)

