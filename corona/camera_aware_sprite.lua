require( "consts" )

local CameraAwareSprite = {}

local utils = require("lib.ecusson.utils")
local vec2 = require("lib.ecusson.math.vec2")
require "camera"
local Sprite = require("lib.ecusson.Sprite")
local Sound = require("lib.ecusson.Sound")

local Super = Sprite
local CameraAwareSprite = utils.extend(Super)

-----------------------------------------------------------------------------------------
-- Initialization and Destruction
-----------------------------------------------------------------------------------------

-- Create the environment
function CameraAwareSprite.create(options)
	local self = utils.extend(CameraAwareSprite) -- just an instanciation
	self.worldPosition = options.worldPosition
	self.name = options.spriteSet
	-- print ("CameraAwareSprite.create", self.name, "self.worldPosition", self.worldPosition.x, self.worldPosition.y)
	Super.super(self, options)
	camera:addListener(self)
	return self
end

function CameraAwareSprite:redraw(  )
	--print ("CameraAwareSprite:redraw() of ", self.name)
	--print ("sprite world pos", self.worldPosition.x, self.worldPosition.y)
	local newPos = camera:worldToScreen(self.worldPosition)
	--print ("sprite newPos", newPos, newPos.x, newPos.y)
	Super.setPosition(self, newPos)
end

function CameraAwareSprite:destroy( options )
	camera:removeListener(self)
	Super.destroy(self, options)
end

function CameraAwareSprite:setPosition( position )
	-- print ("setPosition() of sprite", self.name, "is being executed with param position=", position.x, position.y)
	self.worldPosition = camera:screenToWorld(position)
	if (self:getDisplayObject() ~= nil) then
		self:redraw()
	end
end

function CameraAwareSprite:setWorldPosition( position )
	-- print ("setWorldPosition() of sprite", self.name, "is being executed with param position=", position.x, position.y)
	self.worldPosition = position
	if (self:getDisplayObject() ~= nil) then
		self:redraw()
	end
end

return CameraAwareSprite