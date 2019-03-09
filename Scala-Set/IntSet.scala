// A class of objects to represent a set

class IntSet{
  // State: S : P(Int) (where "P" represents power set)

  // The following lines just define some aliases, so we can subsequently
  // write "Node" rather than "IntSet.Node".
  private type Node = IntSet.Node
  // Constructor
  private def Node(datum: Int, next: Node) = new IntSet.Node(datum, next)

  // Init: S = {}
  private var theSet: Node = Node(1337,null)
  private var theEnd: Node = theSet
  // Each of these sqrt nodes handles O(sqrt(N)) nodes after it
  private var sqrtNodes : Array[Node] = Array(theSet)
  // Count the number of performed operations since the last reconstruction of sqrtNodes
  private var operations = 0
  private var setSize = 0

  /** Convert the set to a string. */
  override def toString: String = {
    var str = "{";
    var curr = theSet.next
    var first = true
    while (curr != null) {
      if (!first) str += ", "
      first = false
      str += curr.datum;
      curr = curr.next
    }
    str += "}"
    str
  }

  /** Adds an element at the end, used only during construction */
  private def addAtEnd(e: Int) = {
    if (theEnd == theSet || theEnd.datum < e) {
      theEnd.next = Node(e,null)
      theEnd = theEnd.next
      setSize += 1
    }
  }

  /** Returns the highest node < e and the last sqrtNode */
  private def find(e: Int): (Node,Int) = {
    var i = 0
    while (i+1 < sqrtNodes.size && sqrtNodes(i+1) != null && sqrtNodes(i+1).datum < e) {
      i += 1
    }
    var curr = sqrtNodes(i)
    while (curr.next != null && curr.next.datum < e) {
      curr = curr.next
    }
    (curr,i)
  }

  /** Reconstructs the nodes that are sqrt(N) appart */
  private def constructSqrtNodes = {
    operations = 0
    val perNode: Int = Math.ceil(Math.sqrt(setSize+1.0)).toInt
    sqrtNodes = new Array[Node](Math.ceil((setSize+1.0) / perNode).toInt)
    var curr = theSet
    var i = 0
    var j = 0
    while (curr != null)
    {
      if (i%perNode == 0) {
        sqrtNodes(j) = curr
        j += 1
      }
      curr = curr.next
      i += 1
    }
  }

  /** Add element e to the set O(sqrt(N))
    * Post: S = S_0 U {e} */
  def add(e: Int) = {
    val prev = find(e)._1
    if (prev.next == null || prev.next.datum != e) {
      setSize += 1
      operations += 1
      prev.next = Node(e,prev.next)
      if (operations*operations >= setSize+1) constructSqrtNodes
    }
  }

  /** Length of the list
    * Post: S = S_0 && returns #S */
  def size : Int = setSize

  /** Does the set contain e?
    * Post: S = S_0 && returns (e in S) */
  def contains(e: Int) : Boolean = {
    val prev = find(e)._1
    prev.next != null && prev.next.datum == e
  }

  /** Return any member of the set.  (This is comparable to the operation
    * "head" on scala.collection.mutable.Set, but we'll use a name that does
    * not suggest a particular order.)
    * Pre: S != {}
    * Post: S = S_0 && returns e s.t. e in S */
  def any : Int = {
    require(setSize > 0)
    theSet.next.datum
  }

  /** Remove e from the set; result says whether e was in the set initially
    * Post S = S_0 - {e} && returns (e in S_0) */
  def remove(e: Int) : Boolean = {
    val temp = find(e)
    val prev = temp._1
    val prevSqrt = temp._2
    if (prev.next == null || prev.next.datum != e) false
    else {
      setSize -= 1
      operations += 1
      if (prevSqrt+1 < sqrtNodes.size && sqrtNodes(prevSqrt+1)==prev.next) {
        sqrtNodes(prevSqrt+1) = prev.next.next
      }
      prev.next = prev.next.next
      if (operations*operations >= setSize+1) constructSqrtNodes
      true
    }
  }
    
  /** Test whether this is a subset of that.
    * Post S = S_0 && returns S subset-of that.S */
  def subsetOf(that: IntSet) : Boolean = {
    var curr = theSet.next
    var other = that.theSet.next
    var success = true
    while (success && curr != null) {
      if (other == null || curr.datum < other.datum) success = false
      else {
        if (curr.datum == other.datum) curr = curr.next
        other = other.next
      }
    }
    success
  }

