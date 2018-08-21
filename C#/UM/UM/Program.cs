using System;
using System.Collections.Generic;
using System.IO;

namespace UM
{
	class MainClass
	{
		static uint[] GPR = { 0, 0, 0, 0, 0, 0, 0, 0 };

		static byte[] tBytes = null;
		static String path;
		static List<List<uint>> arrayCollection = new List<List<uint>>();
		static int iFinger = 0;

		static uint bits;
		static uint opCode;
		static uint regA;
		static uint regB;
		static uint regC;
		static uint A13;
		static uint val13;
		static Boolean run = true;
		static int arrayColectionSize = 0;
		static char[] inputChar;
		static String inputString = "";


		public static void Main(string[] args)
		{


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
				long value = byteAsULong(tBytes[i + 3]) | (byteAsULong(tBytes[i + 2]) << 8)
					| (byteAsULong(tBytes[i + 1]) << 16) | (byteAsULong(tBytes[i]) << 24);
				arrayCollection[0].Add((uint)value);
			}

			Console.WriteLine("Program size: " + arrayCollection[0].Count);

			while (run)
			{
				bits = arrayCollection[0][iFinger];
				opCode = bits >> 28;
				regA = (bits << 23) >> 29;
				regB = (bits << 26) >> 29;
				regC = (bits << 29) >> 29;

				switch (opCode)
				{
					// 0 Conditional Move
					case 0:
						conditionalMove();
						break;
					// 1 Array Index
					case 1:
						arrayIndex();
						break;
					// 2 Array Amendment
					case 2:
						amendment();
						break;
					// 3 Addition
					case 3:
						addition();
						break;
					// 4 Multiplication
					case 4:
						multiplication();
						break;
					// 5 Division
					case 5:
						division();
						break;
					// 6 Not And
					case 6:
						notAnd();
						break;
					// 7 Halt
					case 7:
						//Console.Out.WriteLine("Halt");
						run = false;
						break;
					// 8 Allocation
					case 8:
						allocation();
						break;
					// 9 Abandonment
					case 9:
						//Console.Out.WriteLine("Abandonment");
						abandonment();
						break;
					// 10 Output 
					case 10:
						output();
						break;
					// 11 Input
					case 11:
						input();
						break;
					// 12 Load Program
					case 12:
						loadProgram();
						break;
					// 13 Orthography
					case 13:
						orthopraphy();
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

		private static void input()
		{

			GPR[regC] = Console.ReadKey().KeyChar;
			//if (inputString == "")
			//{
			//	inputString = Console.ReadLine();
			//	//inputString = inputString + (char)13;
			//}
			//else
			//{

			//	inputChar = inputString.Substring(0, 1).ToCharArray();
			//	inputString = inputString.Substring(1,inputString.Length-1);
			//	String endChar = inputString.Substring(inputString.Length - 1, 1); 
			//	if (inputChar[0] == '@')
			//	{
			//		GPR[regC] = 4294967295;
			//		inputString = "";
			//	}
			//	else
			//	{
			//		GPR[regC] = (uint)inputChar[0];
			//	}
			//}

		}

		private static void output()
		{
			Console.Write((char)GPR[regC]);
		}

		private static void conditionalMove()
		{
			//Console.Out.WriteLine("Conditional Move");
			if (GPR[regC] != 0)
			{
				GPR[regA] = GPR[regB];
			}
		}

		private static void arrayIndex()
		{
			//Console.Out.WriteLine("Array Index");
			GPR[regA] = arrayCollection[(int)GPR[regB]][(int)GPR[regC]];
		}

		private static void amendment()
		{
			//Console.Out.WriteLine("Array Amendment");
			arrayCollection[(int)GPR[regA]][(int)GPR[regB]] = GPR[regC];
		}

		private static void addition()
		{
			//Console.Out.WriteLine("Addition");
			GPR[regA] = (uint)((GPR[regB] + GPR[regC]) % (long)Math.Pow(2, 32));
		}

		private static void multiplication()
		{
			//Console.Out.WriteLine("Multiplication");
			GPR[regA] = GPR[regA] = (uint)((GPR[regB] * GPR[regC]) % (long)Math.Pow(2, 32));
		}

		private static void division()
		{
			//Console.Out.WriteLine("Division");
			GPR[regA] = (uint)Math.Floor((double)(GPR[regB] / GPR[regC]));
		}

		private static void notAnd()
		{
			//Console.Out.WriteLine("Not And");
			GPR[regA] = ~(GPR[regB] & GPR[regC]);
		}

		private static void abandonment()
		{
			arrayCollection[(int)GPR[regC]] = null;
			//arrayColectionSize--;
		}

		private static void allocation()
		{
			//Console.Out.WriteLine("Allocation");
			arrayCollection.Add(new List<uint>());
			arrayColectionSize++; //arrayCollection.Count - 1;
			for (int i = 1; i <= GPR[regC]; i++)
			{
				arrayCollection[arrayColectionSize].Add(0);
			}
			GPR[regB] = (uint)arrayColectionSize;
		}

		private static void loadProgram()
		{
			//Console.Out.WriteLine("Load Program " + GPR[regB] + " " + GPR[regC] );
			if (!GPR[regB].Equals(0))
			{
				arrayCollection[0] = arrayCollection[(int)GPR[regB]].GetRange(0, arrayCollection[(int)GPR[regB]].Count);
			}
			iFinger = (int)GPR[regC] - 1;
		}

		private static void orthopraphy()
		{
			//Console.Out.WriteLine("Orthography");
			A13 =  (bits << 4) >> 29;
			val13 =  (bits << 7) >> 7;
			GPR[A13] = val13;
			////Console.Out.WriteLine(A13 + " " + val13);
		}
              
		private static long byteAsULong(byte b)
		{
			return ((long)b) & 0x00000000000000FFL;
		}
	}
}
