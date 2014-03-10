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
require "tile"
local json = require "json"
local physics = require( "physics" )
local playBtn
player = nil -- global in order to be accessed from everywhere
local bombBtn = nil
currentMap = nil
itemsManager = nil
background = nil
local gui = require ("gui") -- has to be required after globals definition
local timerId = nil
local gameTime = 300
local time = gameTime
local timeText
local scoreDText
local scoreKText

function movePlayerById(id,arcP)
	local exist = false
	strid = "" .. id

	local daPlayer = others[strid]
	if (not daPlayer) then
		daPlayer = Player.new(strid,0.02,0,arcP)
		others[strid] = daPlayer
	end

	daPlayer:setAR(arcP)
end

function playerUpD(id)
	local exist = false
	strid = "" .. id

	local daPlayer = others[strid]
	if (not daPlayer) then
		daPlayer = Player.new(strid,0.02,0,arcP)
		others[strid] = daPlayer
	end

	daPlayer.nbDeath = daPlayer.nbDeath +1
end

function playerUpK(id)
	local exist = false
	strid = "" .. id

	local daPlayer = others[strid]
	if (not daPlayer) then
		daPlayer = Player.new(strid,0.02,0,arcP)
		others[strid] = daPlayer
	end

	daPlayer.nbKill = daPlayer.nbKill +1
end

local function onComplete( event )

	local action = event.action
	if "clicked" == event.action then
    	if 1 == event.index then

    	end
end

end



function updateTime()
	if (time <= 0) then
		time = gameTime
		local alert = native.showAlert( "Scores!", "Nombre de morts : ".. player.nbDeath .. "\n Nombre de tués : " .. player.nbKill, { "OK" }, onComplete )
	else
		time = time - 1
	end
	timeText.text = "Temps restant: ".. time
end

function showScore()
	-- Create a new text field to display the timer
	timeText = display.newText("Temps restant: ".. time, 0, 0, native.systemFont, 16*2)
	timeText.xScale = 0.5
	timeText.yScale = 0.5
	-- timeText:setReferencePoint(display.BottomLeftReferencePoint);
	timeText.x =  display.contentWidth/ 2;
	timeText.y =  display.contentHeight - 20;

	scoreDText = display.newText("-"..player.nbDeath, 0, 0, native.systemFont, 16*2)
	scoreDText.xScale = 0.5
	scoreDText.yScale = 0.5
	-- timeText:setReferencePoint(display.BottomLeftReferencePoint);
	scoreDText.x =  60 -- display.contentWidth- 20--display.contentWidth;
	scoreDText.y =  display.contentHeight - 20
	scoreDText:setFillColor(1, 0, 0 )

	scoreKText = display.newText(" / +"..player.nbKill, 0, 0, native.systemFont, 16*2)
	scoreKText.xScale = 0.5
	scoreKText.yScale = 0.5
	-- timeText:setReferencePoint(display.BottomLeftReferencePoint);
	scoreKText.x =  90 -- display.contentWidth- 20--display.contentWidth;
	scoreKText.y =  display.contentHeight - 20
		scoreKText:setFillColor( 0, 1, 0 )
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
		-- if streetText then
		-- 	streetText:removeSelf()
		-- end
		-- streetText = display.newText(name , 10, 10, native.systemFont, 24 )
		-- streetText.anchorX = 0
		-- streetText.anchorY = 0
		-- streetText:setFillColor( 0.7, 0, 0.3 )

		if not streetText then
			streetText = display.newText(name , 10, 10, native.systemFont, 24 )
			streetText.anchorX = 0
			streetText.anchorY = 0
			streetText:setFillColor( 0.7, 0, 0.3 )
		end
		streetText.text = name
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
				if (nodes == nil) then -- FIXME!
					print "WHAT?! WTF?"
				else
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
				end


			net.sendPathToServer(nodes,arcP)

			--player:saveNewNodes(nodes,arcP)
			end
		else
			print("arcP == nil") 
		end
	end
end

