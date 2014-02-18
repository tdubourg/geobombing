require "camera"

Arc = {}                   -- Create a table to hold the class methods
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

-- NOT TESTED
-- function Arc:computePosition(nodeFrom, progress)

--   if nodeFrom == end1 then
--   print "1"
--     return Vector2D:Lerp(end1.pos, end2.pos, progress)
--   elseif nodeFrom == end2 then
--     print "2"
--     return Vector2D:Lerp(end2.pos, end1.pos, progress)
--   else
--     print "3"
--     return nil
--   end
-- end
