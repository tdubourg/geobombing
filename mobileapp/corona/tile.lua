require "utils"
require "consts"

local tempFileIndex = 0

Tile = {}
function Tile:new(url, tileBackground)
  local self = {}
  self.url = url
  self.tileBackground = tileBackground
  self.image = nil

  local loadCompleteListener = 
    function(event)
      if ( event.isError ) then
            dbg (ERRORS, "Failed loading tile "..self.url)
      else
        self.image = event.target
        event.target.anchorX = 0
        event.target.anchorY = 0
        tileLayer:insert(self.image)
        self.tileBackground:redraw(true)
      end
    end

  display.loadRemoteImage( self.url , "GET", loadCompleteListener, "tempTile"..tempFileIndex..".png", system.TemporaryDirectory, -10000, -10000 )
  tempFileIndex = tempFileIndex +1
  setmetatable(self, { __index = Tile })  -- Inheritance
  return self
end

function Tile:setScreenSize(width,height)
  if self.image then
    self.image.xScale = width/self.image.width
    self.image.yScale = height/self.image.height
  end
end

function Tile:destroy()
  if self.image then self.image:removeSelf( ) end
end