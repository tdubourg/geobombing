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

  -- caches
  local fillR = 78/255
  local fillG = 85/255
  local fillB = 128/255

  self.maskLeft = display.newRect( maskLayer, 100000, 100000, 100000, 100000 )
  self.maskLeft:setFillColor(fillR, fillG, fillB)
  self.maskLeft.anchorX = 1
  self.maskLeft.anchorY = 0.5

  self.rightMask = display.newRect( maskLayer, 100000, 100000, 100000, 100000 )
  self.rightMask:setFillColor(fillR, fillG, fillB)
  self.rightMask.anchorX = 0
  self.rightMask.anchorY = 0.5

  self.upMask = display.newRect( maskLayer, 100000, 100000, 100000, 100000 )
  self.upMask:setFillColor(fillR, fillG, fillB)
  self.upMask.anchorX = 0.5
  self.upMask.anchorY = 1

  self.downMask = display.newRect( maskLayer, 100000, 100000, 100000, 100000 )
  self.downMask:setFillColor(fillR, fillG, fillB)
  self.downMask.anchorX = 0.5
  self.downMask.anchorY = 0

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

  -- masks redraw
  self.maskLeft.x, self.maskLeft.y = camera:worldToScreenXY(0, 0.5)
  self.rightMask.x, self.rightMask.y = camera:worldToScreenXY(1, 0.5)
  self.upMask.x, self.upMask.y = camera:worldToScreenXY(0.5, 0)
  self.downMask.x, self.downMask.y = camera:worldToScreenXY(0.5, 1)
end

function TileBackground:destroy()
  for i,list in ipairs(self.tiles) do
    for j,tile in ipairs(list) do
      self.tiles[i][j]:destroy()
    end
  end
  camera:removeListener(self)
end