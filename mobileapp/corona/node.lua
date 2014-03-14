require "vector2D"
require "arc"
require "camera"
require "math"

Node = {}                   -- Create a table to hold the class methods
function Node:new(worldX, worldY, uid, map)  -- The constructor
	
	local self = {uid=uid, map=map}
	self.pos = Vector2D:new(worldX, worldY)    -- linearized position 0..1 (world)
	self.arcs = {}                                   -- K: destination node, V: corresponding arc

	if DISPLAY_MAP_NODES then
		self.drawable = display.newGroup()
		map.mapGroup:insert(self.drawable)

		local circle =display.newCircle(self.drawable, self.pos.x, self.pos.y, 7 )
		circle:setFillColor( 1, 0, 0 )
		camera:addListener(self)
	end
	setmetatable(self, { __index = Node })  -- Inheritance
	return self
end

-- part of the contract with Camera
function Node:redraw(zoomChange)
	local newPos = camera:worldToScreen(self.pos)
	self.drawable.x = newPos.x
	self.drawable.y = newPos.y
end

-- creates an Arc if necessary and link everything
-- @param node1{Node}: The node to link to
-- @return {Arc} the created arc, if necessary, or nil, if no arc was created
function Node:linkTo(node1, wayName)
	if self.arcs[node1] == nil then
		local newArc = Arc:new(self, node1, wayName, self.map)
		self.arcs[node1] = newArc
		node1.arcs[self] = newArc
		return newArc
	end
end


-- recursive call to transmit an explosion through the map
-- origin : calling node, used for angle computation and transmition coef
-- power : transmited power
-- distanceInterval : distance between returned positions (distance, not ratio!)
-- resultList : array of ArcPos containing the resulting positions where to draw explosion sprites
function Node:transmitExplosion(origin, power, distanceInterval, resultArray, forceTransmit)
	for otherNode,arc in pairs(self.arcs) do
		if otherNode ~= origin then 
			local transmitedPower = nil
			if forceTransmit then
				transmitedPower = power
			else
				transmitedPower = power*self:transmitionCoef(origin, otherNode)
			end

			local APfrom = self.map:createArcPos(self, otherNode, 0.0)
			local APto = nil
			if transmitedPower > arc.len then     -- add points on whole arc and transmit
				APto = self.map:createArcPos(self, otherNode, 1.0)
				otherNode:transmitExplosion(self, transmitedPower - arc.len, distanceInterval, resultArray)
			else                               -- add points on partial arc
				APto = self.map:createArcPos(self, otherNode, transmitedPower/arc.len)
			end

			local newPositions = ArcPos.PosListBetween(APfrom, APto, distanceInterval)
			array_insert(resultArray, newPositions)
		end
	end
end

function Node:transmitionCoef(fromNode, toNode)
	local v1 = Vector2D:Sub(self.pos, fromNode.pos)
	local v2 = Vector2D:Sub(toNode.pos, self.pos)
	v1:normalize()
	v2:normalize()

	local dot = v1:dot(v2)

	-- return (dot+1)*0.5         -- [-v1..v1] => [0..1]

	-- dot = math.max( dot, 0 )		-- [0..90] => [0..1]
	-- return dot

	if dot> SPREAD_ANGLE_TOLLERANCE then                 -- tout ou rien
		return 1
	else
		return 0
	end
end

function Node:destroy()
	camera:removeListener(self)
	if self.drawable then
		self.drawable:removeSelf()
		self.drawable = nil
	end
end
