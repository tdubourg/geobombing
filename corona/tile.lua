require "utils"

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
        dbg(Y,{"loaded ok"})
      end
    end

  display.loadRemoteImage( self.url , "GET", loadCompleteListener, "test.png", system.TemporaryDirectory, 0, 0 )
  camera:addListener(self)

  setmetatable(self, { __index = Tile })  -- Inheritance
end



function Tile:redraw()
	if self.image then
  	self.image.x, self.image.y = camera:worldToScreenXY(0,0)
  end
end

function Tile:destroy()
  camera:removeListener(self)
end