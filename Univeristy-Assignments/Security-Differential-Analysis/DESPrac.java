import java.util.Random;
import java.io.*;
import java.math.BigInteger;
import java.util.HashSet;
import java.util.Iterator;

class DESPrac
{
    public static void main(String[] args) throws IOException
    {
        //testEncryption(1);
        //differentialDistributionTable(0);
        differentialAttack();
    }

    static void differentialAttack() throws IOException
    {
        HashSet<Integer> s0 = new HashSet<Integer>();
        HashSet<Integer> s[] = {s0, s0, s0, s0, s0, s0, s0, s0};
        for (int i = 0; i < 7; i++)
        {
            s[i] = differentialAttackBox(i);
        }
    }

    static void differentialAttackBox(int n) throws IOException
    {
        int bestFreq = 0;
        int DeltaE = 0;
        int targetDeltaO = 0;
        for (int i = 4; i < 16; i += 4)
        {
            int freq[] = new int[16];
            for (int j = 0; j < 64; j++)
            {
                int diff = STables[n][i ^ j] ^ STables[n][j];
                freq[diff]++;
            }
            for (int j = 0; j < 16; j++)
            {
                if (freq[j] < 16 && bestFreq < freq[j])
                {
                    bestFreq = freq[j];
                    DeltaE = i;
                    targetDeltaO = j;
                }
            }
        }
        int shift1 = 32 - (n + 1) * 4;
        long DeltaR = (long) DeltaE >> 1 << shift1;
        long DeltaL = PBox((long) targetDeltaO << shift1);
        long DeltaP = (DeltaL << 32) | DeltaR;
        long targetDeltaC = DeltaR;

        Random rand = new Random();
        HashSet<Integer> s = new HashSet<Integer>();
        for (int k = 0; k < 64; k++)
        {
            s.add(k);
        }
        for (int i = 0; i < 128 && s.size() > 2; i++)
        {
            long P = rand.nextLong();
            long P_ = P ^ DeltaP;

            long C = callEncrypt(P);
            long C_ = callEncrypt(P_);

            long DeltaC = C ^ C_;
            if (DeltaC != targetDeltaC) continue;

            int shift2 = 48 - (n + 1) * 6;
            int E = (int) (EBox(P & MASK32) >> shift2) & MASK6;
            int E_ = (int) (EBox(P_ & MASK32) >> shift2) & MASK6;
            
            for (int k = 0; k < 64; k++)
            {
                int O = STables[n][E ^ k];
                int O_ = STables[n][E_ ^ k];
                if ((O ^ O_) != targetDeltaO) s.remove(k);
            }
        }
        System.out.printf("%d options:", s.size());
        for (Integer k : s)
        {
            System.out.printf(" %X", k);
        }
        System.out.printf("\n");

        return s;
    }

    static void differentialDistributionTable(int n)
    {
        System.out.printf("   |");
        for (int j = 0; j < 16; j++)
        {
            System.out.printf(" %2X", j);
        }
        System.out.printf("\n");
        System.out.printf("---+");
        for (int j = 0; j < 16; j++)
        {
            System.out.printf("---");
        }
        System.out.printf("\n");
        for (int i = 0; i < 64; i++)
        {
            int freq[] = new int[16];
            for (int j = 0; j < 64; j++)
            {
                int diff = STables[n][i ^ j] ^ STables[n][j];
                freq[diff]++;
            }
            System.out.printf("%02X |", i);
            for (int j = 0; j < 16; j++)
            {
                System.out.printf(" %2d", freq[j]);
            }
            System.out.printf("\n");
        }
    }

    static void testEncryption(int trials)
    {
        long testP = 0x1234567887654321L;
        long testK = 0x33333333333333L;
        long testC = TwoRoundModifiedDES(testK, testP);
        if (testC == 0xC844E31B90953751L)
        {
            System.out.printf("Test encryption passed.\n");
        }
        else
        {
            System.out.printf("Test encryption NOT passed!\n");
            System.out.printf("Result: 0x%X\n", testC);
        }
        
        Random rand = new Random();
        long startT = System.nanoTime();
        for (int i = 0; i < trials; i++)
        {
            testP = rand.nextLong();
            testK = rand.nextLong() & MASK56;
            testC = TwoRoundModifiedDES(testK, testP);
        }
        long midT = System.nanoTime();
        for (int i = 0; i < trials; i++)
        {
            testP = rand.nextLong();
            testK = rand.nextLong() & MASK56;
        }
        long endT = System.nanoTime();
        long totalT = (midT - startT) - (endT - midT);
        double avgT = totalT * 1.0 / trials / 1e3;
        double avdDT = (1L << 55) * avgT / 1e6 / 60 / 60 / 24 / 365 / 100;
        System.out.printf("Encryption time: %.4g microseconds.\n", avgT);
        System.out.printf("Brute force decryption time: %.4g centuries.\n", avdDT);
    }

