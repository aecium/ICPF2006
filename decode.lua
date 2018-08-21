local debugOut = true

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

arrayColection[1] = {}

function dec2Bin(dec,bc)
  if dec == 0 then return Z8 end
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
  print('')
  fHandle = assert(io.open(tFileName,'rb'))

  local current = fHandle:seek()      -- get current position
  local size = fHandle:seek("end")    -- get file size
  fHandle:seek("set", current)        -- restore position

  local allBits = {}
  for i = 1, (size/32) do
    local b32 = {}
    --for b8 = 1, 4 do 
    fContent = fHandle:read(1)
    b32[1] = dec2Bin(string.byte(fContent))--:reverse()
    fContent = fHandle:read(1)
    b32[2] = dec2Bin(string.byte(fContent))--:reverse()
    fContent = fHandle:read(1)
    b32[3] = dec2Bin(string.byte(fContent))--:reverse()
    fContent = fHandle:read(1)
    b32[4] = dec2Bin(string.byte(fContent))--:reverse()
    --end
    allBits[i] = table.concat(b32)--:reverse()
  end

  arrayColection[1] = allBits
  a = 1
end


loadUM(arg[1])

local opCode = 0
local addressA = 0
local addressB = 0
local addressC = 0

while true do
  cur32bit = arrayColection[1][iFinger]
  opCode = cur32bit:sub(1,4)
  addressA = cur32bit:sub(24,26)
  addressB = cur32bit:sub(27,29)
  addressC = cur32bit:sub(30,32)

  -- 0 Conditional Move
  if opCode == '0000' then
    if debugOut then print("Conditional Move") end
  end
  -- 1 Array Index
  if opCode == '0001' then
    if debugOut then print("Array Index") end
  end

  -- 2 Array Amendment
  if opCode == '0010' then
    if debugOut then print("Array Amendment") end
  end

  --3 Addition
  if opCode == '0011' then
    if debugOut then print("Addition") end
  end

  --4 Multiplication
  if opCode == '0100' then
    if debugOut then print("Multiplication") end
  end

  --5 Division
  if opCode == '0101' then
    if debugOut then print("Division") end
  end

  --6 Not-And
  if opCode == '0110' then
    if debugOut then print("Not-And") end
  end

  --7 Halt
  if opCode == '0111' then
    if debugOut then print("Halt") end
  end

  --8 Allocation
  if opCode == '1000' then
    if debugOut then print("Allocation") end
  end

  --9 Abandonment
  if opCode == '1001' then
    if debugOut then print("Abandonment") end
  end

  --10 Output
  if opCode == '1010' then
    if debugOut then print("Output") end
  end

  --11 Input
  if opCode == '1011' then
    if debugOut then print("Input") end
  end

  --12 Load Program
  if opCode == '1100' then
    if debugOut then print("Load Program") end
  end

  --13 Orthography
  if opCode == '1101' then
    if debugOut then print("13 Orthography") end
  end

  print('iFinger:' .. iFinger)
  print('Curent Line:' .. cur32bit)
  print('Dec:' .. bin2Dec(cur32bit))
  print('opCode:' .. opCode)
  print('addressA:' .. addressA)
  print('addressB:' .. addressB)
  print('addressC:' .. addressC)
  print('')
  
  iFinger = iFinger + 1

  if arrayColection[1] == nil then 
    break 
  end

  if iFinger > #arrayColection[1] then 
    break
  end

end

