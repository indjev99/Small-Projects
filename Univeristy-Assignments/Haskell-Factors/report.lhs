Exercise 1
factor 0 will return (2,0), because 0 `divMod` 2 = (0,0)
factor 1 will get stuck in an infinite recursion. This is because 1 `divMod` x = (0,m) for all m (since m >= 2 by the definition of the function), therefore the function will get called with increasing values of m and won't terminate.


Exercise 2
*Main> factor 0
(2,0)
factor 1 did get stuck.


Exercise 3
Let p be the smallest factor of n
Suppose p > sqrt(n) and p < n
p < n
=> n / p > n / n
=> n / p > 1
Therefore n / p is a non-trivial factor of n.
p > sqrt(n)
=> n / p < n / sqrt(n)
=> n / p < sqrt(n)
=> n / p < p
But n / p is also a factor of n and is smaller than p, which is a contradiction.
The order does matter because, if the n<=m*m case came before the r==0 case, the function will return (n,1) even when sqrt(n) is the smallest factor (for example if we call it with 9 in the wrong order it would return (9,1) and not (3,3))
Using factor1 at worst it takes sqrt(n) calls to find the smallest factor, because wither it will be found or sqrt(n) will be reached and thus it return (n,1).

> factor1 :: Integer -> (Integer, Integer)
> factor1 n = factorFrom1 2 n

> factorFrom1 :: Integer -> Integer -> (Integer, Integer)
> factorFrom1 m n | r == 0    = (m,q)
>                 | n <= m*m  = (n,1)
>                 | otherwise = factorFrom1 (m+1) n
>    where (q,r) = n `divMod` m


Excercise 4
n = q * m + r
q < m
=> q * m < m * m
=> q * m <= m * m - m (because q and m are whole and thus have a difference of at least 1)
=> q * m + m <= m * m
r < m
=> q * m + r < q * m + m
=> n < q * m + m
=> n < m * m
This is equivalent to n <= m*m because in the n = m * m case r == 0 is true and we don't reach this check. (Therefore the order of the first two guarded equations wouldn't matter in this version of the program)
This is a bit more efficient because we don't compute m * m and instead use values, which already need to be computed (q).

> factor2 :: Integer -> (Integer, Integer)
> factor2 n = factorFrom2 2 n

> factorFrom2 :: Integer -> Integer -> (Integer, Integer)
> factorFrom2 m n | r == 0    = (m,q)
>                 | q < m     = (n,1)
>                 | otherwise = factorFrom2 (m+1) n
>    where (q,r) = n `divMod` m


Exercise 5
We would expect this version to do roughly twice as few operations since only half of all numbers are odd.

> factor3 :: Integer -> (Integer, Integer)
> factor3 n  | r == 0    = (2, q)
>            | otherwise = factorFrom3 3 n
>    where (q,r) = n `divMod` 2

> factorFrom3 :: Integer -> Integer -> (Integer, Integer)
> factorFrom3 m n | r == 0    = (m,q)
>                 | q < m     = (n,1)
>                 | otherwise = factorFrom3 (m+2) n
>    where (q,r) = n `divMod` m


Exercise 6
*Main> factor3 (2*521)
(2,521)
(0.00 secs, 64,240 bytes)
*Main> factor3 (3*521)
(3,521)
(0.01 secs, 64,568 bytes)
*Main> factor3 (521*521)
(521,521)
(0.01 secs, 184,136 bytes)
*Main> factor3 (523*541)
(523,541)
(0.01 secs, 184,536 bytes)
*Main> factor3 8616460799
(89681,96079)
(0.06 secs, 20,520,792 bytes)


Exercise 7

> factor4 :: Integer -> (Integer, Integer)
> factor4 n  | r2 == 0   = (2, q2)
>            | r3 == 0   = (3, q3)
>            | otherwise = factorFrom4 5 n 2
>    where (q2,r2) = n `divMod` 2
>          (q3,r3) = n `divMod` 3

> factorFrom4 :: Integer -> Integer -> Integer -> (Integer, Integer)
> factorFrom4 m n s | r == 0    = (m,q)
>                   | q < m     = (n,1)
>                   | otherwise = factorFrom4 (m+s) n (6-s)
>    where (q,r) = n `divMod` m

