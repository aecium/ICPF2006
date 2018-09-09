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
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

		for (int i = 0; i < (bytes.length - 1); i += 4) {
//	    Long hold = (long) (((bytes[i + 3] & 0xFF) << 0) | ((bytes[i + 2] & 0xFF) << 8) | ((bytes[i + 1] & 0xFF) << 16)
//		    | ((bytes[i] & 0xFF) << 24));
			long value = byteAsULong(bytes[i + 3]) | (byteAsULong(bytes[i + 2]) << 8)
					| (byteAsULong(bytes[i + 1]) << 16) | (byteAsULong(bytes[i]) << 24);
			arrayCollection.get(0).add(value);
		}

		Long[] GPR = { (long) 0, (long) 0, (long) 0, (long) 0, (long) 0, (long) 0, (long) 0, (long) 0 };
		Long bits;
		int opCode;
		int regA;
		int regB;
		int regC;
		int A13;
		Long val13;
		boolean run = true;
		int arrayColectionSize =  arrayCollection.size();

		while (run) {
			bits = arrayCollection.get(0).get((int) iFinger);
			opCode = (int) (bits >> 28);
			regA = (int) (bits >> 6) & 0x00000007;
			regB = (int) (bits >> 3) & 0x00000007;
			regC = (int) (bits & 0x00000007) ;

			switch (opCode) {
			// 0 Conditional Move
			case 0:
				// System.out.println("Conditional Move");
				if (GPR[regC] != 0) {
					GPR[regA] = GPR[regB];
				}
				break;
			// 1 Array Index
			case 1:
				// System.out.println("Array Index");
				GPR[regA] = arrayCollection.get(GPR[regB].intValue()).get(GPR[regC].intValue());
				break;
			// 2 Array Amendment
			case 2:
				// System.out.println("Array Amendment");
				arrayCollection.get(GPR[regA].intValue()).set(GPR[regB].intValue(), GPR[regC]);
				break;
			// 3 Addition
			case 3:
				// System.out.println("Addition");
				GPR[regA] = (GPR[regB] + GPR[regC]) % (long) Math.pow(2, 32);
				break;
			case 4:
				// System.out.println("Multiplication");
				GPR[regA] = (GPR[regB] * GPR[regC]) % (long) Math.pow(2, 32);
				;
				break;
			// 5 Division
			case 5:
				// System.out.println("Division");
				GPR[regA] = Long.divideUnsigned(GPR[regB], GPR[regC]);
				break;
			// 6 Not And
			case 6:
				// System.out.println("Not And");
				GPR[regA] = (GPR[regB] & GPR[regC]) ^ 0xFFFFFFFF;
				break;
			// 7 Halt
			case 7:
				// System.out.println("Halt");
				run = false;
				break;
			// 8 Allocation
			case 8:
				// System.out.println("Allocation");
				arrayCollection.add(new ArrayList<Long>());
				arrayColectionSize = arrayCollection.size() - 1;
				for (int i = 1; i <= GPR[regC]; i++) {
					arrayCollection.get(arrayColectionSize).add((long) 0);
				}
				GPR[regB] = (long) arrayColectionSize;
				break;
			// 9 Abandonment
			case 9:
				// System.out.println("Abandonment");
				arrayCollection.remove(GPR[regC]);
				arrayColectionSize--;
				break;
			// 10 Output
			case 10:
				System.out.write(Integer.parseUnsignedInt(GPR[regC].toString()));
				System.out.flush();
				break;
			// 11 Input
			case 11:
				// System.out.println("Input");
				GPR[regC] = (long) System.in.read();
				break;
			// 12 Load Program
			case 12:
				// System.out.println("Load Program");
				if (GPR[regB] != 0) {
					arrayCollection.set(0, new ArrayList<Long>(arrayCollection.get(GPR[regB].intValue())));
				}
				iFinger = GPR[regC] - 1;
				break;
			// 13 Orthography
			case 13:
				// System.out.println("Orthography");
				A13 = (int) (bits >> 25) & 0x00000007;
				val13 = (bits & 0x01FFFFFF);
				GPR[A13] = val13;
				break;
			}

			iFinger++;

		}
	}

	public static long byteAsULong(byte b) {
		return ((long) b) & 0x00000000000000FFL;
	}
}
