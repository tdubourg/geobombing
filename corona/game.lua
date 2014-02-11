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
require "consts"
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

local nodesByUID = {}


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

delay=1
initCamera()


-- connect to server
local client = connect_to_server("127.0.0.1", 3000)
print "connected"

flushMap()
luaMap = receiveMap(client)
if luaMap then
  local mapName = luaMap[JSON_MAP_NAME]
  local nodes = luaMap[JSON_NODE_LIST]
  local ways = luaMap[JSON_WAY_LIST]

  -- load nodes
  for i,node in ipairs(nodes) do
    local lat = node[JSON_NODE_LAT]
    local lon = node[JSON_NODE_LON]
    local uid = node[JSON_NODE_UID]
    nodesByUID[uid] = Node:new(lat, lon, uid)
  end

  -- load arcs
  for i,way in ipairs(ways) do
    local nodeList = way[JSON_WAY_NODE_LIST]
    local previousNode = nil
    for j,nodeID in ipairs(nodeList) do
      local node = nodesByUID[nodeID]
      if (previousNode) then
        previousNode:linkTo(node)
      end
      previousNode = node
    end
  end


else
  --dummy map
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
  end

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
	-- local nodes= {}
	-- nodes[1] = n1
	-- nodes[2] = n2
	-- player:goTo(nodes)
	local screenPos = Vector2D:new(e.x, e.y)
	local  worldPos = screenToWorld(screenPos)
  lookAt(worldPos)
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