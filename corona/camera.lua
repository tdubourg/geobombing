-- listener contract:
-- self.redraw() -> method that handles redrawing the object (ie. moving DrawObjets or modifying them)
-- The Camera should be queried for conversion from world to screen, and scale if necessary.

require "vector2D"
require "print_r"

camera = nil  -- global / singleton

Camera = {}                   -- Create a table to hold the class methods
function Camera:new()  -- The constructor
	local self = {}
	self.listeners = {}    -- set of managed selfs, in keys
	self.cameraPos = Vector2D:new(0,0)
	self.zoomXY = Vector2D:new(1,1)
	self.invZoomXY = Vector2D:new(1,1)

	setmetatable(self, { __index = Camera })  -- Inheritance
	return self
end

function Camera:lookAtXY(wX, wY)
	self:lookAt(Vector2D:new(wX,wY))
end

function Camera:lookAt(v2WorldPos)
	if self.cameraPos:distSquared(v2WorldPos) ~= 0 then     -- checks if an update is necessary
		self.cameraPos = v2WorldPos
		self:updateManaged()
	end
end

function Camera:setZoomXY(zoomX, zoomY)
	self.zoomXY.x = zoomX
	self.invZoomXY.x = 1/zoomX

	if (zoomY) then -- if not specified, zoomY = zoomX
		self.zoomXY.y = zoomY
		self.invZoomXY.y = 1/zoomY
	else
		self.zoomXY.y = zoomX
		self.invZoomXY.y = 1/ zoomX
	end

	self:updateManaged()
end

function Camera:screenToWorld(v2Screen)
	return Vector2D:new(self:screenToWorldXY(v2Screen.x, v2Screen.y))
end

function Camera:worldToScreen(v2World)
	return Vector2D:new(self:worldToScreenXY(v2World.x, v2World.y))
end

function Camera:screenToWorldXY(sX, sY)
	local wX = ((sX- (display.contentWidth / 2))* self.invZoomXY.x + self.cameraPos.x ) 
	local wY = ((sY- (display.contentHeight / 2))* self.invZoomXY.y  + self.cameraPos.y )  
	return wX,wY
end

function Camera:worldToScreenXY(wX, wY)
	local sX = ((wX - self.cameraPos.x) * self.zoomXY.x) + (display.contentWidth / 2)
	local sY = ((wY - self.cameraPos.y) * self.zoomXY.y) + (display.contentHeight / 2)
	return sX,sY
end

function Camera:addListener(obj)
	self.listeners[obj] = true
end

function Camera:removeListener(obj)
	self.listeners[obj] = nil
end

function Camera:updateManaged()
	for obj,_ in pairs(self.listeners) do
		if (obj ~= nil) then
			obj:redraw()
		end
	end
end