    // constants for &-ing with, to mask off everything but the bottom 32- or 48-bits of a long
    static int MASK6 = 0x3f;
    static long MASK32 = 0xffffffffL;
    static long MASK48 = 0xffffffffffffL;
    static long MASK56 = 0xffffffffffffffL;

    static long TwoRoundModifiedDES(long K, long P) // input is a 56-bit key "long" and a 64-bit plaintext "long", returns the ciphertext
    {
        long L0 = (P >> 32) & MASK32; // watch out for the sign extension!
        long R0 = P & MASK32;
        long K1 = K & MASK48;
        long K2 = (K >> 8) & MASK48;

        long L1 = R0;
        long R1 = L0 ^ Feistel(R0, K1);

        long L2 = R1;
        long R2 = L1 ^ Feistel(R1, K2);

        long C = L2 << 32 | R2;

        return C;
    }

    static long Feistel(long R, long K) // input is a 32-bit integer and 48-bit key, both stored in 64-bit signed "long"s; returns the output of the Feistel round
    {
        long F = R;
        F = EBox(F);
        F ^= K;
        F = SBox(F);
        F = PBox(F);
        F ^= (K & MASK32);
        return F;
    }

    // NB: these differ from the tables in the DES standard because the latter are encoded in a strange order

    static final byte[] S1Table = {
     3,  7,  5,  1, 12,  8,  2, 11, 10,  3, 15,  6,  7, 12,  8,  2,
    13,  0, 11,  4,  6,  5,  1, 14,  0, 10,  4, 13,  9, 15, 14,  9,
     4,  1,  2, 12, 11, 14, 15,  5, 14,  7,  8,  3,  1,  8,  5,  6,
     9, 15, 12, 10,  0, 11, 10,  0, 13,  4,  7,  9,  6,  2,  3, 11,
    };

    static final byte[] S2Table = {
    13,  1,  2, 15,  8, 13,  4,  8,  6, 10, 15,  3, 11,  7,  1,  4,
    10, 12,  9,  5,  3,  6, 14, 11,  5,  0,  0, 14, 12,  9,  7,  2,
     7,  2, 11,  1,  4, 14,  1,  7,  9,  4, 12, 10, 14,  8,  2, 13,
     0, 15,  6, 12, 10,  9, 13,  0, 15,  3,  3,  5,  5,  6,  8, 11,
    };

    static final byte[] S3Table = {
    14,  0,  4, 15, 13,  7,  1,  4,  2, 14, 15,  2, 11, 13,  8,  1,
     3, 10, 10,  6,  6, 12, 12, 11,  5,  9,  9,  5,  0,  3,  7,  8,
     4, 15,  1, 12, 14,  8,  8,  2, 13,  4,  6,  9,  2,  1, 11,  7,
    15,  5, 12, 11,  9,  3,  7, 14,  3, 10, 10,  0,  5,  6,  0, 13,
    };

    static final byte[] S4Table = {
    10, 13,  0,  7,  9,  0, 14,  9,  6,  3,  3,  4, 15,  6,  5, 10,
     1,  2, 13,  8, 12,  5,  7, 14, 11, 12,  4, 11,  2, 15,  8,  1,
    13,  1,  6, 10,  4, 13,  9,  0,  8,  6, 15,  9,  3,  8,  0,  7,
    11,  4,  1, 15,  2, 14, 12,  3,  5, 11, 10,  5, 14,  2,  7, 12,
    };

    static final byte[] S5Table = {
     7, 13, 13,  8, 14, 11,  3,  5,  0,  6,  6, 15,  9,  0, 10,  3,
     1,  4,  2,  7,  8,  2,  5, 12, 11,  1, 12, 10,  4, 14, 15,  9,
    10,  3,  6, 15,  9,  0,  0,  6, 12, 10, 11,  1,  7, 13, 13,  8,
    15,  9,  1,  4,  3,  5, 14, 11,  5, 12,  2,  7,  8,  2,  4, 14,
    };

    static final byte[] S6Table = {
     2, 14, 12, 11,  4,  2,  1, 12,  7,  4, 10,  7, 11, 13,  6,  1,
     8,  5,  5,  0,  3, 15, 15, 10, 13,  3,  0,  9, 14,  8,  9,  6,
     4, 11,  2,  8,  1, 12, 11,  7, 10,  1, 13, 14,  7,  2,  8, 13,
    15,  6,  9, 15, 12,  0,  5,  9,  6, 10,  3,  4,  0,  5, 14,  3,
    };

