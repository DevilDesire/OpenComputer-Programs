local robot = require("robot")
local computer = require("computer")
print("System wird initialisiert")

local fieldsX = 4
local fieldsZ = 4
local waitTime = 30 -- seconds
local invSize = robot.inventorySize()

--os.sleep(10)
local function UseAndSuck()
  robot.useDown()
  robot.suck()
end

local function GoForward()
  while true do
    local success = robot.forward()
    if success then
      break
    end
  end
end

local function GoUp()
  while true do
    local success = robot.up()
    if success then
      break
    end
  end
end

local function GoDown()
  while true do
    local success = robot.down()
    if success then
      break
    end
  end
end

local function TurnLeft()
	robot.turnLeft()
end

local function TurnRight()
	robot.turnRight()
end

local function MatrixLineForward()
	local i = 1
	while i < fieldsX do
		GoForward()
		UseAndSuck()
		i = i+1
	end
end

local function MatrixNextLine(i)
	if i % 2 == 0 then
		TurnRight()
		GoForward()
		TurnRight()
	else
		TurnLeft()
		GoForward()
		TurnLeft()
	end
end
		

local function MatrixLines()
	local i = 1
	while i <= fieldsZ do
		MatrixLineForward()
		
		if i < fieldsZ then
			MatrixNextLine(i)
		end
		
		i = i+1
	end
end

local function ReturnAndEmptyCargo()
	if fieldsZ % 2 == 0 then
		GoForward()
	else
		TurnLeft()
		TurnLeft()
		
		for fieldX = 1, fieldsX do
			GoForward()
		end
	end
	
	TurnLeft()	
	
	for fieldZ = 1, fieldsZ -1 do
		GoForward()
	end
	
	TurnLeft()
	GoDown()
	
	for selectedSlot = 2, invSize do
	  robot.select(selectedSlot)
	  robot.dropDown()
	end
	robot.select(1)
end

local function ChargeUpAndWait()
	os.sleep(waitTime)
end

local function RunMatrix()
	while true do
		GoUp()
		GoForward()
		UseAndSuck()
		MatrixLines()
		ReturnAndEmptyCargo()
		ChargeUpAndWait()
	end
end
	
RunMatrix()