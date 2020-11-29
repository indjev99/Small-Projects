<html> 
  <head>
    <title>Question 1 Result</title>
  </head>
  <body> 
    <h1>Question 1 Result</h1>
    <p>
    <?php
      $dbconn = pg_connect("host=tr01")
        or die("Could not connect: " . pg_last_error());

      // Prepare a query for execution with $1 and $2 as a placeholders
      $result = pg_prepare($dbconn, "my_query", "SELECT S.sname, E.grade
                                                 FROM student S, enroll E
                                                 WHERE (E.cno, E.dname) = ($1, $2)
                                                   AND S.sid = E.sid")
        or die("Query preparation failed: " . pg_last_error());

      // Execute the prepared query with the value from the form as the actual argument 
      $result = pg_execute($dbconn, "my_query", array($_POST["cno"], $_POST["dname"])) 
        or die("Query execution failed: " . pg_last_error());

      $nrows = pg_numrows($result);
      if ($nrows != 0)
      {
        print "Data for course " . $_POST["cno"] . " in " . $_POST["dname"] . ":";
        print "<table border=2><tr><th>Name<th>Grade\n";
        for ($j = 0; $j < $nrows; $j++)
        {
          $row = pg_fetch_array($result);
          print "<tr><td>" . $row["sname"];
          print "<td>" . $row["grade"];
          print "\n";
        }
        print "</table>\n";
      }
      else print "No entries for course " . $_POST["cno"] . " in " . $_POST["dname"];
      pg_close($dbconn);
    ?>
  </body>
</html>
