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
require "print_r"
local json = require "json"
local physics = require( "physics" )
local playBtn
player = nil -- global in order to be accessed from everywhere
local bombBtn = nil
local currentMap = nil
itemsManager = nil
local gui = require ("gui") -- has to be required after globals definition

function initGame(player_id)
	player_id = "" .. player_id
	local nodeFr = currentMap:getClosestNode(Vector2D:new(0,0))
	for voisin,_ in pairs(nodeFr.arcs) do
		nodeT=voisin
	end
	local arcP = currentMap:createArcPos(nodeFr, nodeT,0.5)

	player = Player.new(player_id,  0.02, 0,arcP) -- TODO replace 0 by the id sent by the server

	others = {player}
end

function movePlayerById(id,arcP)
	local exist = false
	id = "" .. id
	-- print ( "id asked is ", id)
	-- print ( " -----------------------------")
	for _,other in ipairs(others) do
		-- print(other.id)
		if (other.id == id) then
			-- print("bouge")
			other:setAR(arcP)
			exist = true
		end
		-- print("bouge ??")
	end
	-- print ( " -----------------------------")
	if (exist == false) then
		-- print("bouge nouveau")
		others[#others+1] = Player.new(id,0.02,0,arcP)
	end
end

function update_player_position(id, pos_obj )
	--print ( "TOTO")
	--print (pos_obj.n1, pos_obj.n2, pos_obj.c)
	local arcP = currentMap:createArcPosByUID(pos_obj.n1, pos_obj.n2, pos_obj.c)
	--print ('arcP returned is', arcP)
	movePlayerById(id, arcP)
end

function update_player_state( state_obj )
	-- TODO
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
		net.net_handlers[FRAMETYPE_INIT] = function ( json_obj )
			NETWORK_KEY = json_obj[JSON_FRAME_DATA][NETWORK_INIT_KEY_KEY]
			print ("SENT KEY=", json_obj[JSON_FRAME_DATA][NETWORK_INIT_KEY_KEY])
			luaMap = json_obj[JSON_FRAME_DATA][NETWORK_INIT_MAP_KEY]
			if (currentMap) then currentMap:destroy() end
			currentMap = Map:new(luaMap)
			initGame(json_obj[JSON_FRAME_DATA][NETWORK_INIT_PLAYER_ID_KEY])
			player:refresh()
			camera:lookAt(player:getPos())
		end
		net.net_handlers[FRAMETYPE_PLAYER_UPDATE] = function ( json_obj )
			-- print ("Received player update from server: " .. json.encode(json_obj))

			if (json_obj.data ~= nil) then
				-- There's some data to crunch

				-- The position has to be updated
				if (json_obj.data[NETWORK_PLAYER_UPDATE_POS_KEY] ~= nil) then
					print(json_obj.data[NETWORK_PLAYER_UPDATE_ID_KEY])
					update_player_position(
						json_obj.data[NETWORK_PLAYER_UPDATE_ID_KEY],
						json_obj.data[NETWORK_PLAYER_UPDATE_POS_KEY]
					)

				end
				if (json_obj.data[NETWORK_PLAYER_UPDATE_STATE_KEY] ~= nil) then
					update_player_state(json_obj.data[NETWORK_PLAYER_UPDATE_STATE_KEY])
				end
			end
		end
		net.sendPosition()
	else
		print ("Could no connect to server")
		currentMap = Map:new(nil)
		initGame("1")
		player:refresh()
		camera:lookAt(player:getPos())
	end

	itemsManager = ItemsManager.new()
end

local updateLoop = function( event )
	if (btnBombClicked) then
		btnBombClicked = false
	else
		if (player ~=nil) then 
			player:refresh()
			camera:lookAt(player:getPos())
		end
	end

	-- TODO: move this into GUI.lua
	-- OPTIM: pull au lieu de fetch
	local name = player:getCurrentStreetName()
	if name then
		if streetText then
			streetText:removeSelf()
		end
		streetText = display.newText(name , 0, 0, native.systemFont, 24 )
		streetText.anchorX = 0
		streetText.anchorY = 0
		streetText:setFillColor( 0.5, 0, 0 )
	end
end

local trans
local function moveObject(e)
	print "TAP HANDLER"
	if(trans)then
		transition.cancel(trans)
	end

	if (btnBombClicked) then
		btnBombClicked = false
	else
		local screenPos = Vector2D:new(e.x,e.y)
		local worldPos = camera:screenToWorld(screenPos)
		
		local from = currentMap:getClosestNode(player.pos)	
		
			local arcP = currentMap:getClosestPos(worldPos)

			if (arcP ~= nil) then 
				-- test
				--movePlayerById(1, arcP)

				print(arcP.arc.end1.uid .."/"..arcP.arc.end2.uid.."  ratio ".. arcP.progress)
				if (arcP.progress<0) then
					print (arcP.progress.." ERROR")
				end
				if (player.arcPCurrent.arc.end1.uid == arcP.arc.end1.uid and player.arcPCurrent.arc.end2.uid == arcP.arc.end2.uid) then
					net.sendPathToServer(nil,arcP)
					--player:saveNewNodes(nil,arcP)
				else
					local nodes = currentMap:findPathArcs(player.arcPCurrent,arcP)
					--print(from.uid .. "<--- from")	
					if (nodes[1] == from) then
						if (player.arcPCurrent.arc.end1 == from) then
							player.nodeFrom=player.arcPCurrent.arc.end2
						else
							player.nodeFrom=player.arcPCurrent.arc.end1
						end
				else
					player.nodeFrom=from
				end



				net.sendPathToServer(nodes,arcP)

				--player:saveNewNodes(nodes,arcP)
				end
			else
				print("arcP == nil") 
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
	Runtime:addEventListener( "enterFrame", updateLoop )
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
	Runtime:removeEventListener( "enterFrame", updateLoop )
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