*Main> factor4 (2*521)
(2,521)
(0.00 secs, 64,512 bytes)
*Main> factor4 (3*521)
(3,521)
(0.00 secs, 64,608 bytes)
*Main> factor4 (521*521)
(521,521)
(0.01 secs, 156,768 bytes)
*Main> factor4 (521*523)
(521,523)
(0.01 secs, 156,744 bytes)
*Main> factor4 8616460799
(89681,96079)
(0.04 secs, 15,856,216 bytes)


Exercise 8
The problem is finding all primes with which to test n. This is because checking whether a number is prime or not requires us to first factorize it (or at least fins the smallest factor), so we would first need to rund factor on all numbers below n and then on n. Even if each individual one is much faster. There are roughly sqrt(n)/ln sqrt(n) primes up to sqrt(n), so we would need to check every one, we would have O(sqrt(n)/ln n) as the complexity of checking for each individual number, but there are sqrt(n) numbers to check for so a total complexity of O(n/ln n) which is worse than O(sqrt(n)) - the complexity of the current algorithm. Doing this other algorithm (which only checks for the primes) is a good idea only when we need to factorize multiple numbers and thus we can afford precomputing the primes.


Exercise 9

> 
> factors2 :: Integer -> [Integer]
> factors2 n | r2 == 0   = 2:factors2 q2
>            | r3 == 0   = 3:factors2 q3
>            | otherwise = factorsFrom2 5 n 2
>    where (q2,r2) = n `divMod` 2
>          (q3,r3) = n `divMod` 3

> factorsFrom2 :: Integer -> Integer -> Integer -> [Integer]
> factorsFrom2 m n s | n == 1    = []
>                    | otherwise = p:factorsFrom2 p q (if p `mod` 3 == 1 then 4 else 2) --factorFrom4 doesn't return the final s it used so we need to find it here
>    where (p,q) = factorFrom4 m n s

*Main> factors 24
[2,2,2,3]
(0.00 secs, 66,864 bytes)
*Main> factors 150
[2,3,5,5]
(0.00 secs, 67,416 bytes)


Exercise 10
*Main> factors (521*521*1300391*1300727*1301081)
[521,521,1300391,1300727,1301081]
(0.93 secs, 510,156,168 bytes)
*Main> factors 8616460799
[89681,96079]
(0.08 secs, 37,729,176 bytes)

*Main> factors2 (521*521*1300391*1300727*1301081)
[521,521,1300391,1300727,1301081]
(0.54 secs, 229,031,088 bytes)
*Main> factors2 8616460799
[89681,96079]
(0.04 secs, 15,854,552 bytes)

factors2 appears to be about twice as fast as factors. It also uses about half the memory of factors.


Exercise 11
r = p^2 - q^2 - n
If r < 0 then we need to increase p^2 - q^2, we can do that by either increasing p or decreasing q, but q is the minimum value of y, so we can only increase p. x is a whole number (since u and v (since n is odd and n=u*v) are odd and u+v is even and therefore (u+v)/2 is whole) so the minimum ammount we can increase it by is 1 and there is no point in increasing it more than the minimum because then we might miss a solution and we are looking for the minimum possible value.
Analogigally, if r > 0 we need to increase q by 1.
It will terminate because in the worst case we will find two consecutve squares (because any ood number is the difference of two consecutive squares).

> search :: Integer -> Integer -> Integer -> (Integer, Integer)
> search p q n | r == 0 = (p,q)
>              | r < 0  = search (p+1) q n
>              | r > 0  = search p (q+1) n
>    where r = p*p - q*q - n

> fermat :: Integer -> (Integer, Integer)
> fermat n | odd n  = (p - q,p + q)
>	   | even n = error "fermat called with an even number"
>  --where (p,q) = search 0 0 n           --before Exercise 12
>  --where (p,q) = search (isqrt n) 0 n   --after Exercise 12, before 14
>    where (p,q) = search2 sq 0 n (sq * sq - n) --after Exercise 14
>                      where sq = isqrt n

*Main> fermat 8616460799
(89681,96079)
(0.13 secs, 44,174,424 bytes)
*Main> fermat 1963272347809
(241679,8123471)
(11.03 secs, 4,140,184,912 bytes)


Exercise 12
x^2 - y^2 = n
x^2 >= n
x >= sqrt(n)
Therefore, we should start searching at the sqrt of n.

> {-
> isqrt :: Integer -> Integer
> isqrt = truncate . sqrt . fromInteger -}


