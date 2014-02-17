require "camera"

Arc = {}                   -- Create a table to hold the class methods
function Arc:new(end1, end2)  -- The constructor
  local object = {end1=end1, end2=end2}
  object.len = end1.pos:dist(end2.pos)

  --TODO : display groupS

  object.drawable = display.newLine(end1.pos.x, end1.pos.y, end2.pos.x, end2.pos.y )
  object.drawable.strokeWidth = 4
  object.drawable:setStrokeColor( 255, 0, 0 )

  cameraGroup:insert(object.drawable)

  setmetatable(object, { __index = Arc })  -- Inheritance
  return object
end
