require "camera"

Arc = {}                   -- Create a table to hold the class methods

function Arc:new(end1, end2, streetName, map)
	local self = {end1=end1, end2=end2, streetName=streetName, map=map}
	self.len = end1.pos:dist(end2.pos)
	-- self.pos = Vector2D:new((end1.pos.x + end2.pos.x)/2,(end1.pos.y + end2.pos.y)/2)


	if DISPLAY_MAP_ARCS or DISPLAY_PATH then
		-- self.drawable = display.newLine(end1.pos.x, end1.pos.y, end2.pos.x, end2.pos.y )
		-- self.drawable.strokeWidth = 7
		-- self.drawable:setStrokeColor(200, 200, 200)
		-- map.mapGroup:insert(self.drawable)
		camera:addListener(self)
	end

	setmetatable(self, { __index = Arc })  -- Inheritance
	return self
end

-- part of the contract with Camera
function Arc:redraw(zoomChange)

	if DISPLAY_MAP_ARCS then
		if self.dbgArc then self.dbgArc:removeSelf() end
		local newPos1 = camera:worldToScreen(self.end1.pos)
		local newPos2 = camera:worldToScreen(self.end2.pos)
		self.dbgArc = display.newLine(newPos1.x, newPos1.y, newPos2.x, newPos2.y )
		self.dbgArc.strokeWidth = 4
		self.dbgArc.alpha= 1
		self.dbgArc:setStrokeColor(0, 255, 0)
		self.map.mapGroup:insert(self.dbgArc)
		self.dbgArc.x = newPos1.x --(newPos1.x + newPos2.x)/2
		self.dbgArc.y = newPos1.y--(newPos1.y + newPos2.y)/2
	end

	if zoomChange or not self.drawable then
		if self.drawable then self.drawable:removeSelf() end
		if (arcs[self] ~=nil) then
			if (arcs[self][1] ~= nil and arcs[self][2] ~=nil) then
				local newPos1 = camera:worldToScreen(arcs[self][1])
				local newPos2 = camera:worldToScreen(arcs[self][2])
				self.drawable = display.newLine(newPos1.x, newPos1.y, newPos2.x, newPos2.y )
				self.drawable.strokeWidth = 4
				self.drawable.alpha= 0.5
				self.drawable:setStrokeColor(0, 0, 200)
				self.map.mapGroup:insert(self.drawable)
			else
				dbg(GAME_DBG,{"arcs1",arcs[self][1] })
				dbg(GAME_DBG,{"arcs2",arcs[self][2] })
			end
		end
	else
		if (arcs[self] ~=nil and arcs[self][1] ~= nil and arcs[self][2] ~=nil) then
			local newPos1 = camera:worldToScreen(arcs[self][1])
			local newPos2 = camera:worldToScreen(arcs[self][2])
			self.drawable.x = newPos1.x --(newPos1.x + newPos2.x)/2
			self.drawable.y = newPos1.y--(newPos1.y + newPos2.y)/2
		else
			if self.drawable then
				self.drawable:removeSelf()
				self.drawable= nil
			end
		end
	end
end


function Arc:destroy()
	camera:removeListener(self)
	if self.drawable then
		self.drawable:removeSelf()
		self.drawable = nil
	end
end