require "vector2D"
require "arc"
require "camera"

Node = {}                   -- Create a table to hold the class methods
function Node:new(worldX, worldY, uid)  -- The constructor
  
  local self = {uid=uid}
  self.pos = Vector2D:new(worldX, worldY)    -- linearized position 0..1 (world)
  self.arcs = {}                                   -- K: destination node, V: corresponding arc

  self.drawable = display.newGroup( )

  display.newCircle(self.drawable, self.pos.x, self.pos.y, 7 )
  local text = display.newText(self.drawable, uid, self.pos.x, self.pos.y, native.systemFont, 16 )
  text:setFillColor( 0, 0, 1 )

  camera:addListener(self)

  -- if nodesByUID[uid] ~= nil then
  -- 	print ("WARNING: node uid: ".. uid .." is not unique!")
  -- end
  -- nodesByUID[uid] = self;

  setmetatable(self, { __index = Node })  -- Inheritance
  return self
end

-- part of the contract with Camera
function Node:redraw()
  local newPos = camera:worldToScreen(self.pos)
  self.drawable.x = newPos.x
  self.drawable.y = newPos.y
end

-- creates an Arc if necessary and link everything
function Node:linkTo(node1)
	if self.arcs[node1] == nil then
		local newArc = Arc:new(self, node1)
		self.arcs[node1] = newArc
		node1.arcs[self] = newArc
    return newArc
  end
end

-- WORK IN PROGRESS
function Node:transmitExplosion(origin, power, posList, interval)
  for node,arc in pairs(arcs) do
    local dist = self.pos:dist(node.pos)
    local transmitedPower = power*self:transmitionCoef(origin, node)
    if transmitedPower > dist then
      -- add points on whole arc
      node:transmitExplosion(transmitedPower - dist)
    else
      -- add points on partial arc
    end
  end
end

function Node:transmitionCoef(fromNode, toNode)
  local v1 = (Vector2D:Sub(self.pos, fromNode)):normalize()
  local v2 = (Vector2D:Sub(toNode, self.pos)):normalize()

  local dot = v1:dot(v2)
  return (dot+1)*0.5    -- 0..1
end

function Node:destroy()
  camera:removeListener(self)
  if self.drawable then
    self.drawable:removeSelf()
    self.drawable = nil
  end
end
