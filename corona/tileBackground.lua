TileBackground = {}

function TileBackground:new(luaMap)
  local self = {}
  local tiles = {}

  

  setmetatable(self, { __index = TileBackground })  -- Inheritance
end