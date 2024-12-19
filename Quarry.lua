-- https://pastebin.com/q7vNcwv3
-- pastebin get q7vNcwv3

fuelItems = {"coal", "charcoal", "lava_bucket", "oak_log"} -- items that turtle will use as fuel


X, Y, Z = 0, 0, 0 -- turtle location
Direction = 0 -- direction turtle is facing

local depth, width, length = 100, 10, 10

local function isInventoryFull()
  for i = 1, 16, 1 do -- 4 by 4
    if turtle.getItemCount(i) == 0 then
      print("slot ", i, " is empty")
      return 0
    end
  end
  print("inventory is full")
  return 1
end

local function tryDig()
  if isInventoryFull() then
    print("inventory full")
  end

  turtle.dig()
end

local function tryForward()
  while true do -- try till you cant
  
    if turtle.forward() then -- if yes
      if Direction == 0 then
        Y = Y + 1
      elseif Direction == 1 then
        X = X + 1
      elseif Direction == 2 then
        Y = Y - 1
      elseif Direction == 3 then
        X = X - 1
      end
      return 1
    end

    print("cant move, mining")
    turtle.refuel()
    turtle.dig() -- remove what is in the way
  end
end

local function tryUp()
  while true do
    if turtle.up() then
      return 1
    end
    turtle.refuel()
  end
end

local function tryDown()
  while true do
    if turtle.down() then
      Z = Z - 1
      return 1
    end
    print("Z !down")
  end
end

local function tryTurnRight()
  while true do -- not sure how this can fail but might as well
    if turtle.turnRight() then 
      Direction = Direction + 1
    end
    if Direction > 3 then
      Direction = Direction - 4
    end
    return 1

  end
end

local function moveToOrigin()

  if Y > 0 then -- turn to Y direction
    while Direction ~= 2 do
      tryTurnRight()
    end  
  elseif Y < 0 then
    while Direction ~= 0 do
      tryTurnRight()
    end
  end

  while Y ~= 0 do -- move Y
    tryForward()
  end


  if X > 0 then -- turn to X direction
    while Direction ~= 3 do
      tryTurnRight()
    end
  elseif X < 0 then
    while Direction ~= 1 do
      tryTurnRight()
    end
  end

  while X ~= 0 do -- move X
    tryForward()
  end
  
end

local function moveToLocation(x, y, z)

  while Z > z do
    tryDown()
  end

  while Z < z do
    tryUp()
  end

  if X > x then -- turn to X direction
    while Direction ~= 3 do
      tryTurnRight()
    end
  elseif X < x then
    while Direction ~= 1 do
      tryTurnRight()
    end
  end

  while X ~= x do -- move X
    tryForward()
  end



  if Y < y then -- turn to Y direction
    while Direction ~= 0 do
      tryTurnRight()
    end  
  elseif Y > y then
    while Direction ~= 2 do
      tryTurnRight()
    end
  end

  while Y ~= y do -- move Y
    tryForward()
  end
end

local function lookNorth()
  while Direction ~= 0 do
    tryTurnRight()
  end
end

local function digRect(width, length)
  local tempWidth, tempLength = width - 1, length - 1
  local tempIderator
  local headAssFlag = 0

  if width > length then
    tempIderator = width
  elseif width <= length then
    tempIderator = width
  end

  for i = 1, tempIderator, 1 do

    for i = 1, tempLength, 1 do
      tryDig()
      tryForward()
    end
    if headAssFlag == 1 then
      tempLength = tempLength - 1
    end
    headAssFlag = 1

    tryTurnRight()
    
    for i = 1, tempWidth, 1 do
      tryDig()
      tryForward()
    end
    tempWidth = tempWidth - 1

    tryTurnRight()

  end

end

local function deay() -- delays a little bit of time by doing a 360
  for i = 1, 4, 1 do
    turtle.turnRight()
  end
end

local function isFuel(slot)
  item = turtle.getItemDetail(slot)

  for i = 1, #fuelItems, 1 do
    if item == fuelItems[i] then
      return 1
    end
  end
  return 0

end

local function findFuel() -- finds fuel in inventory
  for i = 1, 16, 1 do
    if isFuel(i) then
      return i
    end
  return 0
  end
end



turtle.refuel()


-- quarry code
for i = 1, depth, 1 do
  digRect(length, width)
  moveToLocation(0, 1, 0)
  lookNorth()
  turtle.digDown()
  turtle.down()
end


