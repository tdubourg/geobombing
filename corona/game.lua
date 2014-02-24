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
require "camera"
require "vector2D"
require "map"
require "items"
local json = require "json"
local physics = require( "physics" )
local playBtn
player = nil -- global in order to be accessed from everywhere
local bombBtn = nil
local currentMap = nil
itemsManager = nil
local gui = require ("gui") -- has to be required after globals definition


function initGame()
	local nodeFr = currentMap:getClosestNode(Vector2D:new(0,0))
	for voisin,_ in pairs(nodeFr.arcs) do
		nodeT=voisin
	end
	player = Player.new( "Me",  0.02, 0,nodeFr , nodeT )

	-- PATHFINDING TEST
	-- local ap1 = currentMap:createArcPosByUID("1","4", 0.3)
	-- local ap2 = currentMap:createArcPosByUID("2","5", 0.2)
	-- local result = currentMap:findPathArcs(ap1, ap2)

	-- for i,v in ipairs(result) do
	-- 	print("i"..i)
	-- 	print("v"..v.uid)
	-- end
end

-- Called when the scene's view does not exist:
function scene:createScene( event )
	local group = self.view
	displayMainGroup:insert(group)
	camera = Camera:new()
	camera:setZoomXY(200,200)
	camera:lookAtXY(0,0)	
	gui.initGUI()

	-- connect to server
	local result = net.connect_to_server("127.0.0.1", 3000)
	
	if result then
		print ( "!!CONNECTED!!" )
		net.net_handlers['map'] = function ( json_obj )
			luaMap = json_obj[JSON_FRAME_DATA]
			if (currentMap) then currentMap:destroy() end
			currentMap = Map:new(luaMap)
			initGame()
			player:refresh()
			camera:lookAt(player:getPos())
		end
		net.net_handlers['pos'] = function ( json_obj )
			print ("Received pos from server: " .. json.encode(json_obj))

			local arcP = currentMap:createArcPosByUID(json_obj.data.n1, json_obj.data.n2,json_obj.data.c)
			player:setAR(arcP)
		end
		net.sendPosition()
	else
		print ("Could no connect to server")
		currentMap = Map:new(nil)
		initGame()
		player:refresh()
		camera:lookAt(player:getPos())
	end

	itemsManager = ItemsManager.new()
end

local myListener = function( event )
	if (btnBombClicked) then
		btnBombClicked = false
	else
	end
end
local trans
local function moveObject(e)
		if(trans)then
			transition.cancel(trans)
		end
		--camera:lookAt(camera:screenToWorld(Vector2D:new(e.x,e.y)))


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
			local worldPos = camera:screenToWorld(screenPos)
			local node = currentMap:getClosestNode(worldPos)
			local from = currentMap:getClosestNode(player.pos)
			
			if (from == node ) then
				--player:saveNewDestination(e)
			elseif (from == nil) then
				--player:saveNewDestinationVect(node.pos)
			elseif (node == nil) then
				--player:saveNewDestination(e)
			else

			local arcP = currentMap:getClosestPos(worldPos)
			print(arcP.arc.end1.uid .."AAAAAAAAAAAAAAAAAAAA/"..arcP.arc.end2.uid.."  ratio ".. arcP.progress)
			if (arcP.progress<0) then
				print (arcP.progress.." ERROR")
			end
			--player.arcPDest = arcP

			--local nodes = currentMap:findPath(from, node)
			local ap1 = currentMap:createArcPos(player.currentArc.end1,player.currentArc.end2,player.currentArcRatio)
			local nodes = currentMap:findPathArcs(ap1,arcP)
--print(player.currentArc.end1.uid,player.currentArc.end2.uid,player.currentArcRatio)
--print(from.uid .. "<--- from")
			
			player.nodeFrom=from
			 for _,nod in ipairs(nodes) do
				print(nod.uid)
				end

			net.sendPathToServer(from,nodes,arcP)
			
			--player.nodeTo=nodes[1]
			
			--player:goToAR(arcP)
			
			--player:saveNewNodes(nodes)
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