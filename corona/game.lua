----------------------------------------------------------------------------------
--
-- game.lua
--
----------------------------------------------------------------------------------

local storyboard = require( "storyboard" )
local player = require( "player" )
local scene = storyboard.newScene()
require "node"
require "network"
require "camera"
require "vector2D"

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

-- get the screen size
_W = display.contentWidth
_H = display.contentHeight

delay=1
initCamera()


--connect network
test_network();

-- connect to server
--test_network()
receiveMap()

-- map init
  local n1 = Node:new(0, 0, 1)
  local n2 = Node:new(20, 200, 2)
  local n3 = Node:new(100,100, 3)
  local n4 = Node:new(100,20, 4)
  local n5 = Node:new(150,250, 5)
  local n6 = Node:new(150,150, 6)



  n1:linkTo(n2)
  n2:linkTo(n3)
  n3:linkTo(n4)
  n4:linkTo(n1)
  n5:linkTo(n2)
  n6:linkTo(n2)
  n6:linkTo(n3)

--structure
local circle = display.newCircle(0,0,5)
circle.name = "circle"
circle.x = _W/2
circle.y = _H/2
print( circle.x)
print( circle.y)
-- create your object

local player = player.new( "Me",  0.5)
 -- player.tx = 0
 -- player.ty = 0
--player.drawable:addEventListener( "touch", player.drawable )

-- function square
local square = math.sqrt;
-- function to get the euclidian distance 
--btw actual position and desired position
local getDistance = function(a, b)
local x, y = a.x-b.x, a.y-b.y;
return square(x*x+y*y);
end;
	
--get way to destination

---------------
local trans
local function moveObject(e)
	if(trans)then
		transition.cancel(trans)
	end
	
	local screenPos = Vector2D:new(e.x, e.y)
	local  worldPos = screenToWorld(screenPos)
	-- lookAt(worldPos)
  	local dist = getDistance(player.drawable,e)
    --speed=dist/time
    trans = transition.to(player.drawable,{time=dist/player.speed,x=worldPos.x,y=worldPos.y})  -- move to touch position
    

end
Runtime:addEventListener("tap",moveObject)



player:printPlayerX()
player:printPlayerY()


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