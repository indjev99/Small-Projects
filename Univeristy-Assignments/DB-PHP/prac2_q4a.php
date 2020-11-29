<html> 
  <head>
    <title>Optional Question Course Selection</title>
  </head>
  <body> 
    <h1>Optional Question Course Selection</h1>
    <p>
    <form action="prac2_q4b.php" method=post>
      Find the grade of a student for a course section.
      <br>
      <br>
      Select course section
      <select name="grade">
        <?php
          $dbconn = pg_connect("host=tr01")
            or die("Could not connect: " . pg_last_error());

          // Prepare a query for execution with $1 as a placeholder
          $result = pg_prepare($dbconn, "my_query", "SELECT E.grade, E.cno, E.dname, E.sectno
                                                     FROM enroll E
                                                     WHERE E.sid = $1")
            or die("Query preparation failed: " . pg_last_error());

          // Execute the prepared query with the value from the form as the actual argument 
          $result = pg_execute($dbconn, "my_query", array($_POST["sid"])) 
            or die("Query execution failed: " . pg_last_error());

          $nrows = pg_numrows($result);
          if ($nrows != 0)
          {
            for ($j = 0; $j < $nrows; $j++)
            {
              $row = pg_fetch_array($result);
              print "<option value=\"" . $row["grade"] . "\">" . $row["cno"]. " at " . $row["dname"] . " - section " . $row["sectno"] . "</option>";
              print "\n";
            }
          }
          pg_close($dbconn);
        ?>
      </select>
      <br>
      <br>
      <input type=submit value="Get grade">
    </form>
  </body>
</html>
