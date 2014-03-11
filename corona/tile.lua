require "utils"

local tempFileIndex = 0

Tile = {}
function Tile:new(url)
  local self = {}
  self.url = url
  self.image = nil

  local loadCompleteListener = 
    function(event)
      if ( event.isError ) then
            print ("Failed loading tile "..self.url)
      else
        self.image = event.target
        event.target.anchorX = 0
        event.target.anchorY = 0
        tileLayer:insert(self.image)
      end
    end

  display.loadRemoteImage( self.url , "GET", loadCompleteListener, "tempTile"..tempFileIndex..".png", system.TemporaryDirectory, 0, 0 )
  tempFileIndex = tempFileIndex +1
  setmetatable(self, { __index = Tile })  -- Inheritance
  return self
end


function Tile:destroy()
  camera:removeListener(self)
end