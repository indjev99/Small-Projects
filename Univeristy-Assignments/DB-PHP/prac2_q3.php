<html> 
  <head>
    <title>Question 3 Result</title>
  </head>
  <body> 
    <h1>Question 3 Result</h1>
    <p>
    <?php
      $dbconn = pg_connect("host=tr01")
        or die("Could not connect: " . pg_last_error());

      // Prepare a query for execution with $1 as a placeholder
      $result = pg_prepare($dbconn, "my_query", "SELECT S.dname, S.cno, S.sectno
                                                 FROM section S
                                                 WHERE (
                                                     SELECT COUNT(E.sid)
                                                     FROM enroll E
                                                     WHERE (E.dname, E.cno, E.sectno) = (S.dname, S.cno, S.sectno)
                                                   ) < $1")
        or die("Query preparation failed: " . pg_last_error());

      // Execute the prepared query with the value from the form as the actual argument 
      $result = pg_execute($dbconn, "my_query", array($_POST["K"])) 
        or die("Query execution failed: " . pg_last_error());

      $nrows = pg_numrows($result);
      if ($nrows != 0)
      {
        print "Sections with under " . $_POST["K"] . " students:";
        print "<table border=2><tr><th>Department<th>Course number<th>Section number\n";
        for ($j = 0; $j < $nrows; $j++)
        {
          $row = pg_fetch_array($result);
          print "<tr><td>" . $row["dname"];
          print "<td>" . $row["cno"];
          print "<td>" . $row["sectno"];
          print "\n";
        }
        print "</table></p>\n";
      }
      else print "No sections with under " . $_POST["K"] . " students";
      pg_close($dbconn);
    ?>
  </body>
</html>
