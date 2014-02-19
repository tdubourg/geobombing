require( "consts" )

local Bomb = {}

local utils = require("lib.ecusson.utils")
local vec2 = require("lib.ecusson.math.vec2")
local Sprite = require("lib.ecusson.Sprite")
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
	self.phase = "idle"
	self.time = 0.0
	self.alive = true

	self.sprite = Sprite.create {
		spriteSet = "bomb",
		animation = "idle",
		-- group = groups.animals,
		position = options.pos,
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
	self.sprite:play("explode")
	timer.performWithDelay(EXPLOSION_DURATION, function (  )
		self:destroy( )				
	end)
end

function Bomb:touch(event)
	-- if self.phase == "alive" then
	-- 	self.phase = "dying"

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
	if event.phase == "ended" then
		self:destroy()
	end
end

-----------------------------------------------------------------------------------------

return Bomb