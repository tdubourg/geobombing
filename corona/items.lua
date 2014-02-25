
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
	self.bombs = {}
	-- self.itemsDispGroup = display.newGroup( )
	return self
end

function ItemsManager:newBomb( bomb_data )

	local newBomb = Bomb.create(bomb_data)
	self.bombs[newBomb.id] = newBomb
	-- timer.performWithDelay(EXPLOSION_DELAY, function ()
	-- 	newBomb:explode()			
	-- end)
	-- self.itemsDispGroup:insert(newBomb)
end

function ItemsManager:destroy(  )
	-- self.itemsDispGroup:removeSelf( )
end

return {
	ItemsManager=ItemsManager
}