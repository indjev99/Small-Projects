import io.threadcso._

object Sorting {
  def comparator(in0: ?[Int], in1: ?[Int], out0: ![Int], out1: ![Int]): PROC = proc {
    repeat {
      var x = 0
      var y = 0
      run(proc { x = in0?() } || proc { y = in1?() } )
      if (y < x) {
        val temp = x
        x = y
        y = temp
      }
      run( proc { out0!x } || proc { out1!y } )
    }
    in0.closeIn
    in1.closeIn
    out0.closeOut
    out1.closeOut
  }
  def sort4(ins: List[?[Int]], outs: List[![Int]]): PROC = {
    require(ins.length == 4 && outs.length == 4)
    val mid1 = List.fill(4)(OneOne[Int])
    val mid2 = List.fill(2)(OneOne[Int])
    val c02 = comparator(ins(0), ins(2), mid1(0), mid1(2))
    val c13 = comparator(ins(1), ins(3), mid1(1), mid1(3))
    val c01 = comparator(mid1(0), mid1(1), outs(0), mid2(0))
    val c23 = comparator(mid1(2), mid1(3), mid2(1), outs(3))
    val c12 = comparator(mid2(0), mid2(1), outs(1), outs(2))
    c02 || c13 || c01 || c23 || c12
  }
  def insert(ins: List[?[Int]], in: ?[Int], outs: List[![Int]]): PROC = {
    val n = ins.length; require(n >= 1 && outs.length == n + 1)
    if (n == 1)
      comparator(in, ins(0), outs(0), outs(1))
    else {
      val chan = OneOne[Int]
      val cmp = comparator(in, ins(0), outs(0), chan)
      val rest = insert(ins.tail, chan, outs.tail)
      cmp || rest
    }
  }
  def insertLog(ins: List[?[Int]], in: ?[Int], outs: List[![Int]]): PROC = {
    val n = ins.length; require(n >= 1 && outs.length == n + 1)
    if (n <= 2)
      insert(ins, in, outs)
    else {
      val lChan, rChan = OneOne[Int]
      val mid = n / 2
      val cmp = comparator(in, ins(mid), lChan, rChan)
      val left = insert(ins.slice(0, mid), lChan, outs.slice(0, mid + 1))
      val right = insert(ins.slice(mid + 1, n), rChan, outs.slice(mid + 1, n + 1))
      cmp || left || right
    }
  }
  def insertionSort(ins: List[?[Int]], outs: List[![Int]]): PROC = {
    val n = ins.length; require(n >= 2 && outs.length == n)
    if (n == 2)
      comparator(ins(0), ins(1), outs(0), outs(1))
    else {
      val chans = List.fill(n - 1)(OneOne[Int])
      val rest = insertionSort(ins.tail, chans)
      val fin = insertLog(chans, ins(0), outs)
      rest || fin
    }
  }
}

// ========================================

import scala.util.Random

class SortTester(N: Int, sort: (List[?[Int]], List[![Int]]) => PROC) {
  val ins, outs = List.fill(N)(OneOne[Int])
  sort(ins, outs).fork

  def oneTest() = {
    val xs = Array.fill(N)(Random.nextInt(1000))
    val ys = new Array[Int](N)
    def sender(i: Int) = proc {
      ins(i)!xs(i)
    }
    def receiver(i: Int) = proc {
      ys(i) = outs(i)?()
    }
    def senders = || (
      for (i <- 0 until N)
        yield sender(i)
    )
    def receivers = || (
      for (i <- 0 until N)
        yield receiver(i)
    )
    run(senders || receivers)
    assert(xs.sorted.sameElements(ys))
  }
}

class InsertTester(N: Int, insert: (List[?[Int]], ?[Int], List[![Int]]) => PROC) {
  val in = OneOne[Int]
  val ins = List.fill(N - 1)(OneOne[Int])
  val outs = List.fill(N)(OneOne[Int])
  insert(ins, in, outs).fork

  def oneTest() = {
    val xs = Array.fill(N)(Random.nextInt(1000))
    val ys = new Array[Int](N)
    def sender(i: Int) = proc {
      if (i > 0) ins(i - 1)!xs(i)
      else in!xs(i)
    }
    def receiver(i: Int) = proc {
      ys(i) = outs(i)?()
    }
    def senders = || (
      for (i <- 0 until N)
        yield sender(i)
    )
    def receivers = || (
      for (i <- 0 until N)
        yield receiver(i)
    )
    java.util.Arrays.sort(xs, 1, N)
    run(senders || receivers)
    assert(xs.sorted.sameElements(ys))
  }
}

object SortingTest {
  val sort4Tester = new SortTester(4, Sorting.sort4)
  val insertTester = new InsertTester(100, Sorting.insert)
  val insertLogTester = new InsertTester(100, Sorting.insertLog)
  val insertionSortTester = new SortTester(25, Sorting.insertionSort)

  def main(args : Array[String]) = {
    for (i <- 0 until 500) {
      sort4Tester.oneTest; if((i + 1) % 10 == 0) print(".")
    }
    println
    for (i <- 0 until 50) {
      insertTester.oneTest; if((i + 1) % 10 == 0) print(".")
    }
    println
    for (i <- 0 until 50) {
      insertLogTester.oneTest; if((i + 1) % 10 == 0) print(".")
    }
    println
    for (i <- 0 until 100) {
      insertionSortTester.oneTest; if((i + 1) % 10 == 0) print(".")
    }
    println
    exit
  }
}
