-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

local storyboard = require "storyboard"
displayMainGroup = display.newGroup( )
net = require "network"
loc = require "location"
print( loc )
-- load scenetemplate.lua
storyboard.gotoScene( "menu" )

loc.enable_location()
-- Add any objects that should appear on all scenes below (e.g. tab bar, hud, etc.):

-- Add a score label
--local scoreLabel = display.newText( 42, 50, 60, native.systemFontBold, 120 )
--scoreLabel:setTextColor( 0, 255, 0 )