Exercise 13
*Main> fermat 8616460799
(89681,96079)
(0.01 secs, 1,847,152 bytes)
*Main> fermat 1963272347809
(241679,8123471)
(9.13 secs, 3,501,250,688 bytes)


Exercise 14
To calculate how much we need to increment r by we need:
((p+1)*(p+1) - q*q - n) - (p*p - q*q - n) =
(p+1)*(p+1) - q*q - n - p*p + q*q + n =
p*p + 2p + 1 - p*p =
2*p + 1
Similarly in the decrement case we do 2*q+1.

> search2 :: Integer -> Integer -> Integer -> Integer -> (Integer, Integer)
> search2 p q n r | r == 0 = (p,q)
>                 | r < 0  = search2 (p+1) q n (r+2*p+1)
>                 | r > 0  = search2 p (q+1) n (r-2*q-1)

*Main> fermat 8616460799
(89681,96079)
(0.01 secs, 1,767,512 bytes)
*Main> fermat 1963272347809
(241679,8123471)
(7.80 secs, 3,339,915,952 bytes)

*Main> 2^105
40564819207303340847894502572032
*Main> (isqrt (2^105))^2
40564819207303346393761349247529
*Main> 2^205
51422017416287688817342786954917203280710495801049370729644032
*Main> (isqrt (2^205))^2
51422017416287695847564223928948851826067856820555259947515904

Only the first 15-16 digits in decimal are accurate, because of the precision of float.


Exercise 15

> {-
> isqrt :: Integer -> Integer
> isqrt n = isqrtFrom 0 n

> isqrtFrom :: Integer -> Integer -> Integer
> isqrtFrom m n | m*m > n   = m-1
>               | otherwise = isqrtFrom (m+1) n -}

*Main> isqrt 15
3
(0.00 secs, 65,448 bytes)
*Main> isqrt 16
4
(0.00 secs, 69,688 bytes)
*Main> isqrt 17
4
(0.00 secs, 69,688 bytes)
*Main> isqrt 123456789000
351364
(0.19 secs, 78,776,408 bytes)

Claim: l < (l+r) `div` 2 < r
Proof:
l < r
=> l+1 <= r
But l+1 /= r
=> l+1 < r
=> l+2 <= r
=> l <= r-2
=> l+r <= r-2+r
=> (l+r) `div` 2 <= (2*r-2) `div` 2
=> (l+r) `div` 2 <= r-1
=> (l+r) `div` 2 < r
For the other side:
l+2 <= r
=> r >= l+2
=> l+r >= l+l+2
=> (l+r) `div` 2 >= (2*l+2) `div` 2
=> (l+r) `div` 2 >= l+1
=> (l+r) `div` 2 > l


Exercise 16

> split :: (Integer, Integer) -> Integer -> Integer
> split (l,r) n | l+1 == r  = l
>               | m*m > n   = split (l,m) n
>               | otherwise = split (m,r) n
>    where m = (l+r) `div` 2


Exercise 17

> isqrt :: Integer -> Integer
> isqrt n | n == 0 = 0
>         | n == 1 = 1
>       {-| otherwise = split (0,n+1) n --(0,n+1) so that isqrt works for 0 and 1 too-}
>         | otherwise = split (0,upperBoundFrom 1 n) n

It takes about log_2 n steps, since the interval is split in two each time and it starts with length n.

*Main> isqrt 15
3
(0.01 secs, 70,880 bytes)
*Main> isqrt 16
4
(0.00 secs, 70,752 bytes)
*Main> isqrt 17
4
(0.00 secs, 70,752 bytes)
*Main> isqrt 123456789000
351364
(0.00 secs, 87,328 bytes)


Exercise 18

> upperBoundFrom :: Integer -> Integer -> Integer
> upperBoundFrom m n | m*m > n   = m
>                    | otherwise = upperBoundFrom (2*m) n

It takes about 2*log_2 (sqrt(n)) steps. Which equals 2*1/2*log_2 n = log_2 n, so it is not worth it.

*Main> isqrt 15
3
(0.00 secs, 70,304 bytes)
*Main> isqrt 16
4
(0.00 secs, 70,968 bytes)
*Main> isqrt 17
4
(0.00 secs, 70,888 bytes)
*Main> isqrt 123456789000
351364
(0.00 secs, 84,256 bytes)
