require( "consts" )

local Bomb = {}

local utils = require("lib.ecusson.Utils")
local vec2 = require("lib.ecusson.math.vec2")
local CameraAwareSprite = require("camera_aware_sprite")
local Sound = require("lib.ecusson.Sound")

-----------------------------------------------------------------------------------------
-- Bomb attributes
-----------------------------------------------------------------------------------------

local transitionDuration = 1.0

-----------------------------------------------------------------------------------------
-- Initialization and Destruction
-----------------------------------------------------------------------------------------

-- Create the environment
function Bomb.create(options)
	local self = utils.extend(Bomb)

	-- Initialize attributes
	-- self.spawnPoint = options.spawnPoint
	self.state = options.state
	self.time = 0
	self.alive = true
	self.arcPos = options.arcPos
	self.id = options.id
	self.type = options.type
	self.power = options.power

	self.sprite = CameraAwareSprite.create {
		spriteSet = "bomb",
		animation = "idle",
		worldPosition = options.arcPos:getPosXY(),
		position = camera:worldToScreen(options.arcPos:getPosXY()),
		-- rotation = self.spawnPoint.rotation
	}

	-- Sound.create("dog_spawn")

	self.sprite:addEventListener("touch", self)
	self.sprite:addEventListener("ecussonSprite", self)
	Runtime:addEventListener("ecussonEnterFrame", self)

	return self
end

-- Destroy the level
function Bomb:destroy()
	Runtime:removeEventListener("ecussonEnterFrame", self)
	self.sprite:removeEventListener("ecussonSprite", self)
	self.sprite:removeEventListener("touch", self)

	self.sprite:destroy()

	for _,explosionSprite in ipairs(self.expSprites) do
		explosionSprite:destroy()
	end

	utils.deleteObject(self)
end

-----------------------------------------------------------------------------------------
-- Methods
-----------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------
-- Event listeners
-----------------------------------------------------------------------------------------

-- Enter frame handler
function Bomb:ecussonEnterFrame(options)
	self.time = self.time + options.dt

	-- self.sprite:setPosition(utils.interpolateLinear{
	-- 	from = self.spawnPoint.from,
	-- 	to = self.spawnPoint.to,
	-- 	delta = math.min(self.time / transitionDuration, 1.0)
	-- })
end

function Bomb:explode(options)
	local explosionPoints = self.arcPos:initExplosion(self.power)

	self.expSprites = {}
	for _,ap in ipairs(explosionPoints) do
		local newSprite = CameraAwareSprite.create {
												spriteSet = "bomb",
												animation = "explode",
												worldPosition = ap:getPosXY(),
												rotation = math.random( ) * 360
													}
		self.expSprites[#self.expSprites+1] = newSprite
	end

	self.sprite:play("explode")
	timer.performWithDelay(EXPLOSION_PERIOD*1000, function ( ) -- converting from seconds to ms, 8 frames
		self:destroy()
	end)
end

function Bomb:update( bdata )
	self.state = bdata.state
	self.type = bdata
	self:setArcPos(bdata.arcPos)
end

function Bomb:setArcPos( arcPos )
	self.arcPos = arcPos
	self.sprite:setWorldPosition(arcPos:getPosXY())
end

function Bomb:touch(event)
	-- if self.state == "alive" then
	-- 	self.state = "dying"

		-- self.sprite:play("dead")

		-- Sound.create("dog_death")

	-- 	Runtime:dispatchEvent{
	-- 		name = "increaseScore",
	-- 		value = 10
	-- 	}
	-- end
end

-- Sprite event handler
function Bomb:ecussonSprite(event)
	-- Destroy object if the dying animation has ended
	if event.state == "ended" then
		self:destroy()
	end
end

-----------------------------------------------------------------------------------------

return Bomb