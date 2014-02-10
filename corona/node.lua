require "vector2D"
require "arc"
require "camera"

local nodesByUID = {}

Node = {}                   -- Create a table to hold the class methods
function Node:new(lat, lon, uid)  -- The constructor
  local object = {lat=lat, lon=lon, uid=uid}
  object.pos = Vector2D:new(gpsToLinear(lat,lon))    -- linearized position, used for game logic
  object.arcs = {}                                   -- K: destination node, V: corresponding arc
  object.drawable = display.newCircle( object.pos.x, object.pos.y, 16 )

  cameraGroup:insert(object.drawable)

  if nodesByUID[uid] ~= nil then
  	print ("WARNING: node uid: ".. uid .." is not unique!")
  end
  nodesByUID[uid] = object;

  setmetatable(object, { __index = Node })  -- Inheritance
  return object
end

function flushMap()
  --TODO!
end


-- creates an Arc if necessary and link everything
function Node:linkTo(node)
	if self.arcs[node] == nil then
		local newArc = Arc:new(self, node)
		self.arcs[node] = newArc
		node.arcs[self] = newArc
	end
end

function gpsToLinear(lat, lon)
	return lat, lon --TODO: spherical to linear transform
end