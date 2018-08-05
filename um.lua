local debugOut = false

if arg[#arg] == '-debug' then
  debugOut = true
end



local Z32 = '00000000000000000000000000000000'
local Z8 = '00000000'
-- general-purpose 32 bit registers
local GPR = {['000']=Z32,['001']=Z32,['010']=Z32,['011']=Z32,['100']=Z32,['101']=Z32,['110']=Z32,['111']=Z32}

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
    allBits[i] = table.concat(b32)
  end

  arrayColection[0] = allBits
  print("Program size:" .. #arrayColection[0])
  a = 1
end


loadUM(arg[1])

local opCode = 0
local addressA = 0
local addressB = 0
local addressC = 0

while true do
  cur32bit = arrayColection[0][iFinger]
  opCode = cur32bit:sub(1,4)
  addressA = cur32bit:sub(24,26)
  addressB = cur32bit:sub(27,29)
  addressC = cur32bit:sub(30,32)



  -- 0 Conditional Move
  if opCode == '0000' then
    if debugOut then print("Conditional Move") end
    if GPR[addressC] ~= Z32 then
      GPR[addressA] = GPR[addressB]
    end
    a = 1
  end

  -- 1 Array Index
  if opCode == '0001' then
    if debugOut then print("Array Index") end
    GPR[addressA] = arrayColection[bin2Dec(GPR[addressB])][bin2Dec(GPR[addressC])+1]
    a = 1
  end

  -- 2 Array Amendment
  if opCode == '0010' then
    if debugOut then print("Array Amendment") end
    arrayColection[bin2Dec(GPR[addressA])][bin2Dec(GPR[addressB])+1] = GPR[addressC]
  end

  --3 Addition
  if opCode == '0011' then
    if debugOut then print("Addition") end
    dec = bin2Dec(GPR[addressB]) + bin2Dec(GPR[addressC])
    GPR[addressA] = dec2Bin((dec - math.floor(dec/2^32)*(2^32)),32) 
    a = 1
  end

  --4 Multiplication
  if opCode == '0100' then
    if debugOut then print("Multiplication") end
    dec = bin2Dec(GPR[addressB]) * bin2Dec(GPR[addressC])
    GPR[addressA] = dec2Bin((dec - math.floor(dec/2^32)*(2^32)),32) 
    a = 1
  end

  --5 Division
  if opCode == '0101' then
    if debugOut then print("Division") end
    if bin2Dec(GPR[addressC]) == 0 then 
      break
    end
    dec = bin2Dec(GPR[addressB]) / bin2Dec(GPR[addressC])
    if dec < 1 then
      dec = 0
    end

    GPR[addressA] = dec2Bin(dec,32)

    a = 1
  end

  --6 Not-And
  if opCode == '0110' then
    if debugOut then print("Not-And") end
    local holdBits = ''
    for i = 1, 32 do
      if GPR[addressB]:sub(i,i) == '0' or GPR[addressC]:sub(i,i) == '0' then
        holdBits = holdBits .. '1'
      else
        holdBits = holdBits .. '0'
      end
    end
    GPR[addressA] = holdBits
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
    j = bin2Dec(GPR[addressC])
    GPR[addressB] = dec2Bin(#arrayColection+1,32)
    arrayColection[#arrayColection+1] = {}
    for i = 1, j do
      arrayColection[#arrayColection][i]=Z32
    end
    a = 1
  end

  --9 Abandonment
  if opCode == '1001' then
    if debugOut then print("Abandonment") end
    arrayColection[bin2Dec(GPR[addressC])] = {}
  end

  --10 Output
  if opCode == '1010' then
    --   if debugOut then print("Output") end
    io.write(string.char(bin2Dec(GPR[addressC])))
  end

  --11 Input
  if opCode == '1011' then
    if debugOut then print("Input") end
    mChar = io.read(1)
    GPR[addressC] = dec2Bin(string.byte(mChar),32)
  end

  --12 Load Program
  if opCode == '1100' then
    if debugOut then print("Load Program " .. bin2Dec(GPR[addressB]) .. " " .. bin2Dec(GPR[addressC])) end
    arrayColection[0] = arrayColection[bin2Dec(GPR[addressB])]
    iFinger = bin2Dec(GPR[addressC])
  end

  --13 Orthography
  if opCode == '1101' then
    if debugOut then print("13 Orthography") end
    A13 = cur32bit:sub(5,7)
    val13 = cur32bit:sub(8,32)
    val13 = zPad(val13,32,true)
    GPR[A13] = val13
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

