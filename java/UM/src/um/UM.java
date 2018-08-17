package um;

import java.io.EOFException;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;

public class UM {

    static byte[] bytes;
    static Path path;
    static ArrayList<ArrayList<Long>> arrayCollection = new ArrayList<>();
    static long iFinger = 0;

    public static void main(String[] args) throws EOFException, IOException {
	arrayCollection.add(0, new ArrayList<Long>());
	if (args.length < 1) {
	    path = Paths.get("/home/aecium/workspace/ICFP2006/um/sandmark.umz");
	} else {
	    path = Paths.get(args[0]);
	}

	try {
	    bytes = Files.readAllBytes(path);
	    int a = 1;
	} catch (IOException e) {
	    // TODO Auto-generated catch block
	    e.printStackTrace();
	}

	for (int i = 0; i < (bytes.length - 1) / 4; i += 4) {
//	    Long hold = (long) (((bytes[i + 3] & 0xFF) << 0) | ((bytes[i + 2] & 0xFF) << 8) | ((bytes[i + 1] & 0xFF) << 16)
//		    | ((bytes[i] & 0xFF) << 24));
	    long value = byteAsULong(bytes[i + 3]) | (byteAsULong(bytes[i + 2]) << 8)
		    | (byteAsULong(bytes[i + 1]) << 16) | (byteAsULong(bytes[i]) << 24);
	    arrayCollection.get(0).add(value);
	}

	Long[] GPR = { (long) 0, (long) 0, (long) 0, (long) 0, (long) 0, (long) 0, (long) 0, (long) 0 };
	String bits;
	String opCode;
	int regA;
	int regB;
	int regC;
	int A13;
	Long val13;
	String bitsB;
	String bitsC;
	String notAndBits;
	boolean run = true;
	Long arrayColectionSize = (long) arrayCollection.size();

	while (run) {
	    bits = String.format("%1$" + 32 + "s", Long.toBinaryString(arrayCollection.get(0).get((int) iFinger)))
		    .replace(' ', '0');
	    opCode = bits.substring(0, 4);
	    regA = (int) bin2Dec(bits.substring(23, 26));
	    regB = (int) bin2Dec(bits.substring(26, 29));
	    regC = (int) bin2Dec(bits.substring(29, 32));

	    int a = 1;

	    switch (opCode) {
	    // 0 Conditional Move
	    case "0000":
		// System.out.println("Conditional Move");
		if (GPR[regC] != 0) {
		    GPR[regA] = GPR[regB];
		}
		break;
	    // 1 Array Index
	    case "0001":
		// System.out.println("Array Index");
		GPR[regA] = arrayCollection.get(Integer.parseUnsignedInt((GPR[regB].toString())))
			.get(Integer.parseUnsignedInt(GPR[regC].toString()));
		break;
	    // 2 Array Amendment
	    case "0010":
		// System.out.println("Array Amendment");
		arrayCollection.get(Integer.parseUnsignedInt(GPR[regA].toString()))
			.set(Integer.parseUnsignedInt((GPR[regB].toString())), GPR[regC]);
		break;
	    // 3 Addition
	    case "0011":
		// System.out.println("Addition");
		GPR[regA] = Integer.parseUnsignedInt(GPR[regB].toString())
			+ Integer.parseUnsignedInt(GPR[regC].toString()) % (long) Math.pow(2, 32);
		break;
	    case "0100":
		// System.out.println("Multiplication");
		GPR[regA] = Integer.parseUnsignedInt(GPR[regB].toString())
			* Integer.parseUnsignedInt(GPR[regC].toString()) % (long) Math.pow(2, 32);
		;
		break;
	    // 5 Division
	    case "0101":
		// System.out.println("Division");
		GPR[regA] = Long.divideUnsigned(GPR[regB], GPR[regC]);
		break;
	    // 6 Not And
	    case "0110":
		// System.out.println("Not And");
		bitsB = String.format("%1$" + 32 + "s", Long.toBinaryString(GPR[regB])).replace(' ', '0');
		bitsC = String.format("%1$" + 32 + "s", Long.toBinaryString(GPR[regC])).replace(' ', '0');
		notAndBits = "";
		for (int i = 0; i < 32; i++) {
		    if (bitsB.substring(i, i + 1).equals("0") || bitsC.substring(i, i + 1).equals("0")) {
			notAndBits += '1';
		    } else {
			notAndBits += '0';
		    }
		}
		GPR[regA] = bin2Dec(notAndBits);
		break;
	    // 7 Halt
	    case "0111":
		// System.out.println("Halt");
		run = false;
		break;
	    // 8 Allocation
	    case "1000":
		// System.out.println("Allocation");
		arrayCollection.add(new ArrayList<Long>());
		arrayColectionSize = (long) arrayCollection.size() - 1;
		for (int i = 1; i <= GPR[regC]; i++) {
		    arrayCollection.get(Integer.parseUnsignedInt(arrayColectionSize.toString())).add((long) 0);
		}
		GPR[regB] = arrayColectionSize;
		break;
	    // 9 Abandonment
	    case "1001":
		// System.out.println("Abandonment");
		arrayCollection.remove(GPR[regC]);
		arrayColectionSize--;
		break;
	    // 10 Output
	    case "1010":
		System.out.write(Integer.parseUnsignedInt(GPR[regC].toString()));
		System.out.flush();
		break;
	    // 11 Input
	    case "1011":
		// System.out.println("Input");
		break;
	    // 12 Load Program
	    case "1100":
		// System.out.println("Load Program");
		arrayCollection.set(0, arrayCollection.get(Integer.parseUnsignedInt(GPR[regB].toString())));
		iFinger = GPR[regC] - 1;
		break;
	    // 13 Orthography
	    case "1101":
		// System.out.println("Orthography");
		A13 = (int) bin2Dec(bits.substring(4, 7));
		val13 = bin2Dec(bits.substring(7, 32));
		GPR[A13] = val13;
		break;
	    }

	    iFinger++;

	    if (iFinger > arrayCollection.get(0).size()) {
		System.out.println("Stoped unexpected EOF");
		break;
	    }

	}
    }

    private static long bin2Dec(String bin) {
	long dec = 0;
	int j = 0;
	for (int i = bin.length(); i > 0; i--) {
	    if (bin.substring(i - 1, i).equals("1")) {
		dec = dec + (int) Math.pow(2, j);
	    }
	    j++;
	}

	return dec;
    }

    public static long byteAsULong(byte b) {
	return ((long) b) & 0x00000000000000FFL;
    }
}
