----------------------------------------------------------------------------------
--
-- game.lua
--
----------------------------------------------------------------------------------

local storyboard = require( "storyboard" )
local player = require( "player" )
local network = require ("network")
local scene = storyboard.newScene()
require "node"
require "consts"
require "camera"
require "vector2D"
require "map"
local physics = require( "physics" )

----------------------------------------------------------------------------------
-- 
--	NOTE:
--	
--	Code outside of listener functions (below) will only be executed once,
--	unless storyboard.removeScene() is called.
-- 
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------



-- Called when the scene's view does not exist:
function scene:createScene( event )
	local group = self.view

	-----------------------------------------------------------------------------

	--	CREATE display objects and add them to 'group' here.
	--	Example use-case: Restore 'group' from previously saved state.

-- -- create object
--local myObject = display.newRect( 0, 0, 100, 100 )
--myObject:setFillColor( 255 )

-- -- touch listener function
-- function myObject:touch( event )
-- if event.phase == "began" then
-- self.markX = self.x -- store x location of object
-- self.markY = self.y -- store y location of object
-- elseif event.phase == "moved" then
-- local x = (event.x - event.xStart) + self.markX
-- local y = (event.y - event.yStart) + self.markY
-- self.x, self.y = x, y -- move object based on calculations above
-- end
-- return true
-- end


-- get the screen size
_W = display.contentWidth
_H = display.contentHeight

local currentMap = nil

delay=1
initCamera()
physics.start( )

-- connect to server
network.connect_to_server("127.0.0.1", 3000)
network.sendPosition()
luaMap = network.receiveSerialized()	-- for now, first frame received is map. TODO: add listeners

currentMap = Map:new(luaMap)


local player = player.new( "Me",  2)

local trans
local function moveObject(e)
	if(trans)then
		transition.cancel(trans)
	end

	--find nearest node

	---------------
	--get way to destination

	---------------
	--dummy map
 
	--player:saveNewNodes(currentMap.nodesByUID)

	player:saveNewDestination(e)


end
Runtime:addEventListener("tap",moveObject)

local myListener = function( event )
player:refresh()
lookAt(player.pos)
end
Runtime:addEventListener( "enterFrame", myListener )

	-----------------------------------------------------------------------------
	
end


local function myTapListener( event )

    --code executed when the button is tapped
    print( "object tapped = "..tostring(event.target) )  --'event.target' is the tapped object
    return true
end

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local group = self.view
	
	-----------------------------------------------------------------------------

	--	INSERT code here (e.g. start timers, load audio, start listeners, etc.)
	
	-----------------------------------------------------------------------------
	
end


-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	local group = self.view
	
	-----------------------------------------------------------------------------
	
	--	INSERT code here (e.g. stop timers, remove listeners, unload sounds, etc.)
	
	-----------------------------------------------------------------------------
	
end


-- Called prior to the removal of scene's "view" (display group)
function scene:destroyScene( event )
	local group = self.view
	
	-----------------------------------------------------------------------------
	
	--	INSERT code here (e.g. remove listeners, widgets, save state, etc.)
	
	-----------------------------------------------------------------------------
	
end


---------------------------------------------------------------------------------
-- END OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

-- "createScene" event is dispatched if scene's view does not exist
scene:addEventListener( "createScene", scene )

-- "enterScene" event is dispatched whenever scene transition has finished
scene:addEventListener( "enterScene", scene )

-- "exitScene" event is dispatched before next scene's transition begins
scene:addEventListener( "exitScene", scene )

-- "destroyScene" event is dispatched before view is unloaded, which can be
-- automatically unloaded in low memory situations, or explicitly via a call to
-- storyboard.purgeScene() or storyboard.removeScene().
scene:addEventListener( "destroyScene", scene )

---------------------------------------------------------------------------------

return scene