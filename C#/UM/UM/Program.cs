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
		static ConsoleKeyInfo inputKey;
		static char inputChar;
		static String inputString = "";
		static FileStream outFile;
		static uint outByte;
		static bool getMoreInput = true;
		static List<String> cmdHistory = new List<String>();
		static int cmdHistoryLocation = 0;
        

		public static void Main(string[] args)
		{
			cmdHistory.Add("");

			arrayCollection.Add(new List<uint>());
			if (args.Length < 1)
			{
				path = "../Release/umix.um";//"/home/aecium/workspace/ICFP2006/um/sandmark.umz";
			}
			else
			{
				path = args[0];
			}

			try
			{
				tBytes = File.ReadAllBytes(path);
				outFile = File.Open("output.txt", FileMode.Create);
			}
			catch (IOException e)
			{
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
						run = false;
						break;
					// 8 Allocation
					case 8:
						allocation();
						break;
					// 9 Abandonment
					case 9:
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

			}
		}
        
		private static void input()
		{
        
			while (getMoreInput)
			{
				inputKey = Console.ReadKey();
                          
				if (inputKey.Key == ConsoleKey.UpArrow || inputKey.Key == ConsoleKey.DownArrow)
				{
					if (inputKey.Key == ConsoleKey.UpArrow)
					{
						if (cmdHistoryLocation < cmdHistory.Count - 1)
						{
							cmdHistoryLocation++;
						}
					}
					else
					{
						cmdHistoryLocation--;
						if (cmdHistoryLocation < 0)
						{
							cmdHistoryLocation = 0;
						}
					}

					inputString = cmdHistory[cmdHistoryLocation];
					Console.SetCursorPosition(0, Console.BufferHeight-1);
					Console.Write("                                         ");
					Console.SetCursorPosition(0, Console.BufferHeight - 1);
					Console.Write("% "+ inputString);

				}
				else
				{
					if (inputKey.Key == ConsoleKey.Backspace && inputString.Length > 0 && Console.CursorLeft >= 2){
						inputString = inputString.Substring(0, inputString.Length - 1);
					} else if (inputKey.Key == ConsoleKey.Backspace) {
						Console.SetCursorPosition(2, Console.BufferHeight - 1);
					}

					if ((char)inputKey.KeyChar == '\n')
					{
						getMoreInput = false;
						cmdHistory.Insert(1,inputString);
					}
					if (!((char)inputKey.KeyChar == 0))
					{
						inputString = inputString + (char)inputKey.KeyChar;
					}
				}
			}
            
			if (!getMoreInput)
			{

				inputChar = inputString.Substring(0, 1).ToCharArray()[0];
				inputString = inputString.Substring(1, inputString.Length - 1);

				GPR[regC] = (uint)inputChar;
				if (inputChar == '\n')
				{
					getMoreInput = true;
				}

			}

		}


		private static void output()
		{
			outByte = (GPR[regC] << 24) >> 24;
			Console.Write((char)outByte);
			outFile.WriteByte((byte)outByte);
			;
		}

		private static void conditionalMove()
		{
			if (GPR[regC] != 0)
			{
				GPR[regA] = GPR[regB];
			}
		}

		private static void arrayIndex()
		{
			GPR[regA] = arrayCollection[(int)GPR[regB]][(int)GPR[regC]];
		}

		private static void amendment()
		{
			arrayCollection[(int)GPR[regA]][(int)GPR[regB]] = GPR[regC];
		}

		private static void addition()
		{
			GPR[regA] = (uint)((GPR[regB] + GPR[regC]) % (long)Math.Pow(2, 32));
		}

		private static void multiplication()
		{
			GPR[regA] = GPR[regA] = (uint)((GPR[regB] * GPR[regC]) % (long)Math.Pow(2, 32));
		}

		private static void division()
		{
			GPR[regA] = (uint)Math.Floor((double)(GPR[regB] / GPR[regC]));
		}

		private static void notAnd()
		{
			GPR[regA] = ~(GPR[regB] & GPR[regC]);
		}

		private static void abandonment()
		{
			arrayCollection[(int)GPR[regC]] = null;
		}

		private static void allocation()
		{
			arrayCollection.Add(new List<uint>());
			arrayColectionSize++;
			for (int i = 1; i <= GPR[regC]; i++)
			{
				arrayCollection[arrayColectionSize].Add(0);
			}
			GPR[regB] = (uint)arrayColectionSize;
		}

		private static void loadProgram()
		{
			if (!GPR[regB].Equals(0))
			{
				arrayCollection[0] = arrayCollection[(int)GPR[regB]].GetRange(0, arrayCollection[(int)GPR[regB]].Count);
			}
			iFinger = (int)GPR[regC] - 1;
		}

		private static void orthopraphy()
		{
			A13 = (bits << 4) >> 29;
			val13 = (bits << 7) >> 7;
			GPR[A13] = val13;
		}

		public static UInt32 ReverseBytes(UInt32 value)
		{
			return (value & 0x000000FFU) << 24 | (value & 0x0000FF00U) << 8 |
				(value & 0x00FF0000U) >> 8 | (value & 0xFF000000U) >> 24;
		}

		private static long byteAsULong(byte b)
		{
			return ((long)b) & 0x00000000000000FFL;
		}
	}
}
