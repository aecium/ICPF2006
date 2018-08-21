if arg[#arg] == "-debug" then require("mobdebug").start() end

local Z32 = '00000000000000000000000000000000'
local Z8 = '00000000'
-- general-purpose 32 bit registers
local GPR = {['000']=Z32,['001']=Z32,['010']=Z32,['011']=Z32,['100']=Z32,['101']=Z32,['110']=Z32,['111']=Z32}


-- arrays for program and data storage
local arrayColection = {}

-- instruction finger
local iFinger = 1

arrayColection[1] = {}

local fContent

function loadUM(mFileName)
  tFileName = mFileName or "um/sandmark.umz"
  print('Loading ' .. tFileName)
  fHandle = assert(io.open(tFileName,'rb'))
  
  --get file size
  local current = fHandle:seek()      -- get current position
  local size = fHandle:seek("end")    -- get file size
  fHandle:seek("set", current)        -- restore position


  local allBits = {}
  for i = 1, (size/32) do
    local b32 = {}
    fContent = ''
    for b8 = 1, 4 do 
      fContent = fContent .. string.format('%02x', fHandle:read(1):byte())
    end
    allBits[i] = fContent
  end

  arrayColection[1] = allBits
  a = 1
end


loadUM(arg[1])

local opCode = 0
local hexOp = 0
local addressA = 0
local addressB = 0
local addressC = 0

while true do
  hexOp = arrayColection[1][iFinger]:sub(1,2)
  opCode = bit32.extract('0x' .. hexOp,0,7)
  
   -- 0 Conditional Move
  if opCode == '0000' then
    print("Conditional Move")
    
  end
  -- 1 Array Index
  if opCode == '0001' then
    print("Array Index")
    
  end

  -- 2 Array Amendment
  if opCode == '0010' then
    print("Array Amendment")
    
  end

  --3 Addition
  if opCode == '0011' then
    print("Addition")
    
  end

  --4 Multiplication
  if opCode == '0100' then
    print("Multiplication")
    
  end

  --5 Division
  if opCode == '0101' then
    print("Division")
    
  end

  --6 Not-And
  if opCode == '0110' then
    print("Not-And")
    
  end

  --7 Halt
  if opCode == '0111' then
    print("Halt")
    break
  end

  --8 Allocation
  if opCode == '1000' then
    print("Allocation")
   
  end

  --9 Abandonment
  if opCode == '1001' then
    print("Abandonment")
    
  end

  --10 Output
  if opCode == '1010' then
    print("Output")
    
  end

  --11 Input
  if opCode == '1011' then
    print("Input")
   
  end

  --12 Load Program
  if opCode == '1100' then
    print("Load Program")
   
  end

  --13 Orthography
  if opCode == '1101' then
    print("13 Orthography")
  
  end
  
  iFinger = iFinger + 1
  
  if arrayColection[1] == nil then 
    print("Program plater nil")
    break 
  end
  
  if iFinger > #arrayColection[1] then 
    print("Finger past end")
    break 
  end
  
end
