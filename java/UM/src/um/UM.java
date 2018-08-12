package um;

import java.io.EOFException;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;

import javax.swing.text.html.parser.ParserDelegator;

public class UM {

    static byte[] bytes;
    static Path path;
    static ArrayList<ArrayList<Long>> arrayCollection = new ArrayList<>();
    static int iFinger = 0;

    public static void main(String[] args) throws EOFException, IOException {
	arrayCollection.add(new ArrayList<Long>());
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
	    long hold = ((bytes[i + 3] & 0xFF) << 0) | ((bytes[i + 2] & 0xFF) << 8) | ((bytes[i + 1] & 0xFF) << 16)
		    | ((bytes[i] & 0xFF) << 24);
	    arrayCollection.get(0).add(hold);
	}

	String bits;
	String opCode;
	String regA;
	String regB;
	String regC;

	while (true) {
	    bits = String.format("%1$" + 32 + "s", Long.toBinaryString(arrayCollection.get(0).get(iFinger)))
		    .replace(' ', '0');
	    opCode = bits.substring(0, 4);
	    regA = bits.substring(23,26);
	    regB = bits.substring(26,29);
	    regC = bits.substring(29,32);

	    iFinger++;

	}
    }

}
