
ItemsManager = {}

ItemsManager.__index = ItemsManager

local IMAGES_DIR = 'images/'
local timer = require "timer"
local Bomb = require "bomb"
local ArcPos = require ("arcPos")
require "utils"
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

function ItemsManager:bombUpdate( bomb_data )
	dbg(BOMB_DBG_MODE, {"Inside bombUpdate with bomb_data=", bomb_data})
	local bomb_id = tostring( bomb_data[NETWORK_BOMB_UPDATE_ID_KEY] )
	local bdata = {
		  state = bomb_data[NETWORK_BOMB_UPDATE_STATE_KEY]
		, arcPos = ArcPos.createFromNetworkPosObj(currentMap, bomb_data[NETWORK_BOMB_UPDATE_POS_KEY])
		, type = bomb_data[NETWORK_BOMB_UPDATE_TYPE_KEY]
		, power = bomb_data[NETWORK_BOMB_UPDATE_POWER_KEY]
	}
	local bomb = self.bombs[bomb_id]
	if (bomb == nil) then
		dbg(BOMB_DBG_MODE, {"Bomb not found in already created ones, creating a new one"})
		bomb = Bomb.create(bdata)
		self.bombs[bomb_id] = bomb
	else
		bomb:update(bdata)
	end

	if (bomb.state == 0) then -- BOOM
		dbg(BOMB_DBG_MODE, {"Explosion on bomb", bomb.id})
		bomb:explode()
	end
end

function ItemsManager:destroy(  )
	-- self.itemsDispGroup:removeSelf( )
end

return {
	ItemsManager=ItemsManager
}