
ItemsManager = {}

ItemsManager.__index = ItemsManager

local IMAGES_DIR = 'images/'
local timer = require "timer"
local Bomb = require "bomb"
require "consts"
PATHS = {
	bomb=IMAGES_DIR .. 'bomb.png'
}

function ItemsManager.new()	-- constructor
	local self = {}
	setmetatable( self, ItemsManager )
	-- self.itemsDispGroup = display.newGroup( )
	return self
end

function ItemsManager:newBomb( x, y )
	local newBomb = Bomb.create({pos = {x= x, y= y}})
	timer.performWithDelay(EXPLOSION_DELAY, function (  )
		newBomb:explode()			
	end)
	-- self.itemsDispGroup:insert(newBomb)
end

function ItemsManager:destroy(  )
	-- self.itemsDispGroup:removeSelf( )
end

return {
	ItemsManager=ItemsManager
}