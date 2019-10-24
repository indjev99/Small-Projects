/** Import is for readLine so that we can write input directly to the program */
import scala.io.StdIn

object Brack {
  //Maximum length of word so we can define our arrays in dynamic programming
  val MAXWORD = 100

  //Operation to take 'A', 'B' and 'C' to corresponding Ints
  def LetterToInt(a: Char): Int = {
    if (a == 'A' || a == 'B' || a == 'C') {
      return (a.toInt - 'A'.toInt);
    } else {
      println("Please only Letters from A,B,C.")
      sys.exit
    }
  }

  //Defining the op array for everything to use
  val op = Array.ofDim[Int](3, 3)
  op(0)(0) = 1; op(0)(1) = 1; op(0)(2) = 0
  op(1)(0) = 2; op(1)(1) = 1; op(1)(2) = 0
  op(2)(0) = 0; op(2)(1) = 2; op(2)(2) = 2
  val combs = Array(
    Array((0, 2), (1, 2), (2, 0)),
    Array((0, 0), (0, 1), (1, 1)),
    Array((1, 0), (2, 1), (2, 2))
  )

  /** Read file into array (discarding the EOF character) */
  def readFile(fname: String): Array[Char] =
    scala.io.Source.fromFile(fname).toArray.init

  /* Functions below here need to be implemented */

  // TASK 1
  // PossibleRec checks whether bracketing to something is possible recursively
  // Checks whether w(i,j) can be bracketed to z

  def PossibleRec(w: Array[Int], i: Int, j: Int, z: Int): Boolean = {
    var found = false
    if (j == i + 1) {
      if (w(i) == z) found = true
    } else {
      var k = i + 1
      while (k < j && !found) {
        var t = 0
        while (t < 3 && !found) {
          found = PossibleRec(w, i, k, combs(z)(t)._1) && PossibleRec(
            w,
            k,
            j,
            combs(z)(t)._2
          )
          t += 1
        }
        k += 1
      }
    }
    found
  }

  // TASK 2
  // NumberRec which checks the ways you get a result recursively
  // Computes number of ways w(i,j) can be bracketed to get z

  def NumberRec(w: Array[Int], i: Int, j: Int, z: Int): Int = {
    var cnt = 0
    if (j == i + 1) {
      if (w(i) == z) cnt = 1
    } else {
      var k = i + 1
      while (k < j) {
        var t = 0
        while (t < 3) {
          cnt += NumberRec(w, i, k, combs(z)(t)._1) * NumberRec(
            w,
            k,
            j,
            combs(z)(t)._2
          )
          t += 1
        }
        k += 1
      }
    }
    cnt
  }

  // TASK 3
  /*
        NumberRec will always perform the same.
        The functions split the interval in two parts (three times) so:
        T(n) = sum_(i in [1,n)) 3*(T(i)+T(n-i))
        By symmetry:
        T(n) = 6 * sum_(i in [1,n)) T(i)
             = 6 * T(n-1) + 6 * sum_(i in [1,(n-1))) T(i)
             = 7 * T(n-1)
        T(n) = 7^(n-1) * const
        A reasonable value for the constant is about 4 operations.
        So for n = 11 we would expect 7^10*4 operations.
        At about a billion operations per second we get 1.1 seconds.

        We have to account that the overhead of the command is about 0.7 seconds.
        Test:

        Bracketing values for BBBBBBBBBBB
        A can be achieved in 0 ways
        B can be achieved in 16796 ways
        C can be achieved in 0 ways

        real	0m4.011s
        user	0m4.224s
        sys	0m0.053s

        Given that this calls the function three times, this is quite reasonable.

        Here is a test with n = 12

        Bracketing values for BBBBBBBBBBBB
        A can be achieved in 0 ways
        B can be achieved in 58786 ways
        C can be achieved in 0 ways

        real	0m24.613s
        user	0m24.724s
        sys	0m0.072s

        And another one showing that it always performs the same:

        Bracketing values for ABCABCABCABC
        A can be achieved in 26906 ways
        B can be achieved in 20051 ways
        C can be achieved in 11829 ways

        real	0m24.533s
        user	0m24.643s
        sys	0m0.071s

        Accounting for the overhead the result roughly 7-uples.

        For PossibleRec the same analysis would hold.
        However we have to consider that for a random long string, in general,
        each outcome is possible, so it will be mostly linear except for the final part.
        In that case the timing is basically all caused by the overhead.
        However, if an input is not possible, we will visit a much larger part
        of the recursion tree and it will be exponential.
        If we, say, visit half on each step, we get:
        T(n) = 3.5^n * 4
        So, for n = 15 we would expect about 0.6 seconds.

        Test:

        Bracketing values for BBBBBBBBBBBBBB
        A is not Possible
        B is Possible
        C is not Possible

        real	0m1.586s
        user	0m1.780s
        sys	0m0.068s

        Given that we do the slow version twice and accounting for the overhead,
        this answer seems quite likely.

        Here is a test with n = 16

        Bracketing values for BBBBBBBBBBBBBBB
        A is not Possible
        B is Possible
        C is not Possible

        real	0m4.663s
        user	0m4.837s
        sys	0m0.057s

        Accounting for the overhead the result about triples.
   */

  // You may find the following class useful for Task 7
  // Binary tree class
  abstract class BinaryTree
  case class Node(left: BinaryTree, right: BinaryTree) extends BinaryTree
  case class Leaf(value: Char) extends BinaryTree

  // Printing for a binary tree
  def print_tree(tree: BinaryTree) {
    tree match {
      case Leaf(ch) => print(ch)
      case Node(left, right) => {
        print('(')
        print_tree(left)
        print_tree(right)
        print(')')
      }
      case default => print("Default case reached, where it shouldn't be.")
    }
  }

