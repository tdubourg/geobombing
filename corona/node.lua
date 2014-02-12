require "vector2D"
require "arc"
require "camera"

Node = {}                   -- Create a table to hold the class methods
function Node:new(lat, lon, uid)  -- The constructor
  local object = {lat=lat, lon=lon, uid=uid}
  object.pos = Vector2D:new(gpsToLinear(lon,lat))    -- linearized position, used for game logic
  object.arcs = {}                                   -- K: destination node, V: corresponding arc

  object.drawable = display.newGroup( )
  display.newCircle(object.drawable, object.pos.x, object.pos.y, 10 )
  local text = display.newText(uid, object.pos.x, object.pos.y, native.systemFont, 16 )
  text:setFillColor( 0, 0, 1 )
  object.drawable:insert(text)


  cameraGroup:insert(object.drawable)

  -- if nodesByUID[uid] ~= nil then
  -- 	print ("WARNING: node uid: ".. uid .." is not unique!")
  -- end
  -- nodesByUID[uid] = object;

  setmetatable(object, { __index = Node })  -- Inheritance
  return object
end

function flushMap()
  -- TODO!
  -- destroy corona display objects (nodes, arcs)
  -- empty nodesByUID

end


-- creates an Arc if necessary and link everything
function Node:linkTo(node1)
	if self.arcs[node1] == nil then
		local newArc = Arc:new(self, node1)
		self.arcs[node1] = newArc
		node1.arcs[self] = newArc
	end
end

function gpsToLinear(lon, lat)
	return lon, lat --TODO: spherical to linear transform
end