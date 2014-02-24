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

function ArcPos:initExplosion(power)
  drawPosList = {}
  self.arc.end1:transmitExplosion(self.arc.end2, power-self.progress*self.arc.len, EXPLOSION_INTERVAL, drawPosList)
  self.arc.end2:transmitExplosion(self.arc.end1, power-(1-self.progress)*self.arc.len, EXPLOSION_INTERVAL, drawPosList)
  -- TODO draw sprites on drawPosList
  print "tranmit list len"
  print(#drawPosList)
end

-- generates a table filled with positions between arcPosFrom and arcPosTo.
-- distanceInterval is the spacing between added positions. (distance, not ratio!) 
function ArcPos.PosListBetween(arcPosFrom, arcPosTo, distanceInterval)
  if arcPosFrom.arc == arcPosTo.arc then               -- same arc check
    local commonArc = arcPosFrom.arc
    if arcPosFrom.progress < arcPosTo.progress then
      APsmall = arcPosFrom
      APbig = arcPosTo
    else
      APsmall = arcPosTo
      APbig = arcPosFrom
    end

    result = {}
    result[1] = APsmall

    ratio = APsmall.progress
    deltaRatio = distanceInterval/commonArc.len        -- ratio interval regarding arc length

    while ratio <= APbig.progress do
      result[#result+1] = ArcPos:new(commonArc, ratio)
      ratio = ratio + deltaRatio
    end
    result[#result+1] = APbig
    return result
  end
end