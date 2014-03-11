-- listener contract:
-- self.redraw(zoomChange) -> method that handles redrawing the object (ie. moving DrawObjets or modifying them)
-- The Camera should be queried for conversion from world to screen, and scale if necessary.

require "vector2D"
require "print_r"


tileLayer = display.newGroup( )
roadLayer = display.newGroup( )
playerLayer = display.newGroup( )
explosionLayer = display.newGroup( )
guiLayer = display.newGroup( )

-- Z order
tileLayer:toFront( )
roadLayer:toFront( )
playerLayer:toFront( )
explosionLayer:toFront( )
guiLayer:toFront( )


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


-- not used
-- function Camera:setGPSConversion(v2MapOriginGps, v2MapScaleGps)
-- 	self.mapShift = v2MapOriginGps
-- 	self.mapScale = v2MapScaleGps
-- 	self:updateManaged()
-- end

function Camera:lookAtXY(wX, wY)
	self:lookAt(Vector2D:new(wX,wY))
end

function Camera:lookAt(v2WorldPos)
	if self.cameraPos:distSquared(v2WorldPos) ~= 0 then     -- checks if an update is necessary
		self.cameraPos = v2WorldPos
		self:updateManaged(false)
	end
end

function Camera:setZoomUniform(zoom)
	self.zoomXY.x = zoom
	self.zoomXY.y = self.zoomXY.x * (display.stageWidth/display.stageHeight)
	self.invZoomXY.x = 1/self.zoomXY.wX 
	self.invZoomXY.y = 1/self.zoomXY.y
	self:updateManaged(true)
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

	self:updateManaged(true)
end


-- wrappers
function Camera:screenToWorld(v2Screen)
	return Vector2D:new(self:screenToWorldXY(v2Screen.x, v2Screen.y))
end

function Camera:worldToScreen(v2World)
	return Vector2D:new(self:worldToScreenXY(v2World.x, v2World.y))
end

-- not used
-- function Camera:worldToGps(v2World)
-- 	return Vector2D:new(self:worldToGpsXY(v2World.x, v2World.y))
-- end

-- function Camera:worldToGps(v2Gps)
-- 	return Vector2D:new(self:worldToGpsXY(v2Gps.x, v2Gps.y))
-- end


-- space conversions
---------------------------------------------------------------------------------------
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

-- not used
-- function Camera:worldToGpsXY(wX, wY) -- crash? call setGPSConversion() first :p
-- 	local gX = self.mapShift.x + wX*self.mapScale.x
-- 	local gY = self.mapShift.y + wX*self.mapScale.y
-- 	return gX,gY
-- end

-- function Camera:GpsToWorldXY(gX, gY) -- crash? call setGPSConversion() first :p
-- 	local wX = (gX-self.mapShift.x)/self.mapScale.x
-- 	local wY = (gY-self.mapShift.y)/self.mapScale.y
-- 	return wX,wY
-- end
---------------------------------------------------------------------------------------


function Camera:addListener(obj)
	self.listeners[obj] = true
end

function Camera:removeListener(obj)
	self.listeners[obj] = nil
end

function Camera:updateManaged(zoomChanged)
	for obj,_ in pairs(self.listeners) do
		if (obj ~= nil) then
			obj:redraw(zoomChanged)
		end
	end
end
