
if arg[#arg] == "-debug" then require("mobdebug").start() end

local Z32 = '00000000000000000000000000000000'
local Z8 = '00000000'
-- general-purpose 32 bit registers
local GPR = {['000']={},['001']={},['010']={},['011']={},['100']={},['101']={},['110']={},['111']={}}
for i = 1, 8 do
  GPR[i] = Z32
end

-- arrays for program and data storage
local AP = {}

-- instruction finger
iFinger = 0

AP[1] = {}

function dec2Bin(dec)
  if dec == 0 then return Z8 end
  local bin = ''
  while true do
    bin = bin .. dec - math.floor(dec/2)*2
    dec = math.floor(dec / 2)
    if dec == 0 then break end
  end
  while #bin < 8 do
    bin = bin .. '0'
  end

  return bin
end

function loadUM(mFileName)
  tFileName = mFileName or "um/sandmark.umz"
  print('Loading ' .. tFileName)
  fHandle = assert(io.open(tFileName,'rb'))

  local current = fHandle:seek()      -- get current position
  local size = fHandle:seek("end")    -- get file size
  fHandle:seek("set", current)        -- restore position

  local allBits = {}
  for i = 1, (size/32) do
    local b32 = {}
    for b8 = 1, 4 do 
      fContent = fHandle:read(1)
      b32[b8] = dec2Bin(string.byte(fContent))
    end
    allBits[i] = table.concat(b32)
  end

  AP[1] = allBits
  a = 1
end


loadUM(arg[1])

local run = true
local opCode = 0
local addressA = 0
local addressB = 0
local addressC = 0

while run do
  opCode = AP[1]:sub(1*iFinger,4)
  addressA = AP[1]:sub(23*iFinger,3)
  addressB = AP[1]:sub(26*iFinger,3)
  addressC = AP[1]:sub(39*iFinger,3)

  -- 0
  if opCode == '0000' then
    if GPR[addressC] ~= Z32 then
      GPR[addressA] = GPR[addressB]
    end
  end
  -- 1
  if opCode == '0001' then
    GPR[addressA] = AP[addressB]:sub(addressC,32)
  end

  -- 2
  if opCode == '0010' then
    AP[addressA][addressB] = addressC
  end

  --3
  if opCode == '0011' then

  end

  --4
  if opCode == '0100' then

  end

  --5 
  if opCode == '0101' then

  end

  --6
  if opCode == '0110' then
    local holdBits = ''
    for i = 1, 8 do
      if AP[addressB]:sub(i,i) == '1' or AP[addressC]:sub(i,i) == '1' then
        holdBits = holdBits .. '1'
      end
    end
    AP[addressA] = holdBits
  end

  --7
  if opCode == '0111' then
    run = false
    break
  end

  --8
  if opCode == '1000' then
    
  end

  --9
  if opCode == '1001' then

  end

  if opCode == '1010' then

    --10
  end

  --11
  if opCode == '1100' then

  end

  --12
  if opCode == '1101' then

  end

  --13
  if opCode == '1110' then

  end




end

