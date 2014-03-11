TileBackground = {}

function TileBackground:new(luaTileURLs)
  local self = {}
  local tiles = {}

  for i,list in ipairs(luaTileURLs[TYPEGRID]) do
  	for j,url in ipairs(list) do
  		tiles[i][j] = Tile:new(url)
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