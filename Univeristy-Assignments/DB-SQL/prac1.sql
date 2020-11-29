-- Q1

-- needs distinct in case there are multiple sections of the course
SELECT DISTINCT S.sname
FROM student S, enroll E, course C
WHERE S.sid = E.sid AND (E.cno, E.dname) = (C.cno, C.dname)
  AND C.cname = 'Thermodynamics';

/*
        sname
---------------------
 Andermanthenol, K.
 Bates, M.
 Borchart, Sandra L.
 Jacobs, T.
 June, Granson
 Starry, J.
 Villa-lobos, M.
(7 rows)
*/

-- doesn't need distinct
SELECT S.sname
FROM student S
WHERE S.sid IN (
    SELECT E.sid
    FROM enroll E, course C
    WHERE (E.cno, E.dname) = (C.cno, C.dname)
      AND C.cname = 'Thermodynamics'
  );

/*
        sname
---------------------
 June, Granson
 Bates, M.
 Starry, J.
 Borchart, Sandra L.
 Andermanthenol, K.
 Villa-lobos, M.
 Jacobs, T.
(7 rows)
*/

-- Q2

-- shouldn't need distinct unless multiple sections
-- of the same course can be taught by the same professor
SELECT C.cname, S.pname
FROM enroll E, course C, section S
WHERE E.sid = 16 AND (C.cno, C.dname) = (E.cno, E.dname)
  AND (S.cno, S.dname, S.sectno) = (E.cno, E.dname, E.sectno);

/*
          cname           |   pname
--------------------------+-----------
 Intro to Programming     | Jones, J.
 Intro to Programming     | Smith, S.
 Intro to Data Structures | Jones, J.
 Compiler Construction    | Clark, E.
(4 rows)
*/

-- Q3

SELECT D.dname
FROM dept D
WHERE (
    SELECT COUNT(S.sid)
    FROM student S, major M
    WHERE s.age < 19 AND M.sid = S.sid AND M.dname = D.dname
  ) >= 1;

/*
         dname
------------------------
 Chemical Engineering
 Civil Engineering
 Computer Sciences
 Industrial Engineering
 Mathematics
(5 rows)
*/

-- Q4

SELECT S.cno, S.sectno
FROM section S
WHERE (
    SELECT COUNT(E.sid)
    FROM enroll E
    WHERE (E.dname, E.cno, E.sectno) = (S.dname, S.cno, S.sectno)
  ) < 12;

/*
 cno | sectno
-----+--------
 310 |      1
 365 |      1
 375 |      1
 302 |      1
 302 |      2
 467 |      1
 514 |      1
 461 |      1
 462 |      1
 561 |      1
(10 rows)
*/

-- Q5

INSERT INTO prof VALUES ('Benedikt, M.', 'Computer Sciences');

/*
INSERT 0 1

These is the prof table after:

    pname     |         dname
--------------+------------------------
 Brian, C.    | Computer Sciences
 Brown, S.    | Civil Engineering
 Bucket, T.   | Sanitary Engineering
 Clark, E.    | Civil Engineering
 Edison, L.   | Chemical Engineering
 Jones, J.    | Computer Sciences
 Randolph, B. | Civil Engineering
 Robinson, T. | Mathematics
 Smith, S.    | Industrial Engineering
 Walter, A.   | Industrial Engineering
 Benedikt, M. | Computer Sciences
(11 rows)
*/

-- Optional

SELECT S.sid
FROM student S
WHERE NOT EXISTS (
    SELECT E.dname, E.cno, E.sectno
    FROM enroll E
    WHERE E.sid = S.sid AND (
        SELECT COUNT(E2.sid)
        FROM enroll E2
        WHERE (E2.dname, E2.cno, E2.sectno) = (E.dname, E.cno, E.sectno)
      ) <= 10
  );

/*
 sid
-----
   2
   7
   8
  10
  20
  23
  25
  31
  32
  34
  39
  41
  42
  44
  46
  48
  51
  60
  61
  62
  63
  64
  65
  68
  70
  71
  72
  75
  77
  80
  81
  82
  83
  84
  87
  89
  92
  95
  99
 100
 103
(41 rows)
*/