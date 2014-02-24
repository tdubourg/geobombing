-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

local storyboard = require "storyboard"
displayMainGroup = display.newGroup( )
net = require "network2"
loc = require "location"
print( loc )


local Sound = require("lib.ecusson.Sound")
local Sprite = require("lib.ecusson.Sprite")
local PerformanceWidget = require("lib.ecusson.PerformanceWidget")

-----------------------------------------------------------------------------------------
-- Preload spritesheets
-----------------------------------------------------------------------------------------

Sprite.setup{
	imagePath = "runtimedata/sprites/",
	datapath = "runtimedata.sprites.",
	animationData = require("config.Sprites").sheets
}

Sprite.loadSheet("sprites")

-----------------------------------------------------------------------------------------
-- Setup sounds
-----------------------------------------------------------------------------------------

Sound.setup{
	soundsPath = "runtimedata/audio/",
	soundsData = require("config.Sounds")
}


-- load scenetemplate.lua
storyboard.gotoScene( "menu" )

loc.enable_location()
-- Add any objects that should appear on all scenes below (e.g. tab bar, hud, etc.):

-- Add a score label
--local scoreLabel = display.newText( 42, 50, 60, native.systemFontBold, 120 )
--scoreLabel:setTextColor( 0, 255, 0 )
