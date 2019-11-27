> module Geography(Place, Direction(N,S,E,W), move, opposite, Wall, Size)
> where

We represent a place (square) in the maze by its x and y coordinates:

> type Place = (Int, Int)

A direction, corresponding to a compass point

> data Direction = N | S | E | W deriving (Eq, Show)

***************************************
*              Question 1             *
* Complete the following definitions. *
***************************************

> opposite :: Direction -> Direction
> opposite N = S
> opposite W = E
> opposite S = N
> opposite E = W

> move :: Direction -> Place -> Place
> move N (i,j) = (i,j+1)
> move W (i,j) = (i-1,j)
> move S (i,j) = (i,j-1)
> move E (i,j) = (i+1,j)

We will represent a piece of wall by a place and a direction.  
For example, ((3,4), N) means that there is a wall to the North
of (3,4), and to the South of (3,5).

> type Wall = (Place, Direction)

A size of (x,y) represents that the squares are numbered (i,j) 
for  0 <= i < x and 0 <= j < y.

> type Size = (Int, Int)

