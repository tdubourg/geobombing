require "camera"

Arc = {}                   -- Create a table to hold the class methods
function Arc:new(end1, end2)  -- The constructor
  local object = {end1=end1, end2=end2}
  object.len = end1.pos:dist(end2.pos)
  object.pos = Vector2D:new((end1.pos.x + end2.pos.x)/2,(end1.pos.y + end2.pos.y)/2)

  --TODO : display groupS

  object.drawable = display.newLine(end1.pos.x, end1.pos.y, end2.pos.x, end2.pos.y )
  object.drawable.strokeWidth = 2
  object.drawable:setStrokeColor( 255, 255, 255 )

  camera:addListener(object)

  setmetatable(object, { __index = Arc })  -- Inheritance
  return object
end

-- part of the contract with Camera
function Arc:redraw(camera)
  local newPos1 = camera:worldToScreen(self.end1.pos)
  local newPos2 = camera:worldToScreen(self.end2.pos)
  self.drawable:removeSelf()
  self.drawable = display.newLine(newPos1.x, newPos1.y, newPos2.x, newPos2.y )
  self.drawable.strokeWidth = 2
  self.drawable:setStrokeColor( 255, 255, 255 )
end
