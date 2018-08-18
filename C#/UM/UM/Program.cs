using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;

namespace UM
{
	class MainClass
	{

		public static void Main(string[] args)
		{
			uint[] GPR = {0, 0, 0, 0, 0, 0, 0, 0};

			byte[] tBytes = null;
			String path;
			List<List<uint>> arrayCollection = new List<List<uint>>();
			int iFinger = 0;

			arrayCollection.Add(new List<uint>());
			if (args.Length < 1)
			{
				path = "/home/aecium/workspace/ICFP2006/um/sandmark.umz";
			}
			else
			{
				path = args[0];
			}

			try
			{
				tBytes = File.ReadAllBytes(path);
			}
			catch (IOException e)
			{
				// TODO Auto-generated catch block();
				System.Diagnostics.Debug.WriteLine(e.StackTrace);
			}

			for (int i = 0; i < tBytes.Length; i += 4)
			{
				//      Long hold = (long) (((bytes[i + 3] & 0xFF) << 0) | ((bytes[i + 2] & 0xFF) << 8) | ((bytes[i + 1] & 0xFF) << 16)
				//          | ((bytes[i] & 0xFF) << 24));
				long value = byteAsULong(tBytes[i + 3]) | (byteAsULong(tBytes[i + 2]) << 8)
					| (byteAsULong(tBytes[i + 1]) << 16) | (byteAsULong(tBytes[i]) << 24);
				arrayCollection[0].Add((uint)value);
			}

			Console.WriteLine("Program size: " + arrayCollection[0].Count);

			String bits;
			String opCode;
			uint regA;
			uint regB;
			uint regC;
			uint A13;
			uint val13;
			String bitsB;
			String bitsC;
			String notAndBits;
			Boolean run = true;
			int arrayColectionSize = arrayCollection.Count;

			while (run)
			{
				bits = Convert.ToString(arrayCollection[0][iFinger], 2).PadLeft(32).Replace(' ','0');
				opCode = bits.Substring(0, 4);
				regA = (uint)bin2Dec(bits.Substring(23,3));
				regB = (uint)bin2Dec(bits.Substring(26,3));
				regC = (uint)bin2Dec(bits.Substring(29,3));
               
				switch (opCode)
				{
					// 0 Conditional Move
					case "0000":
						//Console.Out.WriteLine("Conditional Move");
						if (GPR[regC] != 0)
						{
							GPR[regA] = GPR[regB];
						}
						break;
					// 1 Array Index
					case "0001":
						//Console.Out.WriteLine("Array Index");

						GPR[regA] = arrayCollection[(int)GPR[regB]][(int)GPR[regC]];
						break;
					// 2 Array Amendment
					case "0010":
						//Console.Out.WriteLine("Array Amendment");
						arrayCollection[(int)GPR[regA]][(int)GPR[regB]] = GPR[regC];
						break;
					// 3 Addition
					case "0011":
						//Console.Out.WriteLine("Addition");
						GPR[regA] = (uint)((GPR[regB] + GPR[regC]) % (long) Math.Pow(2,32));
						break;
					case "0100":
						//Console.Out.WriteLine("Multiplication");
						GPR[regA] = GPR[regA] = (uint)((GPR[regB] * GPR[regC]) % (long)Math.Pow(2, 32));
						break;
					// 5 Division
					case "0101":
						//Console.Out.WriteLine("Division");
						GPR[regA] = (uint)Math.Floor((double)(GPR[regB] / GPR[regC]));
						break;
					// 6 Not And
					case "0110":
						//Console.Out.WriteLine("Not And");
						bitsB = Convert.ToString(GPR[regB], 2).PadLeft(32).Replace(' ', '0');
						bitsC = Convert.ToString(GPR[regC], 2).PadLeft(32).Replace(' ', '0');
						notAndBits = "";
						for (int i = 0; i < 32; i++)
						{
							if (bitsB.Substring(i,1).Equals("0") || bitsC.Substring(i, 1).Equals("0"))
							{
								notAndBits += '1';
							}
							else
							{
								notAndBits += '0';
							}
						}
						GPR[regA] = bin2Dec(notAndBits);
						break;
					// 7 Halt
					case "0111":
						//Console.Out.WriteLine("Halt");
						run = false;
						break;
					// 8 Allocation
					case "1000":
						//Console.Out.WriteLine("Allocation");
						arrayCollection.Add(new List<uint>());
						arrayColectionSize = arrayCollection.Count - 1;
						for (int i = 1; i <= GPR[regC]; i++)
						{
							arrayCollection[arrayColectionSize].Add(0);
						}
						GPR[regB] = (uint) arrayColectionSize;
						break;
					// 9 Abandonment
					case "1001":
						//Console.Out.WriteLine("Abandonment");
						arrayCollection[(int)GPR[regC]] = null;
						arrayColectionSize--;
						break;
					// 10 Output
					case "1010":
						Console.Write((char)GPR[regC]);
						break;
					// 11 Input
					case "1011":
						//Console.Out.WriteLine("Input");
						break;
					// 12 Load Program
					case "1100":
						//Console.Out.WriteLine("Load Program " + GPR[regB] + " " + GPR[regC] );
						if (!GPR[regB].Equals(0))
						{
							arrayCollection[0] =  arrayCollection[(int)GPR[regB]].GetRange(0,arrayCollection[(int)GPR[regB]].Count);
						}
						iFinger = (int)GPR[regC] - 1;
						break;
					// 13 Orthography
					case "1101":
						//Console.Out.WriteLine("Orthography");
						A13 = bin2Dec(bits.Substring(4, 3));
						val13 = bin2Dec(bits.Substring(7, 25));
						GPR[A13] = val13;
						////Console.Out.WriteLine(A13 + " " + val13);
						break;
				}

				iFinger++;

				if (iFinger > arrayCollection[0].Count)
				{
					//System.out.println("Stoped unexpected EOF");
					break;
				}

			}
		}

		private static uint bin2Dec(String bin)
		{
			//uint dec = 0;
			//int j = 0;
			//for (int i = bin.Length; i > 0; i--)
			//{
			//	if (bin.Substring(i - 1, 1).Equals("1"))
			//	{
			//		dec = dec + (uint)Math.Pow(2, j);
			//	}
			//	j++;
			//}

			//return dec;
			return Convert.ToUInt32(bin, 2);
		}

		public static long byteAsULong(byte b)
		{
			return ((long)b) & 0x00000000000000FFL;
		}
	}
}
