object Cipher{
  /** Bit-wise exclusive-or of two characters */
  def xor(a: Char, b: Char) : Char = (a.toInt ^ b.toInt).toChar

  /** Print ciphertext in octal */
  def showCipher(cipher: Array[Char]) =
    for(c <- cipher){ print(c/64); print(c%64/8); print(c%8); print(" ") }

  /** Read file into array */
  def readFile(fname: String) : Array[Char] = 
    scala.io.Source.fromFile(fname).toArray

  /** Read from stdin in a similar manner */
  def readStdin() = scala.io.Source.stdin.toArray

  /** Encrypt plain using key; can also be used for decryption */
  def encrypt(key: Array[Char], plain: Array[Char]) : Array[Char] = {
    val n = plain.size; val k = key.size
    var encrypted = new Array[Char](n)
    var keyPos = 0; var i = 0
    while (i < n) {
      encrypted(i) = xor(plain(i),key(keyPos))
      i += 1
      keyPos = (keyPos+1) % k
    }
    encrypted
  }

  /** Try to decrypt ciphertext, using crib as a crib */
  def tryCrib(crib: Array[Char], ciphertext: Array[Char]) = {
    val n = ciphertext.size; val k = crib.size

    /** Gets the key for the crib at some position if there is a matxch */
    def getKeyAt(pos : Int) : Array[Char] = {

      /** Checks ehther a prefix with some length repeats in the key */
      def checkKeyWith(key : Array[Char], len : Int) : Boolean = {
        var i = 0
        var succ = true
        while (i < k) {
          if (key(i) != key(i % len)) succ = false
          i += 1
        }
        succ
      }

      var key = new Array[Char](k) //initial key found
      var i = 0
      while (i < k) {
        key(i) = xor(crib(i),ciphertext(pos+i))
        i += 1
      }

      var pref = 0 //length of shortest prefix that repeats
      var done = false
      while (pref < k-2 && !done) {
        pref += 1
        done = checkKeyWith(key,pref)
      }

      if (!done) new Array[Char](0)
      else {
        var goodkey = new Array[Char](pref)
        //position in key where the proper key starts
        val start = (pos + pref - 1) / pref * pref - pos
        var i = 0
        while (i < pref) {
          goodkey(i) = key((start + i) % pref)
          i += 1
        }
        goodkey
      }
    }

    var bestkey = new Array[Char](0)
    var i = 0
    while (i < n-k+1) {
      var key = getKeyAt(i)
      if (key.size > 0  && (bestkey.size == 0 || bestkey.size > key.size)) bestkey = key
      i += 1
    }
    if (bestkey.size == 0) println("No matches found.")
    else {
      println(new String (bestkey))
      print(new String (encrypt(bestkey,ciphertext)))
    }
  }

  /** The first optional statistical test, to guess the length of the key */
  def crackKeyLen(ciphertext: Array[Char]) = {
    val n = ciphertext.size
     
    /** Counts mathces for a specific shift */
    def countMatchesWithShift(shift : Int) : Int = {
      var cnt = 0
      var i = 0
      while (i < n-shift) {
        if (ciphertext(i) == ciphertext(i+shift)) cnt += 1
        i += 1
      }
      cnt
    }
    
    var i = 1
    while (i <= 32) {
      println(i + ": " + countMatchesWithShift(i))
      i += 1
    }
  }

  /** The second statistical test, to guess characters of the key. */
  def crackKey(klen: Int, ciphertext: Array[Char]) = {
    val n = ciphertext.size

    /** Fing key guesses for a specific shift */
    def findKeyGuesses(shift : Int) = {
      var i = 0
      while (i < n-shift) {
        if (ciphertext(i) == ciphertext(i+shift)) {
          val keychar = xor(' ',ciphertext(i))
          val keypos = i % klen + 1
          if (keychar.toInt >= 32 && keychar.toInt < 128) println(keypos + " " + keychar)
        }
        i += 1
      }
    }
    
    var i = 1
    while (klen * i < n) {
      findKeyGuesses(klen * i)
      i += 1
    }
  }

/** The main method just selects which piece of functionality to run */
  def main(args: Array[String]) = {
    // string to print if error occurs
    val errString = 
      "Usage: scala Cipher (-encrypt|-decrypt) key [file]\n"+
      "     | scala Cipher -crib crib [file]\n"+
      "     | scala Cipher -crackKeyLen [file]\n"+
      "     | scala Cipher -crackKey len [file]"

    // Get the plaintext, either from the file whose name appears in position
    // pos, or from standard input
    def getPlain(pos: Int) = 
      if(args.length==pos+1) readFile(args(pos)) else readStdin

    // Check there are at least n arguments
    def checkNumArgs(n: Int) = if(args.length<n){println(errString); sys.exit}

    // Parse the arguments, and call the appropriate function
    checkNumArgs(1)
    val command = args(0)
    if(command=="-encrypt" || command=="-decrypt"){
      checkNumArgs(2); val key = args(1).toArray; val plain = getPlain(2)
      print(new String (encrypt(key,plain)))
    }
    else if(command=="-crib"){
      checkNumArgs(2); val key = args(1).toArray; val plain = getPlain(2)
      tryCrib(key, plain)
    }
    else if(command=="-crackKeyLen"){
      checkNumArgs(1); val plain = getPlain(1)
      crackKeyLen(plain)
    }      
    else if(command=="-crackKey"){
      checkNumArgs(2); val klen = args(1).toInt; val plain = getPlain(2)
      crackKey(klen, plain)
    }
    else println(errString)
  }
}
