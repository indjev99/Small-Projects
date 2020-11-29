<html> 
  <head>
    <title>Question 2 Result</title>
  </head>
  <body> 
    <h1>Question 2 Result</h1>
    <p>
    <?php
      $dbconn = pg_connect("host=tr01")
        or die("Could not connect: " . pg_last_error());

      // Prepare a query for execution with $1 as a placeholder
      $result = pg_prepare($dbconn, "my_query", "SELECT D.dname
                                                 FROM dept D
                                                 WHERE (
                                                     SELECT COUNT(S.sid)
                                                     FROM student S, major M
                                                     WHERE s.age < $1 AND M.sid = S.sid AND M.dname = D.dname
                                                   ) >= 1")
        or die("Query preparation failed: " . pg_last_error());

      // Execute the prepared query with the value from the form as the actual argument 
      $result = pg_execute($dbconn, "my_query", array($_POST["K"])) 
        or die("Query execution failed: " . pg_last_error());

      $nrows = pg_numrows($result);
      if ($nrows != 0)
      {
        print "Departments with students under " . $_POST["K"] . " years old:";
        print "<table border=2><tr><th>Department\n";
        for ($j = 0; $j < $nrows; $j++)
        {
          $row = pg_fetch_array($result);
          print "<tr><td>" . $row["dname"];
          print "\n";
        }
        print "</table>\n";
      }
      else print "No departments with students under " . $_POST["K"] . " years old";
      pg_close($dbconn);
    ?>
  </body>
</html>