    static final byte[] S7Table = {
    12, 10,  1, 15, 10,  4, 15,  2,  9,  7,  2, 12,  6,  9,  8,  5,
     0,  6, 13,  1,  3, 13,  4, 14, 14,  0,  7, 11,  5,  3, 11,  8,
     9,  4, 14,  3, 15,  2,  5, 12,  2,  9,  8,  5, 12, 15,  3, 10,
     7, 11,  0, 14,  4,  1, 10,  7,  1,  6, 13,  0, 11,  8,  6, 13,
    };

    static final byte[] S8Table = {
     4, 13, 11,  0,  2, 11, 14,  7, 15,  4,  0,  9,  8,  1, 13, 10,
     3, 14, 12,  3,  9,  5,  7, 12,  5,  2, 10, 15,  6,  8,  1,  6,
     1,  6,  4, 11, 11, 13, 13,  8, 12,  1,  3,  4,  7, 10, 14,  7,
    10,  9, 15,  5,  6,  0,  8, 15,  0, 14,  5,  2,  9,  3,  2, 12,
    };

    // STables[i-1][s] is the output for input s to S-box i
    // The output of each S box is uniform given an uniform input.
    // Each output o is mapped to by exactly 4 possible inputs s1, s2, s3, s4.
    // P(O = o) = P(S = s1) + P(S = s2) + P(S = s3) + P(S = s4) = 4 / 64 = 1 / 16
    static final byte[][] STables = {S1Table, S2Table, S3Table, S4Table, S5Table, S6Table, S7Table, S8Table};

    static long SBox(long S) // input is a 48-bit integer stored in 64-bit signed "long"
    {
        // Split I into eight 6-bit chunks
        int Sa = (int) ((S >> 42));
        int Sb = (int) ((S >> 36) & 63);
        int Sc = (int) ((S >> 30) & 63);
        int Sd = (int) ((S >> 24) & 63);
        int Se = (int) ((S >> 18) & 63);
        int Sf = (int) ((S >> 12) & 63);
        int Sg = (int) ((S >> 6) & 63);
        int Sh = (int) (S & 63);
        // Apply the S-boxes
        byte Oa = S1Table[Sa];
        byte Ob = S2Table[Sb];
        byte Oc = S3Table[Sc];
        byte Od = S4Table[Sd];
        byte Oe = S5Table[Se];
        byte Of = S6Table[Sf];
        byte Og = S7Table[Sg];
        byte Oh = S8Table[Sh];
        // Combine answers into 32-bit output stored in 64-bit signed "long"
        long O = (long) Oa << 28 | (long) Ob << 24 |
                 (long) Oc << 20 | (long) Od << 16 |
                 (long) Oe << 12 | (long) Of << 8 |
                 (long) Og << 4 | (long) Oh;
        return O;
    }

    static long EBox(long R) // input is a 32-bit integer stored in 64-bit signed "long"
    {
        // compute each 6-bit component
        long Ea = (R >> 27) & 31 | (R & 1) << 5;
        long Eb = (R >> 23) & 63;
        long Ec = (R >> 19) & 63;
        long Ed = (R >> 15) & 63;
        long Ee = (R >> 11) & 63;
        long Ef = (R >> 7) & 63;
        long Eg = (R >> 3) & 63;
        long Eh = (R >> 31) & 1 | (R & 31) << 1;
        // 48-bit output stored in 64-bit signed "long"
        long E = (long) Ea << 42 | (long) Eb << 36 |
                 (long) Ec << 30 | (long) Ed << 24 |
                 (long) Ee << 18 | (long) Ef << 12 |
                 (long) Eg << 6 | (long) Eh;
        return E;
    }

    static final int[] Pbits = {
    16,  7, 20, 21,
    29, 12, 28, 17,
     1, 15, 23, 26,
     5, 18, 31, 10,
     2,  8, 24, 14,
    32, 27,  3,  9,
    19, 13, 30,  6,
    22, 11,  4, 25
    };

    // this would have been a lot faster as fixed binary operations rather than a loop
    static long PBox(long O) // input is a 32-bit integer stored in 64-bit signed "long"
    {
        long P = 0L;
        for(int i = 0; i < 32; i++)
        {
            P |= ((O >> (32 - Pbits[i])) & 1) << (31 - i);
        }
        return P;
    }

    // a helper method to call the external programme "desencrypt" in the current directory
    // the parameter is the 64-bit plaintext to encrypt, returns the ciphertext
    static long callEncrypt(long P) throws IOException
    {
        Process process = Runtime.getRuntime().exec("./desencrypt " + Long.toHexString(P));
        String CString = (new BufferedReader(new InputStreamReader(process.getInputStream()))).readLine();

        // we have to go via BigInteger otherwise the signed longs cause incorrect parsing
        long C = new BigInteger(CString, 16).longValue();

        return C;
    }

}
