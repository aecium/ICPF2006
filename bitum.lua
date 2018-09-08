local debugOut = false

if arg[#arg] == '-debug' then
  debugOut = true
end

local Z32 = '00000000000000000000000000000000'
local Z8 = '00000000'
-- general-purpose 32 bit registers
local GPR = {[0]=0,[1]=0,[2]=0,[3]=0,[4]=0,[5]=0,[6]=0,[7]=0}

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

    fContent = fHandle:read(1)
    b32[1] =  dec2Bin(string.byte(fContent))
    fContent = fHandle:read(1)
    b32[2] = dec2Bin(string.byte(fContent))
    fContent = fHandle:read(1)
    b32[3] = dec2Bin(string.byte(fContent))
    fContent = fHandle:read(1)
    b32[4] = dec2Bin(string.byte(fContent))

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

while true do
  cur32bit = arrayColection[0][iFinger]
  opCode = bit32.extract(cur32bit,28,4)
  addressA = bit32.extract(cur32bit,6,3)
  addressB = bit32.extract(cur32bit,3,3)
  addressC = bit32.extract(cur32bit,0,3)

  -- 0 Conditional Move
  if opCode == 0 then
    if GPR[addressC] ~= 0 then
      GPR[addressA] = GPR[addressB]
    end
  end

  -- 1 Array Index
  if opCode == 1 then
    GPR[addressA] = arrayColection[GPR[addressB]][GPR[addressC]+1]
  end

-- 2 Array Amendment
  if opCode == 2 then
    arrayColection[GPR[addressA]][GPR[addressB]+1] = GPR[addressC]
  end

--3 Addition
  if opCode == 3 then
    dec = GPR[addressB] + GPR[addressC]
    GPR[addressA] = dec - math.floor(dec/2^32)*(2^32)
  end

--4 Multiplication
  if opCode == 4 then
    dec = GPR[addressB] * GPR[addressC]
    GPR[addressA] = dec - math.floor(dec/2^32)*(2^32) 
  end

--5 Division
  if opCode == 5 then
    dec = math.floor(GPR[addressB] / GPR[addressC])
    if dec < 1 then
      dec = 0
    end

    GPR[addressA] = dec
  end

--6 Not-And
  if opCode == 6 then
    GPR[addressA] = bit32.bnot(bit32.band(GPR[addressB],GPR[addressC]))
  end

--7 Halt
  if opCode == 7 then
    print("Halt")
    print("iFinger:" .. iFinger)
    break
  end

--8 Allocation
  if opCode == 8 then
    arraySize = GPR[addressC]
    GPR[addressB] = #arrayColection+1
    arrayColection[#arrayColection+1] = {}
    for i = 1, arraySize do
      arrayColection[#arrayColection][i] = 0
    end
  end

--9 Abandonment
  if opCode == 9 then
    arrayColection[GPR[addressC]] = {}
  end

--10 Output
  if opCode == 10 then
    io.write(string.char(GPR[addressC]))
  end

--11 Input
  if opCode == 11 then
    mChar = io.read(1)
    GPR[addressC] = string.byte(mChar)
  end

--12 Load Program
  if opCode == 12 then
    if GPR[addressB] ~= 0 then
      holdArray = arrayColection[GPR[addressB]] 
      arrayColection[0] = {}
      for i = 1, #holdArray do
        arrayColection[0][i] = holdArray[i]
      end
    end
    iFinger = GPR[addressC]
    holdArray = nil
  end

--13 Orthography
  if opCode == 13 then
    A13 = bit32.extract(cur32bit,25,3)
    val13 = bit32.extract(cur32bit,0,25)
    GPR[A13] = val13
  end

  iFinger = iFinger + 1

end