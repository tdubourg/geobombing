require "camera"

Arc = {}                   -- Create a table to hold the class methods

-- do not call this method, use Map:createArcPos() or Map:createArcPosByUID()
function Arc:new(end1, end2)  -- The constructor
  local self = {end1=end1, end2=end2}
  self.len = end1.pos:dist(end2.pos)
  self.pos = Vector2D:new((end1.pos.x + end2.pos.x)/2,(end1.pos.y + end2.pos.y)/2)

  --TODO : display groupS

  self.drawable = display.newLine(end1.pos.x, end1.pos.y, end2.pos.x, end2.pos.y )
  self.drawable.strokeWidth = 2
  self.drawable:setStrokeColor( 255, 255, 255 )

  camera:addListener(self)

  setmetatable(self, { __index = Arc })  -- Inheritance
  return self
end

-- part of the contract with Camera
function Arc:redraw()
  local newPos1 = camera:worldToScreen(self.end1.pos)
  local newPos2 = camera:worldToScreen(self.end2.pos)
  self.drawable:removeSelf()
  self.drawable = display.newLine(newPos1.x, newPos1.y, newPos2.x, newPos2.y )
  self.drawable.strokeWidth = 2
  self.drawable:setStrokeColor( 255, 255, 255 )
end


function Arc:destroy()
  camera:removeListener(self)
  if self.drawable then
    self.drawable:removeSelf()
    self.drawable = nil
  end
end