  /** Does this equal that?
    * Post: S = S_0 && returns that.S = S */
  override def equals(that: Any) : Boolean = that match {
    case s: IntSet => {
      var curr = theSet.next
      var other = s.theSet.next
      var success = true
      while (success && (curr != null || other != null)) {
        if (curr == null || other == null || curr.datum != other.datum) success = false
        else {
          curr = curr.next
          other = other.next
        }
      }
      success
    }
    case _ => false
  }

  // ----- optional parts below here -----

  /** return union of this and that.  
    * Post: S = S_0 && returns res s.t. res.S = this U that.S */
  def union(that: IntSet) : IntSet = {
    val result = IntSet()
    var curr = theSet.next
    var other = that.theSet.next
    while (curr != null || other != null) {
      if (other == null || (curr != null && curr.datum < other.datum)) {
        result.addAtEnd(curr.datum)
        curr = curr.next
      }
      else if (curr == null || (other != null && other.datum < curr.datum)) {
        result.addAtEnd(other.datum)
        other = other.next
      }
      else {
        result.addAtEnd(curr.datum)
        curr = curr.next
        other = other.next
      }
    }
    result.constructSqrtNodes
    result
  }

  /** return intersection of this and that.  
    * Post: S = S_0 && returns res s.t. res.S = this intersect that.S */
  def intersect(that: IntSet) : IntSet = {
    val result = IntSet()
    var curr = theSet.next
    var other = that.theSet.next
    while (curr != null && other != null) {
      if (curr.datum < other.datum) {
        curr = curr.next
      }
      else if (other.datum < curr.datum) {
        other = other.next
      }
      else {
        result.addAtEnd(curr.datum)
        curr = curr.next
        other = other.next
      }
    }
    result.constructSqrtNodes
    result
  }

  /** return diff of this and that.  
    * Post: S = S_0 && returns res s.t. res.S = this / that.S */
  def diff(that: IntSet) : IntSet = {
    val result = IntSet()
    var curr = theSet.next
    var other = that.theSet.next
    while (curr != null) {
      if (other == null || curr.datum < other.datum) {
        result.addAtEnd(curr.datum)
        curr = curr.next
      }
      else if (other.datum < curr.datum) {
        other = other.next
      }
      else {
        curr = curr.next
        other = other.next
      }
    }
    result.constructSqrtNodes
    result
  }

  /** filter
    * Post: S = S_0 && returns res s.t. res.S = {x | x <- S && p(x)} */
  def filter(p : Int => Boolean) : IntSet = {
    val result = IntSet()
    var curr = theSet.next
    while (curr != null) {
      if (p(curr.datum)) {
        result.addAtEnd(curr.datum)
      }
      curr = curr.next
    }
    result.constructSqrtNodes
    result
  }

  /** map
    * Post: S = S_0 && returns res s.t. res.S = {f(x) | x <- S} */
  def map(f: Int => Int) : IntSet = {
    val result = new IntSet;
    var curr = theSet.next
    val listBuffer = new scala.collection.mutable.ListBuffer[Int];
    while (curr != null) {
      listBuffer += f(curr.datum)
      curr = curr.next
    }
    val list = listBuffer.toList.sorted
    for (e <- list) result.addAtEnd(e)
    result.constructSqrtNodes
    result
  }
}


// The companion object
object IntSet{
  /** The type of nodes defined in the linked list */
  private class Node(var datum: Int, var next: Node)

  /** Factory method for sets.
    * This will allow us to write, for example, IntSet(3,5,1) to
    * create a new set containing 3, 5, 1 -- once we have defined 
    * the main constructor and the add operation. 
    * post: returns res s.t. res.S = {x1, x2,...,xn}
    *       where xs = [x1, x2,...,xn ] */
  def apply(xs: Int*) : IntSet = {
    val result = new IntSet;
    val listBuffer = new scala.collection.mutable.ListBuffer[Int];
    for (x <- xs) listBuffer +=x
    val list = listBuffer.toList.sorted
    for (e <- list) result.addAtEnd(e)
    result.constructSqrtNodes
    result
  }
}