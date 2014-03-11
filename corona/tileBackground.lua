require "vector2D"

TileBackground = {}

function TileBackground:new(luaTiles)
  local self = {}
  local tiles = {}

  local mapTL = Vector2D.fromJSON(luaTiles[NETW_INIT_GRID_BOUNDS_SMTLP])
  local mapBR = Vector2D.fromJSON(luaTiles[NETW_INIT_GRID_BOUNDS_SMBRP])
  local tilesTL = Vector2D.fromJSON(luaTiles[NETW_INIT_GRID_BOUNDS_TTLP])
  local tilesBR = Vector2D.fromJSON(luaTiles[NETW_INIT_GRID_BOUNDS_TBRP])

  dbg(Y,{"mapTL",mapTL})
  dbg(Y,{"mapBR",mapBR})
  dbg(Y,{"tilesTL",tilesTL})
  dbg(Y,{"tilesBR",tilesBR})

  for i,list in ipairs(luaTiles[TYPEGRID]) do
  	for j,url in ipairs(list) do
  		tiles[i][j] = Tile:new(url)
      dbg(Y,{"new tile"})
  	end
  end

  camera:addListener(self)

  setmetatable(self, { __index = TileBackground })  -- Inheritance
end



function TileBackground:redraw()
	for i,list in ipairs(tiles) do
  	for j,tile in ipairs(list) do
  		if tile.image then  -- already loaded
  			-- TODO redraw
  		end
  	end
  end
end

function TileBackground:destroy()
end