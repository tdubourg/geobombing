
ItemsManager = {}

ItemsManager.__index = ItemsManager

local IMAGES_DIR = 'images/'
local timer = require "timer"
require "constants"
PATHS = {
	bomb=IMAGES_DIR .. 'bomb.png'
}

function ItemsManager.new()	-- constructor
	local self = {}
	setmetatable( self, ItemsManager )
	self.itemsDispGroup = display.newGroup( )
	return self
end

function ItemsManager:newBomb( x, y )
	local newBomb = display.newImage( PATHS.bomb, x, y )
	cameraGroup:insert(self.itemsDispGroup)
	timer.performWithDelay(EXPLOSION_DELAY, function (  )
		newBomb:removeSelf( )				
	end)
	self.itemsDispGroup:insert(newBomb)
end

function ItemsManager:destroy(  )
	self.itemsDispGroup:removeSelf( )
end

return {
	ItemsManager=ItemsManager
}