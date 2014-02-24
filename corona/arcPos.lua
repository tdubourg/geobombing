ArcPos = {}                   -- Create a table to hold the class methods
function ArcPos:new(arc, progress)  -- The constructor
  local self = {arc=arc, progress=progress}
  self.posXY = nil
  
  setmetatable(self, { __index = ArcPos })  -- Inheritance
  return self
end

function ArcPos:getPosXY()
  if not self.posXY then
    self.posXY = Vector2D:Lerp(self.arc.end1.pos, self.arc.end2.pos, self.progress)
  end
  return self.posXY
end

