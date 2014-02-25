
require "Vector2D"
require "print_r"

local MAP_WIDTH_ON_SCREEN = 2
local MAP_HEIGHT_ON_SCREEN = 2
cameraGroup = nil

local centerOffset = nil
local cameraPos = nil


local function initCamera()
	cameraGroup = display.newGroup()
	displayMainGroup:insert(cameraGroup)
	--cameraGroup.anchorX = 0.5
	--cameraGroup.anchorY = 0.5

	w = display.contentWidth
	h = display.contentHeight
	centerOffset = Vector2D:new(w/2, h/2)

	lookAt(Vector2D:new(0,0))
end

function lookAt(v2WorldPos)
	cameraPos = Vector2D:Sub(centerOffset, v2WorldPos)
	cameraGroup.x = cameraPos.x
	cameraGroup.y = cameraPos.y
end


function screenToWorld(v2Pos)
	return Vector2D:Sub(v2Pos, cameraPos)
end

function worldToScreen(v2Pos)
	return Vector2D:Add(v2Pos, cameraPos)
end

local exitCamera = function (  )
		cameraGroup:removeSelf( )
end

return {
	initCamera = initCamera,
	exitCamera = exitCamera
}
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