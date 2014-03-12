require( "consts" )

local CameraAwareSprite = {}

local utils = require("lib.ecusson.Utils")
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
	self.name = options.spriteSet
	Super.super(self, options)
	camera:addListener(self)

	self:setWorldPosition(options.worldPosition)
	return self
end

function CameraAwareSprite:redraw( zoomChange )
	local newPos = camera:worldToScreen(self.worldPosition)
	Super.setPosition(self, newPos)
end

function CameraAwareSprite:destroy( options )
	camera:removeListener(self)
	Super.destroy(self, options)
end

function CameraAwareSprite:setPosition( position )
	self.worldPosition = camera:screenToWorld(position)
	if (self:getDisplayObject() ~= nil) then
		self:redraw()
	end
end

function CameraAwareSprite:setWorldPosition( position )
	self.worldPosition = position
	if (self:getDisplayObject() ~= nil) then
		self:redraw()
	end
end

return CameraAwareSprite