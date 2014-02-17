----------------------------------------------------------------------------------
--
-- game.lua
--
----------------------------------------------------------------------------------

local storyboard = require( "storyboard" )
print("1")
local player = require( "player" )
print("2")
local network = require ("network")
print("3")
local scene = storyboard.newScene()
print("4")
require "node"
print("5")
require "consts"
print("6")
local camera = require "camera"
print("7")
require "vector2D"
print("8")
require "map"
print("9")
require "items"
print("10")
local physics = require( "physics" )
print("11")
local playBtn
print("12")
player = nil -- global in order to be accessed from everywhere
print("13")
local bombBtn = nil
print("14")
local currentMap = nil
print("15")
itemsManager = nil
print("16")
local gui = require ("gui") -- has to be required after globals definition
print("17")


-- Called when the scene's view does not exist:
function scene:createScene( event )
	print("18")
	local group = self.view
	print("19")
	displayMainGroup:insert(group)
	print("20")
	camera.initCamera()
	print("21")
	gui.initGUI()
	print("22")

	delay=1
	print("23")
	physics.start( )
	print("24")

	-- connect to server

	

	network.connect_to_server("127.0.0.1", 3000)
	print("25")
	network.sendPosition()
	print("26")
	luaMap = network.receiveSerialized()	-- for now, first frame received is map. TODO: add listeners
	print("27")
	currentMap = Map:new(luaMap)
	print("28")
	player = Player.new( "Me",  2)
	print("29")
	itemsManager = ItemsManager.new()
	print("29")
	print ("IM", itemsManager)
	print("29")
end
	print("29")
local myListener = function( event )
	print("29")
	if (btnBombClicked) then
	print("29")
		btnBombClicked = false
	print("29")
	else
	print("29")
		player:refresh()
	print("29")
		lookAt(player.pos)
	print("29")
	end
	print("29")
end
local trans
	print("29")
local function moveObject(e)
	print("29")
		print ("Received tap event in moveObject")
	print("29")
		if(trans)then
	print("29")
			transition.cancel(trans)
	print("29")
		end
	print("29")

		--find nearest node

		---------------
		--get way to destination

		---------------
		--dummy map
	 
		--player:saveNewNodes(currentMap.nodesByUID)

	print("29")
		if (btnBombClicked) then
	print("29")
			btnBombClicked = false
	print("29")
		else
	print("29")
			local screenPos = Vector2D:new(e.x,e.y)
			local worldPos = screenToWorld(screenPos)
	print("29")
			local node = currentMap:getClosestNode(worldPos)
	print("29")
			-- print ("Closest node is", node)
			--print(n6.pos.x .." ,".. n6.pos.y .." ")
			local from = currentMap:getClosestNode(player.pos)
	print("29")
			-- print ("Closest from is", from)
			
			if (from == node ) then
	print("29")
				print("la1")
	print("29")
				--player:saveNewDestination(e)
			elseif (from == nil) then
	print("29")
				print("la2")
	print("29")
				--player:saveNewDestinationVect(node.pos)
			elseif (node == nil) then
	print("29")
				print("la3")
	print("29")
				--player:saveNewDestination(e)
			-- print ("Nodes:", nodes)
			else
	print("29")
			local nodes = currentMap:findPath(from, node)
	print("29")
			player:saveNewNodes(nodes)
	print("29")
			end
	print("29")
		end
	print("29")


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