import java.io.*;
import javax.xml.bind.annotation.adapters.HexBinaryAdapter;
import java.util.Arrays;
import java.text.DecimalFormat;

public class BeastAttackNormal
{
    static int blockSize = 8;

    static int matches = 0;
    static int trials = 0;
    static int encryptions = 0;
       
    public static void main(String[] args) throws Exception
    {
        boolean fancy = false;
        if (args.length > 0 && args[0].equals("fancy")) fancy = true;

        byte[] message = new byte[1024];

        int messageLength = initPrediction();
        System.out.println("The message is " + messageLength + " bytes long.");

        generateAllBytes();

        decryptMessage(message, messageLength, fancy);
        if (!fancy) printBytesAsChars(message, messageLength);
        System.out.println("");

        DecimalFormat df2 = new DecimalFormat("#.##");
        System.out.println("Used " + encryptions + " encryptions.");
        System.out.println(df2.format(matches * 100.0 / trials) + "% IV match rate.");
    }

    static String commonSymbols = " etaoinsrhdlucmfywgpbvkxqjzETAOINSRHDLUCMFYWGPBVKXQJZ1234567890,.!?():;\"\'[]{}/\\\n\r\t#$%&*+-<=>@^_`|~";
    // All possible bytes roughly arranged in terms of frequency
    static byte[] allBytes;

    // Generates the array of all bytes starting with the most common symbols
    static void generateAllBytes()
    {
        allBytes = new byte[256];
        boolean[] byteUsed = new boolean[256];

        for (int i = 0; i < 256; i++)
        {
            byteUsed[i] = false;
        }
        int j = 0;
        for (int i = 0; i < commonSymbols.length(); i++)
        {
            byte b = (byte) commonSymbols.charAt(i);
            byteUsed[(int) b] = true;
            allBytes[j] = b;
            j++;
        }
        for (int i = 0; i < 256; i++)
        {
            if (!byteUsed[i])
            {
                allBytes[j] = (byte) i;
                j++;
            }
        }
    }

    // Decrypts the message
    static void decryptMessage(byte[] message, int messageLength, boolean fancy) throws Exception
    {
        byte[] ciphertext = new byte[1024];
        byte[] oldBlock = new byte[blockSize];
        byte[] prefix = new byte[blockSize];
        byte[] xorWith = new byte[blockSize];
        byte[] xordPrefix = new byte[blockSize];

        for (int byteNum = 0; byteNum < messageLength; byteNum++)
        {
            for (int i = 0; i < blockSize - 1; i++)
            {
                int j = byteNum - blockSize + i + 1;
                prefix[i] = j >=0 ? message[j] : 0;
            }

            int prefixLength = blockSize - byteNum % blockSize - 1;
            callEncrypt(prefix, prefixLength, ciphertext);
            copyBlock(ciphertext, oldBlock, byteNum / blockSize + 1);
            copyBlock(ciphertext, xorWith, byteNum / blockSize);

            int i = 0;
            if (fancy) System.out.print(" ");
            do
            {
                if (fancy) System.out.print("\b" + (char) allBytes[i]);
                prefix[blockSize - 1] = allBytes[i];
                xorBlock(prefix, xorWith, xordPrefix);
                callEncryptWithIV(xordPrefix, ciphertext);
                i++;
            }
            while (!checkMatchBlock(ciphertext, oldBlock, 1));
            message[byteNum] = prefix[blockSize - 1];
        }
    }

    // Prints a string of bytes as chars
    static void printBytesAsChars(byte[] bytes, int length)
    {
        for (int i = 0; i < length; i++)
        {
            System.out.print((char) bytes[i]);
        }
    }

    // Calls encrypt with a blockSize long prefix XORed with the IV
    static void callEncryptWithIV(byte[] prefix , byte[] ciphertext) throws Exception
    {
        byte[] predictedIV = new byte[blockSize];
        byte[] xordPrefix = new byte[blockSize];
        do
        {
            trials++;
            predictIV(predictedIV);
            xorBlock(prefix, predictedIV, xordPrefix);
            callEncrypt(xordPrefix, blockSize, ciphertext);
            updateIV(ciphertext);
        }
        while (!checkMatchBlock(ciphertext, predictedIV, 0));
        matches++;
    }
 
