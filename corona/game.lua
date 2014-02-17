----------------------------------------------------------------------------------
--
-- game.lua
--
----------------------------------------------------------------------------------

local storyboard = require( "storyboard" )

local Player = require( "player" )

local scene = storyboard.newScene()

require "node"
require "consts"
local json = require( "json" )
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
	local result = net.connect_to_server("127.0.0.1", 3000)
	
	if result then

		net.net_handlers['map'] = function ( json_obj )
			luaMap = json_obj[JSON_FRAME_DATA]
		end
		net.net_handlers['pos'] = function ( json_obj )
			print (json.encode(json_obj))
		end
		net.sendPosition()
		 -- = net.receiveSerialized()	-- for now, first frame received is map. TODO: add listeners

	else
	end

	currentMap = Map:new(luaMap)
	player = Player.new( "Me",  2)
	itemsManager = ItemsManager.new()
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
			local from = currentMap:getClosestNode(player.pos)
			
			if (from == node ) then
				--player:saveNewDestination(e)
			elseif (from == nil) then
				--player:saveNewDestinationVect(node.pos)
			elseif (node == nil) then
				--player:saveNewDestination(e)
			else
			local nodes = currentMap:findPath(from, node)


			net.sendPathToServer(nodes)

			player:saveNewNodes(nodes)
			end
		end


	end

-- local function myTapListener( event )

--     --code executed when the button is tapped
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