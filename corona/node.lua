require "vector2D"
require "arc"
require "camera"

Node = {}                   -- Create a table to hold the class methods
function Node:new(worldX, worldY, uid)  -- The constructor
  
  local object = {uid=uid}
  object.pos = Vector2D:new(worldX, worldY)    -- linearized position 0..1 (world)
  object.arcs = {}                                   -- K: destination node, V: corresponding arc

  object.drawable = display.newGroup( )
  display.newCircle(object.drawable, object.pos.x, object.pos.y, 10 )
  local text = display.newText(object.drawable, uid, object.pos.x, object.pos.y, native.systemFont, 16 )
  text:setFillColor( 0, 0, 1 )

  camera:addListener(object)

  -- if nodesByUID[uid] ~= nil then
  -- 	print ("WARNING: node uid: ".. uid .." is not unique!")
  -- end
  -- nodesByUID[uid] = object;

  setmetatable(object, { __index = Node })  -- Inheritance
  return object
end

-- part of the contract with Camera
function Node:redraw(camera)
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
	end
end