    static long initIV = 0;
    static long initTime = 0;
    static long lastPredictedIV = 0;
    static long lastDiff = 0;

    // Initializes the prediction, returns the length of the message
    static int initPrediction() throws Exception
    {
        byte[] ciphertext = new byte[1024];
        byte[] bytes = new byte[blockSize];

        initTime = System.currentTimeMillis();
        int initLength = callEncrypt(null, 0, ciphertext);
        initIV = bytesToLong(ciphertext);

        int length = initLength;
        int prefLen = 0;
        while (length == initLength)
        {
            prefLen++;
            length = callEncrypt(bytes, prefLen, ciphertext);
        }
        return initLength - blockSize - prefLen + 1;
    }

    // Predicts the IV
    static void predictIV(byte[] predictedIV)
    {
        long timeDelta = System.currentTimeMillis() - initTime;
        lastPredictedIV = initIV + timeDelta * 5;
        longToBytes(lastPredictedIV + lastDiff, predictedIV);
    }
    
    // Call with the ciphertext to update predictions for accuracy
    static void updateIV(byte[] ciphertext)
    {
        long realIV = bytesToLong(ciphertext);
        lastDiff = realIV - lastPredictedIV;
    }

    // Returns whether the first blockSize bytes match, from starts from startBlock
    static boolean checkMatchBlock(byte[] from, byte[] to, int startBlock)
    {
        for (int i = 0; i < blockSize; i++)
        {
            if (from[startBlock * blockSize + i] != to[i]) return false;
        }
        return true;
    }

    // Copies the first blockSize bytes, from starts from startBlock
    static void copyBlock(byte[] from, byte[] to, int startBlock)
    {
        for (int i = 0; i < blockSize; i++)
        {
            to[i] = from[startBlock * blockSize + i];
        }
    }

    // XORs the first blockSize bytes
    static void xorBlock(byte[] from1, byte[] from2, byte[] to)
    {
        for (int i = 0; i < blockSize; i++)
        {
            to[i] = (byte) (from1[i] ^ from2[i]);
        }
    }
    
    // Takes blockSize bytes and concatenates them
    static long bytesToLong(byte[] bytes)
    {
        long num = 0;
        for (int i = 0; i < blockSize; i++)
        {
            num = num << 8;
            long curr = bytes[i] & 0xFF;
            num = num | curr;
        }
        return num;
    }

    // Takes blockSize concatenated bytes and splits them
    static void longToBytes(long num, byte[] bytes)
    {
        for (int i = blockSize - 1; i >= 0; i--)
        {
            bytes[i] = (byte) num;
            num = num >> 8;
        }
    }

    // a helper method to call the external programme "encrypt" in the current directory
    // the parameters are the plaintext, length of plaintext, and ciphertext; returns length of ciphertext
    static int callEncrypt(byte[] prefix, int prefix_len, byte[] ciphertext) throws IOException
    {
        ++encryptions;

        HexBinaryAdapter adapter = new HexBinaryAdapter();
        Process process;
	
        // run the external process (don't bother to catch exceptions)
        if (prefix != null)
        {
            // turn prefix byte array into hex string
            byte[] p = Arrays.copyOfRange(prefix, 0, prefix_len);
            String PString = adapter.marshal(p);
            process = Runtime.getRuntime().exec("./encrypt " + PString);
        }
        else
        {
            process = Runtime.getRuntime().exec("./encrypt");
        }

        // process the resulting hex string
        String CString = (new BufferedReader(new InputStreamReader(process.getInputStream()))).readLine();
        byte[] c = adapter.unmarshal(CString);
        System.arraycopy(c, 0, ciphertext, 0, c.length);
        return c.length;
    }
}