  // These arrays should hold the relevant data for dynamic programming
  var poss = Array.ofDim[Boolean](MAXWORD, MAXWORD, 3)
  var ways = Array.ofDim[Int](MAXWORD, MAXWORD, 3)
  var exp = Array.ofDim[BinaryTree](MAXWORD, MAXWORD, 3)

  // Task 4, 5, and 7(optional)

  def TabulateHelper(w: Array[Int], i: Int, j: Int, z: Int): Unit = {
    ways(i)(j)(z) = 0
    if (j == i + 1) {
      if (w(i) == z) {
        ways(i)(j)(z) += 1
        exp(i)(j)(z) = Leaf(('A'.toInt + w(i)).toChar)
      }
    } else {
      var k = i + 1
      while (k < j) {
        var t = 0
        while (t < 3) {
          val lsym = combs(z)(t)._1
          val rsym = combs(z)(t)._2
          ways(i)(j)(z) += ways(i)(k)(lsym) * ways(k)(j)(rsym)
          if (poss(i)(k)(lsym) && poss(k)(j)(rsym))
            exp(i)(j)(z) = Node(exp(i)(k)(lsym), exp(k)(j)(rsym))
          t += 1
        }
        k += 1
      }
    }
    if (ways(i)(j)(z) > 0) poss(i)(j)(z) = true
    else poss(i)(j)(z) = false
  }

  def Tabulate(w: Array[Int], n: Int): Unit = {
    var len = 0
    while (len < n) {
      var i = 0
      while (i < n - len) {
        var z = 0
        while (z < 3) {
          TabulateHelper(w, i, i + len + 1, z)
          z += 1
        }
        i += 1
      }
      len += 1
    }
  }

  // Task 6
  /*
        We have to fill O(n^2) entries and each takes O(n), so O(n^3) in total.
        The constant is roughly 3*3/6 times the number of operation in each iteration.
        If this runs at about 10^9 ops per second we would expect it to run in 10 secs for n = 1000.
        n = 10000 should take about 3 hours. Memory-wise we can go to about n = 30000.
        However, there is much stronger limiting factor is that the number of ways overflows.
        This happens when n > 20.

        Tests (we print the raw values first):

        Bracketing values for BBBBBBBBBBBBBBBBBBBB
        0
        A cannot be achieved
        1767263190
        B can be achieved 1767263190 ways
        For example:(((((((((((((((((((BB)B)B)B)B)B)B)B)B)B)B)B)B)B)B)B)B)B)B)
        0
        C cannot be achieved

        Bracketing values for BBBBBBBBBBBBBBBBBBBBB
        0
        A cannot be achieved
        -2025814172
        0
        C cannot be achieved

   */

  /** The main method just selects which piece of functionality to run */
  def main(args: Array[String]) = {

    // string to print if error occurs
    val errString =
      "Usage: scala Brack -PossibleRec [file]\n" +
        "     | scala Brack -NumberRec [file]\n" +
        "     | scala Brack -Tabulate [file]\n"

    if (args.length > 2) {
      println(errString)
      sys.exit
    }

    //Get the plaintext, either from the file whose name appears in position
    //pos, or from standard input
    def getPlain(pos: Int) =
      if (args.length == pos + 1) readFile(args(pos))
      else StdIn.readLine.toArray

    // Check there are at least n arguments
    def checkNumArgs(n: Int) = if (args.length < n) {
      println(errString); sys.exit
    }

    // Parse the arguments, and call the appropriate function
    checkNumArgs(1)
    val plain = getPlain(1)
    val command = args(0)

    //Making sure the letters are of the right type
    val len = plain.length
    var plainInt = new Array[Int](len)
    if (len > MAXWORD) {
      println("Word Too Long! Change MAXWORD")
      sys.exit;
    } else {
      for (i <- 0 until len) {
        plainInt(i) = LetterToInt(plain(i))
      }
    }

    //Executing appropriate command
    if (command == "-PossibleRec") {
      println("Bracketing values for " + plain.mkString(""))
      for (i <- 0 to 2) {
        if (PossibleRec(plainInt, 0, len, i)) {
          println(('A'.toInt + i).toChar + " is Possible");
        } else {
          println(('A'.toInt + i).toChar + " is not Possible");
        }
      }
    } else if (command == "-NumberRec") {
      var z: Int = 0
      println("Bracketing values for " + plain.mkString(""))
      for (i <- 0 to 2) {
        z = NumberRec(plainInt, 0, len, i)
        if (z == 1) {
          printf(('A'.toInt + i).toChar + " can be achieved in %d way\n", z)
        } else {
          printf(('A'.toInt + i).toChar + " can be achieved in %d ways\n", z)
        }
      }
    } else if (command == "-Tabulate") {
      Tabulate(plainInt, len)
      println("Bracketing values for " + plain.mkString(""))
      for (v <- 0 to 2) {
        var z: Int = ways(0)(len)(v)
        println(z)
        if (z == 0) {
          println(('A'.toInt + v).toChar + " cannot be achieved")
        } else if (z == 1) {
          printf(('A'.toInt + v).toChar + " can be achieved %d way\n", z)
          printf("For example:")
          print_tree(exp(0)(len)(v))
          printf("\n")
        } else if (z > 1) {
          printf(('A'.toInt + v).toChar + " can be achieved %d ways\n", z)
          printf("For example:")
          print_tree(exp(0)(len)(v))
          printf("\n")
        }
      }
    } else println(errString)
  }
}
