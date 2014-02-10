
require "Vector2D"
require "print_r"

cameraGroup = nil

local centerOffset = nil
local cameraPos = nil


function initCamera()
  cameraGroup = display.newGroup()
  --cameraGroup.anchorX = 0.5
  --cameraGroup.anchorY = 0.5

  w = display.contentWidth
  h = display.contentHeight
  centerOffset = Vector2D:new(w/2, h/2)

  lookAt(Vector2D:new(0,0))
end

function lookAt(v2Pos)
  cameraPos = Vector2D:Add(v2Pos, centerOffset)
  print_r(cameraPos)
  cameraGroup.x = cameraPos.x
  cameraGroup.y = cameraPos.y
end


function screenToWorld(v2Pos)
  return Vector2D:Sub(v2Pos, centerOffset)
end

function worldToScreen(v2Pos)
  return Vector2D:Add(v2Pos, centerOffset)
end

-- function Camera:new()  -- The constructor
--   local object = {}

--   setmetatable(object, { __index = Camera })  -- Inheritance
--   return object
-- end

-- function Camera:getSingleton()   -- Another member function
--   if instance==nil then
-- 	instance = Camera:new()
--   end
--   return instance
-- end