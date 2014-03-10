Tile = {}
function Tile:new()
  local self = {}
  setmetatable(self, { __index = Tile })  -- Inheritance
  --display.loadRemoteImage( "http://www.coronalabs.com/demo/hello.png", "GET", loadComplete, "helloCopy.png", system.TemporaryDirectory, 50, 50 )
end

function Tile:loadComplete()
  print "complete"
end