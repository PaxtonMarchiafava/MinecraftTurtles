
------ start of function block. keep these together. they are a family
fuelItems = {"stick", "coal", "charcoal", "lava_bucket", "birch_log"} -- items that turtle will use as fuel (in order?)

X, Y, Z = 0, 0, 0 -- turtle location
Direction = 0 -- direction turtle is facing


-- rando shit

local function printTable(table)
  print(textutils.serialize(table))
end

local function longTimer(mins)
  for i = 1, mins - 1, 1 do
    sleep(60)
    print(mins - i, " minutes remaining")
  end

  sleep(30)

  print("0.5 minutes remaining")
  sleep(20)
  print("10 seconds remaining")

end

-- inventory functions

local function getItemName(slot)
  if turtle.getItemCount(slot) > 0 then
    return string.sub( turtle.getItemDetail(slot)["name"], string.find(turtle.getItemDetail(slot)["name"], ":") + 1)
  else
    return ""
  end
end

local function selectItem(item) -- returns slot that item was in
  for i = 1, 16, 1 do
    if getItemName(i) == item then
      turtle.select(i)
      return i
    end
  end
  return 0
end

local function isInventoryFull()
  for i = 1, 16, 1 do -- 4 by 4
    if turtle.getItemCount(i) == 0 then
      return 0
    end
  end
  return 1
end

local function isFuel(slot)
  item = getItemName(slot)

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

local function howManyStacks(item)
  local counter = 0

  for i = 1, 16, 1 do
    if getItemName(i) == item then
      counter = counter + 1
    end
  end

  return counter
end

-- movment functions

local function dynamicRefuel() -- refuel with priority
  local material = "null"

  for i = 1, #fuelItems, 1 do
    if selectItem(fuelItems[i]) > 0 then
      turtle.refuel(1)
      print("refueled using ", fuelItems[i])
      return 1
    end
  end

  print("can't refuel")
  return 0

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

local function tryTurnLeft()
  tryTurnRight()
  tryTurnRight()
  tryTurnRight()
end

local function face(direction)
  while Direction ~= direction do
    tryTurnRight()
  end
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

    turtle.dig() -- remove what is in the way
    
    if turtle.getFuelLevel() < 1 then
      dynamicRefuel()
    end
    
    
  end
end

local function tryUp() -- needs error handling
  while true do
    if turtle.up() then
      Z = Z + 1
      return 1
    end
    turtle.digUp()
    dynamicRefuel()
  end
end

local function tryDown()
  local failed = 0
  while true do
    if turtle.down() then
      Z = Z - 1
      return 1
    end

    if turtle.getFuelLevel() < 1 then
      dynamicRefuel()
    end

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

local function turnAround()
  tryTurnRight()
  tryTurnRight()
end

-- build functions

local function tryPlaceDown(item)
  
  while not selectItem(item) do
    print("need more ", item)
    sleep(5)
  end

  turtle.placeDown()

end

local function buildRect(width, length, item)
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
      tryPlaceDown(item)
      tryForward()
    end
    if headAssFlag == 1 then
      tempLength = tempLength - 1
    end
    headAssFlag = 1

    tryTurnRight()
    
    for i = 1, tempWidth, 1 do
      placeDown(item)
      tryForward()
    end
    tempWidth = tempWidth - 1

    tryTurnRight()

  end

end

local function leavePackage()
  local keep = 0

  tryPlaceDown("chest")

  for i = 1, 16, 1 do -- for all items

    if isFuel(i) > 0 then
      keep = 1
    end

    for j = 1, #ThingsToKeep, 1 do
      if ThingsToKeep[j] == getItemName(i) then
        keep = 2
      end
    end

    if keep == 0 then
      turtle.select(i)
      turtle.dropDown()
    end
    keep = 0

  end
end

-- dig functions

local function tryDig()
  if isInventoryFull() > 0 then
    print("inventory full")
  end

  turtle.dig()
end

local function tryDigDown()
  if isInventoryFull() > 0 then
    print("inventory full")
  end

  turtle.digDown()
end

local function tryDigUp()
  if isInventoryFull() > 0 then
    print("inventory full")
  end

  turtle.digUp()
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

local function cutTree() -- cut down tree that is in front of turt
  turtle.dig()
  tryForward()
  turtle.digDown()
  
  selectItem("birch_log")

  while turtle.compareUp() == true do -- get the whole tree
    turtle.digUp()
    tryUp()
  end

  moveToLocation(X, Y, 0)
end

-- look at world

local function getItemUnder() -- returns item under turtle
  if turtle.inspectDown() ~= "nil" then
    return string.sub(turtle.inspectDown()["name"], string.find(turtle.inspectDown()["name"], ":") + 1)
  else
    return ""
  end
end

local function getItemOver()
  local temp, temp2 = turtle.inspectUp()
  print(temp)
  print(temp2)

  if temp then
    return string.sub(temp2["name"], string.find(temp2["name"], ":") + 1)
  else
    return ""
  end
end

-- other worlds interactions

local function bigSuck() -- no loads refused
  turtle.suck()
  turtle.suckDown()
  turtle.suckUp()
end

local function massiveSuck()
  local currentDirection = Direction
  bigSuck()
  tryTurnRight()
  bigSuck()
  tryTurnRight()
  bigSuck()
  tryTurnRight()
  bigSuck()
  tryTurnRight()

  face(currentDirection) -- should already face this way but might as well make sure

end

-- farm functions

local function plantGrowth() -- returns growth value
  local shitter, pisser = turtle.inspectDown()
  
  if shitter then
    return pisser["state"]["age"]
  end
  return -1
end

local function harvestSingle()
  selectItem("wheat_seeds")
  turtle.digDown()
  tryPlaceDown("wheat_seeds")
  turtle.suckDown()
end

local function harvest(x, y)
  local cuck = 0
  
  tryForward() -- get off the chest
  while cuck < x do
    
    for i = 1, y, 1 do
      
      if i > 1 then
        tryForward()
      end

      if plantGrowth() < 7 or plantGrowth() > 5 then
        selectItem("bone_meal")
        turtle.placeDown()
      end
      
      if plantGrowth() == 7 then
        harvestSingle()
      end
    end
    
    if cuck % 2 == 1 then
      tryTurnLeft()
      tryForward()
      tryTurnLeft()
      
    else
      tryTurnRight()
      tryForward()
      tryTurnRight()
    end
    cuck = cuck + 1
  end
end

local function compost()
  face(3)

  moveToLocation(-1, 0 , 1)

  while howManyStacks("wheat_seeds") > 2 do
    selectItem("wheat_seeds")
    turtle.dropDown()
  end
end

---------------- end of function block


while true do
  -- sleep(1)
  
  if isInventoryFull() < 1 then
    tryDig()
    
  else
    turnAround()
    for i = 1, 16, 1 do
      selectItem("cobblestone")
      turtle.drop()
    end
    turnAround()
  end

end