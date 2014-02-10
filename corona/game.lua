----------------------------------------------------------------------------------
--
-- game.lua
--
----------------------------------------------------------------------------------

local storyboard = require( "storyboard" )
local player = require( "player" )
local scene = storyboard.newScene()
require "node"

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



--get the screen size
_W = display.contentWidth
_H = display.contentHeight
initCamera()


--map init
  local n1 = Node:new(20, 20, 1)
  local n2 = Node:new(20, 200, 2)
  local n3 = Node:new(100,100, 3)
  local n4 = Node:new(100,20, 4)
  local n5 = Node:new(150,250, 5)
  local n6 = Node:new(150,150, 6)


  cameraGroup:translate( 40, 0 )

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
circle.x = _W/4
circle.y = _H/4

-- create your object

local player = player.new( "Me",  0.1, 0, 0, 0)

--make 'myObject' listen for touch events
--local myObject = display.newImageRect("images/bomberman.jpg", 25, 25);
--local myObject = display.newRect(0,0,50,50)

--myObject.x = _W/2
--myObject.y = _H/2
player.drawable.x =_W/2
player.drawable.y =_H/2
player.drawable:addEventListener( "touch", player.drawable )

  -- function square
  local square = math.sqrt;
-- function to get the euclidian distance 
--btw actual position and desired position
local getDistance = function(a, b)
local x, y = a.x-b.x, a.y-b.y;
return square(x*x+y*y);
end;
player:printPlayerSpeed()
  --set the speed
  --local speed = 0.1

--get way to destination

---------------
local trans
local function moveObject(e)
	if(trans)then
		transition.cancel(trans)
	end
	-- if ((e.y-myObject.y/(e.x-myObject.x))*circle.x+(e.y-(e.y-myObject.y/(e.x-myObject.x))*e.y)==0) then
	-- 	local dist = getDistance(myObject,circle)
 --    	--speed=dist/time
 --    	trans = transition.to(myObject,{time=dist/speed,x=(circle.x-1),y=(circle.y-1)})	
 --    else
  	--local dist = getDistance(myObject,circle)
  	--trans = transition.to(myObject,{time=dist/speed,x=circle.x,y=circle.y})
  	local dist = getDistance(player.drawable,e)
    --speed=dist/time
    trans = transition.to(player.drawable,{time=dist/player.speed,x=e.x,y=e.y})  -- move to touch position
    --player.x =e.x
    --player.y =e.y
    
    player:printPlayerNbDeath()
    player:printPlayerX()
    player:printPlayerY()
-- end
end
Runtime:addEventListener("tap",moveObject)

-- _W = display.contentWidth
-- _H = display.contentHeight

-- local physics = require("physics")

-- physics.start()
-- physics.setGravity(0,0)

-- local circle = display.newCircle(0,0,20)
-- circle.name = "circle"
-- circle.x = _W/2
-- circle.y = _H/2
-- circle.tx = 0
-- circle.ty = 0
-- physics.addBody(circle)
-- circle.linearDamping = 0
-- circle.enterFrame = function(self,event)
--     print(self.x,self.tx)

--     --This condition will stop the circle on touch coordinates
--     --You can change the area value, this will detect if the circles's x and y is between the circles's tx and ty
--     --If area is 0, it may not stop the circle, area = 5 is safe, change if you want to
--     local area = 5
--     if self.x <= self.tx + area and self.x >= self.tx - area and
--        self.y <= self.ty + area and self.y >= self.ty - area then
--         circle:setLinearVelocity(0,0) --set velocity to (0,0) to fully stop the circle
--     end
-- end

-- --Add event listener for the monitoring the coordinates of the circle
-- Runtime:addEventListener("enterFrame",circle)


-- Runtime:addEventListener("touch",function(event)
--     if event.phase == "began" or event.phase == "moved" then
--         local x, y = event.x, event.y
--         local tx, ty = x-circle.x, y-circle.y --compute for the toX and toY coordinates
--         local sppedMultiplier = 1.5 --this will change the speed of the circle, 0 value will stop the circle

--         --sets the future destination of the circle
--         circle.tx = x 
--         circle.ty = y
--           circle:setLinearVelocity(tx*delay,ty*delay) --this will set the velocity of the circle towards the computed touch coordinates on a straight path.
--     end
-- end)

	-----------------------------------------------------------------------------
	
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