local debugOut = false

if arg[#arg] == '-debug' then
  debugOut = true
end



local Z32 = '00000000000000000000000000000000'
local Z8 = '00000000'
-- general-purpose 32 bit registers
local GPR = {['000']=0,['001']=0,['010']=0,['011']=0,['100']=0,['101']=0,['110']=0,['111']=0}

-- arrays for program and data storage
local arrayColection = {}

-- instruction finger
local iFinger = 1

arrayColection[0] = {}

function dec2Bin(dec,bc)
  if dec == 0 and bc == nil then 
    return Z8 
  elseif dec == 0 and bc == 32 then
    return Z32
  end
  bitCount = bc or 8
  local bin = ''
  while true do
    bin = bin .. dec - math.floor(dec/2)*2
    dec = math.floor(dec / 2)
    if dec == 0 then break end
  end

  bin = zPad(bin,bitCount)

  return bin:reverse()
end

function zPad(bin,bc,rev)
  rev = rev or false
  bitCount = bc or 32
  while #bin < bitCount do
    if rev then
      bin = '0' .. bin
    else
      bin = bin .. '0'
    end
  end
  return bin
end

function bin2Dec(bin)
  if bin == nil then return 0 end
  if bin == Z32 then return 0 end
  local dec = 0
  local j = 0
  for i = #bin, 1, -1 do
    if bin:sub(i,i) == '1' then
      dec = dec + 2^(j)
    end
    j = j + 1
  end
  return dec
end

function loadUM(mFileName)
  tFileName = mFileName or "um/sandmark.umz"
  print('Loading ' .. tFileName)
  fHandle = assert(io.open(tFileName,'rb'))

  local current = fHandle:seek()      -- get current position
  local size = fHandle:seek("end")    -- get file size
  fHandle:seek("set", current)        -- restore position

  local allBits = {}
  for i = 1, (size/4) do
    local b32 = {}
    --for b8 = 1, 4 do 
    fContent = fHandle:read(1)
    b32[1] = dec2Bin(string.byte(fContent))
    fContent = fHandle:read(1)
    b32[2] = dec2Bin(string.byte(fContent))
    fContent = fHandle:read(1)
    b32[3] = dec2Bin(string.byte(fContent))
    fContent = fHandle:read(1)
    b32[4] = dec2Bin(string.byte(fContent))
    --end
    allBits[i] = bin2Dec(table.concat(b32))
  end

  arrayColection[0] = allBits
  print("Program size:" .. #arrayColection[0])
  a = 1
end


loadUM(arg[1])

local opCode
local addressA
local addressB
local addressC

local outputSpy =''

while true do
  cur32bit = dec2Bin(arrayColection[0][iFinger],32)
  opCode = cur32bit:sub(1,4)
  addressA = cur32bit:sub(24,26)
  addressB = cur32bit:sub(27,29)
  addressC = cur32bit:sub(30,32)



  -- 0 Conditional Move
  if opCode == '0000' then
    if debugOut then print("Conditional Move") end
    if GPR[addressC] ~= 0 then
      GPR[addressA] = GPR[addressB]
    end
    a = 1
  end

  -- 1 Array Index
  if opCode == '0001' then
    if debugOut then print("Array Index") end
    GPR[addressA] = arrayColection[GPR[addressB]][GPR[addressC]+1]
    if GPR[addressA] == nil then
      a =1
    end
    a = 1
  end

-- 2 Array Amendment
  if opCode == '0010' then
    if debugOut then print("Array Amendment") end
    arrayColection[GPR[addressA]][GPR[addressB]+1] = GPR[addressC]
  end

--3 Addition
  if opCode == '0011' then
    if debugOut then print("Addition") end
    dec = GPR[addressB] + GPR[addressC]
    GPR[addressA] = dec - math.floor(dec/2^32)*(2^32)
    a = 1
  end

--4 Multiplication
  if opCode == '0100' then
    if debugOut then print("Multiplication") end
    dec = GPR[addressB] * GPR[addressC]
    GPR[addressA] = dec - math.floor(dec/2^32)*(2^32) 
    a = 1
  end

--5 Division
  if opCode == '0101' then
    if debugOut then print("Division") end
    if GPR[addressC] == 0 then 
      print('div by 0')
      break
    end
    dec = math.floor(GPR[addressB] / GPR[addressC])
    if dec < 1 then
      dec = 0
    end

    GPR[addressA] = dec
    if dec == 1.25 then
      a = 1
    end
  end

--6 Not-And
  if opCode == '0110' then
    if debugOut then print("Not-And") end
    regB = dec2Bin(GPR[addressB],32)
    regC = dec2Bin(GPR[addressC],32)
    local holdBits = ''
    for i = 1, 32 do
      if regB:sub(i,i) == '0' or regC:sub(i,i) == '0' then
        holdBits = holdBits .. '1'
      else
        holdBits = holdBits .. '0'
      end
    end
    GPR[addressA] = bin2Dec(holdBits)
    a =1
  end

--7 Halt
  if opCode == '0111' then
    print("Halt")
    print("iFinger:" .. iFinger)
    break
  end

--8 Allocation
  if opCode == '1000' then
    if debugOut then print("Allocation") end
    arraySize = GPR[addressC]
    GPR[addressB] = #arrayColection+1
    arrayColection[#arrayColection+1] = {}
    for i = 1, arraySize do
      arrayColection[#arrayColection][i] = 0
    end
    a = 1
  end

--9 Abandonment
  if opCode == '1001' then
    if debugOut then print("Abandonment") end
    arrayColection[GPR[addressC]] = {'Abandoned'}
  end

--10 Output
  if opCode == '1010' then
    --   if debugOut then print("Output") end
    io.write(string.char(GPR[addressC]))
    outputSpy = outputSpy .. string.char(GPR[addressC])
    if outputSpy:sub(#outputSpy,#outputSpy) == '\n' then
      a = 1
    end
    if outputSpy:find('loadprog ok.') then
      a = 1
     -- debugOut = true
    end
  end

--11 Input
  if opCode == '1011' then
    if debugOut then print("Input") end
    mChar = io.read(1)
    if mChar:find('\n') then
      GPR[addressC] = 4294967295
    else
      GPR[addressC] = string.byte(mChar)
    end
  end

--12 Load Program
  if opCode == '1100' then
    if debugOut then print("Load Program " .. GPR[addressB] .. " " .. GPR[addressC]) end
    holdArray = arrayColection[GPR[addressB]]
    arrayColection[0] = table.pack(table.unpack(holdArray)) 

    --for i = 1, #holdArray do
    --   arrayColection[0][i] = holdArray[i]
    --end

    iFinger = GPR[addressC]
    holdArray = nil
  end

--13 Orthography
  if opCode == '1101' then
    --if debugOut then print("13 Orthography") end
    A13 = cur32bit:sub(5,7)
    val13 = cur32bit:sub(8,32)
    val13 = zPad(val13,32,true)
    GPR[A13] = bin2Dec(val13)
  end

  if GPR['000'] == nil or GPR['001'] == nil or GPR['010'] == nil or GPR['011'] == nil or GPR['100'] == nil or GPR['101'] == nil or GPR['110'] == nil or GPR['111'] == nil then
    a = 1
  end

  if arrayColection[0] == nil then
    a = 1
  end


  iFinger = iFinger + 1

  if arrayColection[0] == nil then 
    print("Program array is nil")
    break 
  end

  if iFinger > #arrayColection[0] then 
    print("Stoped unexpected EOF")
    break
  end

end

