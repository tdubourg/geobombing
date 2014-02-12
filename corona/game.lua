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
-- include Corona's "widget" library
local widget = require "widget"

-- forward declarations and other locals
local playBtn
-- Those constants are the ratio of the sizes and positions of the widget button relative to the full sized-background,
-- As the background is going to be scaled, using the ratio, and multiplying by the contentWidth/contentHeight, we're
-- going to place them at the exact location where they should be
POS_X_WIDGET_BUTTON = 0.90
POS_Y_WIDGET_BUTTON = 0.85

-- Those constants are because Corona does weird things
WIDTH_RATIO_WIDGET_BUTTON = 0.5
HEIGHT_RATIO_WIDGET_BUTTON = 0.5
BOMB_BTN_PIXELS_HEIGHT = 100
BOMB_BTN_PIXELS_WIDTH = 100

local btnBombClicked = false

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

if (btnBombClicked) then
	btnBombClicked = false
else
	local screenPos = Vector2D:new(e.x,e.y)
    local  worldPos = screenToWorld(screenPos)
	local node
	node = currentMap:getClosestNode(worldPos)
	--print(n6.pos.x .." ,".. n6.pos.y .." ")
	local from = currentMap:getClosestNode(player.pos)
	local nodes = currentMap:findPath(from, node)
	player:saveNewNodes(nodes)
	--player:saveNewDestinationVect(node.pos)
end


end
Runtime:addEventListener("tap",moveObject)

local myListener = function( event )
if (btnBombClicked) then
	btnBombClicked = false
else
player:refresh()
lookAt(player.pos)
end
end
Runtime:addEventListener( "enterFrame", myListener )

-- 'onRelease' event listener for playBtn
local function onBombBtnRelease()
	
	print("BOMB")
	btnBombClicked = true
	-- player:saveNewDestination(player.pos)
	-- go to level1.lua scene
	--storyboard.gotoScene( "game", "fade", 500 )

	return true	-- indicates successful touch
end

-- create a widget button (which will loads level1.lua on release)
	bombBtn = widget.newButton{
		label="",
		labelColor = { default={128}, over={128} },
		defaultFile="images/bombButton2.png",
		overFile="images/bombButton3.png",
		width=BOMB_BTN_PIXELS_WIDTH*WIDTH_RATIO_WIDGET_BUTTON,
		height=BOMB_BTN_PIXELS_HEIGHT*HEIGHT_RATIO_WIDGET_BUTTON,
		onRelease = onBombBtnRelease	-- event listener function
	}
	
	bombBtn.x = display.contentWidth*POS_X_WIDGET_BUTTON 
	bombBtn.y = display.contentHeight*POS_Y_WIDGET_BUTTON
group:insert( bombBtn )

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
	storyboard.returnTo = "menu"

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