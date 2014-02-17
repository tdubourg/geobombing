----------------------------------------------------------------------------------
--
-- game.lua
--
----------------------------------------------------------------------------------

local storyboard = require( "storyboard" )
local Player = require( "player" )
local network = require ("network")
local scene = storyboard.newScene()
require "node"
require "consts"
local camera = require "camera"
require "vector2D"
require "map"
require "items"
local physics = require( "physics" )

local playBtn
player = nil -- global in order to be accessed from everywhere

local bombBtn = nil
local currentMap = nil
itemsManager = nil
local gui = require ("gui") -- has to be required after globals definition

-- Called when the scene's view does not exist:
function scene:createScene( event )
	local group = self.view
	displayMainGroup:insert(group)
	camera.initCamera()
	gui.initGUI()

	delay=1
	physics.start( )

	-- connect to server
	network.connect_to_server("192.168.43.119", 3000)
	network.sendPosition()
	luaMap = network.receiveSerialized()	-- for now, first frame received is map. TODO: add listeners

	currentMap = Map:new(luaMap)

	player = Player.new( "Me",  2)
	itemsManager = ItemsManager.new()
	print ("IM", itemsManager)
end

local myListener = function( event )
	if (btnBombClicked) then
		btnBombClicked = false
	else
		player:refresh()
		lookAt(player.pos)
	end
end

local trans
local function moveObject(e)
		print ("Received tap event in moveObject")
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
			local worldPos = screenToWorld(screenPos)
			local node = currentMap:getClosestNode(worldPos)
			-- print ("Closest node is", node)
			--print(n6.pos.x .." ,".. n6.pos.y .." ")
			local from = currentMap:getClosestNode(player.pos)
			-- print ("Closest from is", from)
			
			if (from == node ) then
				print("la1")
				--player:saveNewDestination(e)
			elseif (from == nil) then
				print("la2")
				--player:saveNewDestinationVect(node.pos)
			elseif (node == nil) then
				print("la3")
				--player:saveNewDestination(e)
			-- print ("Nodes:", nodes)
			else
			local nodes = currentMap:findPath(from, node)
			player:saveNewNodes(nodes)
			end
		end


	end

-- local function myTapListener( event )

--     --code executed when the button is tapped
--     print( "object tapped = "..tostring(event.target) )  --'event.target' is the tapped object
--     return true
-- end

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local group = self.view
	storyboard.returnTo = "menu"
	Runtime:addEventListener( "enterFrame", myListener )
	Runtime:addEventListener("tap", moveObject)	
end


-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	local group = self.view
	gui.exitGUI()
	camera.exitCamera()
	if (itemsManager ~= nil) then
		itemsManager:destroy()
	end
	Runtime:removeEventListener( "enterFrame", myListener )
	Runtime:removeEventListener("tap",moveObject)	
end


-- Called prior to the removal of scene's "view" (display group)
function scene:destroyScene( event )
	local group = self.view
	group:removeSelf( )
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