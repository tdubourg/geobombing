require "vector2D"
require "tile"

TileBackground = {}

function TileBackground:new(luaTiles)
  local self = {}
  self.tiles = {}

  local mapTL = v2FromJSON(luaTiles[NETW_INIT_GRID_BOUNDS_SMTLP])
  local mapBR = v2FromJSON(luaTiles[NETW_INIT_GRID_BOUNDS_SMBRP])
  local tilesTL = v2FromJSON(luaTiles[NETW_INIT_GRID_BOUNDS_TTLP])
  local tilesBR = v2FromJSON(luaTiles[NETW_INIT_GRID_BOUNDS_TBRP])

  dbg(Y,{"mapTL",mapTL})
  dbg(Y,{"mapBR",mapBR})
  dbg(Y,{"tilesTL",tilesTL})
  dbg(Y,{"tilesBR",tilesBR})

  for i,list in ipairs(luaTiles[TYPEGRID]) do
  	self.tiles[i] = {}
  	for j,url in ipairs(list) do
  		self.tiles[i][j] = Tile:new(url)
      dbg(Y,{"new tile"})
  	end
  end

  camera:addListener(self)

  setmetatable(self, { __index = TileBackground })  -- Inheritance
end



function TileBackground:redraw()
	for i,list in ipairs(self.tiles) do
  	for j,tile in ipairs(list) do
  		if tile.image then  -- already loaded
  			-- TODO redraw
  		end
  	end
  end
end

function TileBackground:destroy()
end