function initGame(player_id)
	
	player_id = "" .. player_id
	local nodeFr = currentMap:getClosestNode(Vector2D:new(0,0))
	for voisin,_ in pairs(nodeFr.arcs) do
		nodeT=voisin
	end
	local arcP = currentMap:createArcPos(nodeFr, nodeT,0.5)

	player = Player.new(player_id,  0.02, 0,arcP) -- TODO replace 0 by the id sent by the server

	others = {}
	others[player_id] = player

	net.net_handlers[FRAMETYPE_PLAYER_UPDATE] = function ( json_obj )
		-- print ("Received player update from server: " .. json.encode(json_obj))

		if (json_obj.data ~= nil) then
			-- There's some data to crunch

			-- The position has to be updated
			if (json_obj.data[NETWORK_PLAYER_UPDATE_POS_KEY] ~= nil) then
				-- print(json_obj.data[NETWORK_PLAYER_UPDATE_ID_KEY])
				update_player_position(
					json_obj.data[NETWORK_PLAYER_UPDATE_ID_KEY],
					json_obj.data[NETWORK_PLAYER_UPDATE_POS_KEY]
				)
			end

			if (json_obj.data[NETWORK_PLAYER_UPDATE_STATE_KEY] ~= nil) then
				update_player_state(json_obj.data[NETWORK_PLAYER_UPDATE_STATE_KEY])
			end
		end

		--handling self death
		if json_obj.data[NETWORK_PLAYER_UPDATE_DEAD_KEY] then
			if tostring(json_obj.data[NETWORK_PLAYER_UPDATE_ID_KEY]) == player.id then
				storyboard.gotoScene("menu" , { effect="crossFade", time=500 } )
			end
		end
	end

	showScore()
	Runtime:addEventListener( "enterFrame", updateLoop )
	Runtime:addEventListener("tap", moveObject)	
	timer.performWithDelay( 1000, updateTime , -1 )
end

-- local function myTapListener( event )

--     --code executed when the button is tapped
--     return true
-- end

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local group = self.view
	storyboard.returnTo = "menu"

	local tile = Tile:new()

	-- display a background image
	background = display.newImageRect( "images/background.png",display.contentWidth, display.contentHeight)
	-- background:setReferencePoint( display.TopLeftReferencePoint )
	background.x, background.y = display.contentCenterX, display.contentCenterY
	local group = self.view
	displayMainGroup:insert(group)
	camera = Camera:new()
	camera:setZoomXY(200,200)				--debug zoom
	-- camera:setZoomXY(2000,2000)	--city zoom
	camera:lookAtXY(0,0)	
	gui.initGUI()
	
	-- connect to server
	print "create scene"
	local result = net.connect_to_server("127.0.0.1", 3000)

	if result then
		print ( "!!CONNECTED!!" )
		net.net_handlers[FRAMETYPE_PLAYER_DISCONNECT] = function ( json_obj )
			local strid = tostring(json_obj.data.id)
			local playerObj = others[strid]
			if playerObj then
				playerObj:destroy()
				others[strid] = nil
			end
		end
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
		net.sendGPSPosition()
	else
		print ("Could no connect to server")
		currentMap = Map:new(nil)
		initGame("1")
		player:refresh()
		camera:lookAt(player:getPos())
	end

	itemsManager = ItemsManager.new()
end


-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	net.disconnect()

	Runtime:removeEventListener( "enterFrame", updateLoop )
	Runtime:removeEventListener("tap",moveObject)	

	net.net_handlers[FRAMETYPE_PLAYER_DISCONNECT] = nil
	net.net_handlers[FRAMETYPE_INIT] = nil
	net.net_handlers[FRAMETYPE_PLAYER_UPDATE] = nil

	local group = self.view
	gui.exitGUI()
	currentMap:destroy()

	if streetText then
		streetText:removeSelf()
	end

	if background then
		background:removeSelf( )
	end

	for id,player in pairs(others) do
		player:destroy()
		others[id] = nil
	end

	if (itemsManager ~= nil) then
		itemsManager:destroy()
	end

	group:removeSelf( )

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