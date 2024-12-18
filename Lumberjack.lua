

X, Y, Z = 0, 0, 0 -- turtle location
Direction = 0 -- direction turtle is facing

local Gridsize = 5
local indexes = 9
local treeDespawnTime = 480

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

local function face(direction)
  while Direction ~= direction do
    tryTurnRight()
  end
end

local function getItemName(slot)
  if turtle.getItemCount(slot) > 0 then
    return string.sub( turtle.getItemDetail(slot)["name"], string.find(turtle.getItemDetail(slot)["name"], ":") + 1)
  end
  return nil
end

local function selectItem(item)
  for i = 1, 16, 1 do
    if getItemName(i) == item then
      turtle.select(i)
      return 1
    end
  end
  return 0
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

local function dynamicRefuel() -- refuel with priority
  local material = "null"

  if selectItem("stick") then
    turtle.refuel()
    material = "stick"
  elseif selectItem("coal_block") then
    turtle.refuel()
    material = "coal_block"
  elseif selectItem("birch_log") then
    turtle.refuel()
    material = "birch_log"
  end

  print("refueled using ", material)

end

local function turnAround()
  tryTurnRight()
  tryTurnRight()
end

local function tryUp()
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

local function tryPlaceDown(item)
  
  while not selectItem(item) do
    print("need more ", item)
    sleep(5)
  end

  turtle.placeDown()

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

turtle.refuel()

while true do

  for k = 1, (2 * 2), 1 do -- go ONE WAY across

    for i = 1, indexes, 1 do
      selectItem("birch_log")

      if turtle.compare() then -- tree!
        cutTree()

        tryPlaceDown("birch_sapling")
        
        massiveSuck()

      else
        tryForward()
        tryPlaceDown("birch_sapling")
        massiveSuck()
      end

      for j = 1, Gridsize - 1, 1 do -- get to next tree
        tryForward()
        bigSuck()
      end

    end
    
    tryTurnRight()
    for i = 1, Gridsize, 1 do
      tryForward()
    end
    tryTurnRight()
  end


  tryDown()
  face(2) -- face backwards
  while howManyStacks("birch_log") > 1 do
    selectItem("birch_log")
    turtle.drop()
  end
  face(0)
  
  sleep(treeDespawnTime)
  tryUp()
end
