require "vector2D"
require "tile"

TileBackground = {}

function TileBackground:new(luaTiles)
  local self = {}
  self.tiles = {}

  for i,list in ipairs(luaTiles[TYPEGRID]) do
  	self.tiles[i] = {}
  	for j,url in ipairs(list) do
  		self.tiles[i][j] = Tile:new(url, self)
  	end
  end


  -- scale and placing handling
  local mapTL = v2FromJSON(luaTiles[NETW_INIT_GRID_BOUNDS_SMTLP])
  local mapBR = v2FromJSON(luaTiles[NETW_INIT_GRID_BOUNDS_SMBRP])
  local tilesTL = v2FromJSON(luaTiles[NETW_INIT_GRID_BOUNDS_TTLP])
  local tilesBR = v2FromJSON(luaTiles[NETW_INIT_GRID_BOUNDS_TBRP])

  self.scale = Vector2D:Sub(mapBR,mapTL)

  self.offset = Vector2D:Sub(tilesTL,mapTL)
  self.offset.x = self.offset.x / self.scale.x
  self.offset.y = self.offset.y / self.scale.y

  self.tileSize = Vector2D:Sub(tilesBR,tilesTL)
  self.tileSize.x = self.tileSize.x  / (#(self.tiles[1]) * self.scale.x)
  self.tileSize.y = self.tileSize.y  / (#(self.tiles) * self.scale.y)

  camera:addListener(self)
  setmetatable(self, { __index = TileBackground })  -- Inheritance

end


function TileBackground:redraw(zoomChange)
  local screenWidth = self.tileSize.x * camera.zoomXY.x
  local screenHeight = self.tileSize.y * camera.zoomXY.y
	for i,list in ipairs(self.tiles) do
  	for j,tile in ipairs(list) do
  		if tile.image then  -- already loaded
        local wX = self.offset.x + (j-1)*self.tileSize.x
        local wY = self.offset.y + (i-1)*self.tileSize.y
  			tile.image.x, tile.image.y = camera:worldToScreenXY(wX, wY)
        if zoomChange then
          tile:setScreenSize(screenWidth, screenHeight)
        end
  		end
  	end
  end
end

function TileBackground:destroy()
end