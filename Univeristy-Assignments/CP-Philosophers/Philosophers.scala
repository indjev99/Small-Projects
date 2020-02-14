import io.threadcso._
import scala.language.postfixOps
import scala.util.Random

/** Simulation of the Dining Philosophers example. */
class Philosophers(N: Int, haveRightHanded: Boolean, haveButtler: Boolean) {
  // Simulate basic actions
  def Eat = Thread.sleep(100)
  def Think = Thread.sleep(Random.nextInt(150))
  def Pause = Thread.sleep(100)

  // Each philosopher will send "pick" and "drop" commands to her forks, which
  // we simulate using the following values.
  type Command = Boolean
  val Pick = true; val Drop = false
  val Sit = true; 

  val log = new io.threadcso.debug.Log[String](N)
 
  /** A single philosopher. */
  def phil(me: Int, left: ![Command], right: ![Command], sit: ?[Unit], leave: ![Unit]) = proc(s"Phil $me") {
    val (first, firstName, second, secondName) =
      if (me == 0 && haveRightHanded) (right, "right", left, "left")
      else (left, "left", right, "right") 
    repeat{
      Think
      if (haveButtler) sit?()
      log.add(me, s"$me sits"); Pause
      first!Pick; log.add(me, s"$me picks up " + firstName + " fork"); Pause
      second!Pick; log.add(me, s"$me picks up " + secondName + " fork"); Pause
      log.add(me, s"$me eats"); Eat
      first!Drop; Pause; second!Drop; Pause
      if (haveButtler) leave!()
      log.add(me, s"$me leaves")
      if (me == 0) print(".")
    }
  }

  /** A single fork. */
  def fork(me: Int, left: ?[Command], right: ?[Command]) = proc(s"Fork $me") {
    serve(
      left =?=> {
        x => assert(x == Pick); val y = left?; assert(y == Drop)
      }
      |
      right =?=> {
        x => assert(x == Pick); val y = right?; assert(y == Drop)
      }
    )
  }

  def buttler(sit: ![Unit], leave: ?[Unit]) = proc("Buttler") {
    var sitting = 0
    serve (
        (sitting < N - 1 && sit) =!=> {sitting += 1; ()}
      | (sitting > 0 && leave) =?=> {_ => sitting -= 1}
    )
  }

  /** The complete system. */
  val system = {
    // Channels to pick up and drop the forks:
    val philToLeftFork, philToRightFork = Array.fill(5)(OneOne[Command])
    val buttlerToPhils = OneMany[Unit]
    val philsToButtler = ManyOne[Unit]
    // philToLeftFork(i) is from Phil(i) to Fork(i);
    // philToRightFork(i) is from Phil(i) to Fork((i-1)%N)
    val allPhils = || ( 
      for (i <- 0 until N)
      yield phil(i, philToLeftFork(i), philToRightFork(i), buttlerToPhils, philsToButtler)
    )
    val allForks = || ( 
      for (i <- 0 until N) yield
        fork(i, philToRightFork((i+1)%N), philToLeftFork(i))
    )
    allPhils || allForks || buttler(buttlerToPhils, philsToButtler)
  }
}

object PhilosophersTest {
  /** Run the system. */
  def main(args : Array[String]) = {
    val philosophers = new Philosophers(5, false, false)
    philosophers.log.writeToFileOnShutdown("philsLog.txt")
    run(philosophers.system)
    exit
  }
}

  
