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
require "tileBackground"
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
local gameTime = 10
local time = gameTime
local timeText
local scoreDText
local scoreKText
local scoreGroup 
 isDead = false
rankOn = false

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



function removeScoreDisplay()
	rankOn = false
	scoreGroup:removeSelf()
	--time = gameTime
	--timerId = timer.performWithDelay( 1000, updateTime , -1 )
	Runtime:addEventListener("tap",moveObject)	
end

-- function updateTime()
-- 	if (time <= 0) then
-- 		time = gameTime
-- 		timer.cancel( timerId )

-- 	else
-- 		time = time - 1
-- 	end
-- 	timeText.text = "Temps restant: ".. time
-- end

function showScore()
	-- Create a new text field to display the timer
	timeText = display.newText("Temps restant: ".. time, 0, 0, native.systemFont, 16*2)
	timeText.xScale = 0.5
	timeText.yScale = 0.5
	-- timeText:setReferencePoint(display.BottomLeftReferencePoint);
	timeText.x =  display.contentWidth/ 2;
	timeText.y =  display.contentHeight - 20;
	timeText: setFillColor( 1,1,1 )

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
	function moveObject(e)
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
	local arcP =currentMap.arcs[1]
	 arcP= currentMap:createArcPosByUID(arcP.end1.uid, arcP.end2.uid,0.5)
	
	player = Player.new(player_id,  0.02, 0,arcP) -- TODO replace 0 by the id sent by the server

	others = {}
	others[player_id] = player

	net.net_handlers[FRAMETYPE_PLAYER_UPDATE] = function ( json_obj )

	
	if (not rankOn) then
				--print ("Received player update from server: " .. json.encode(json_obj))
				
		if (json_obj.data ~= nil) then
			-- There's some data to crunch
			local pos = json_obj.data[NETWORK_PLAYER_UPDATE_POS_KEY]
			local state = json_obj.data[NETWORK_PLAYER_UPDATE_STATE_KEY]

			-- The position has to be updated
			if (pos ~= nil) then
				local t = json_obj.data[NETWORK_PLAYER_UPDATE_TIMESTAMP_KEY]
				-- If we do not want to discard it...
				if (t >= now() - PLAYER_UPDATE_DISCARD_DELAY_IN_MS or state == nil or not NETW_DISCARD_PU_OPTIMIZATION) then				
					-- Then take it into account!
					update_player_position(
						json_obj.data[NETWORK_PLAYER_UPDATE_ID_KEY],
						json_obj.data[NETWORK_PLAYER_UPDATE_POS_KEY]
						)
				else
					dbg(DISCARDED_PLAYER_UPDATES, {"DISCARDED player updated", json_obj.data})
				end
			end

			if (state ~= nil) then
				update_player_state(json_obj.data[NETWORK_PLAYER_UPDATE_STATE_KEY])
			end
			if (json_obj.data[NETWORK_TIME] ~= nil) then
				time = json_obj.data[NETWORK_TIME]
				timeText.text = "Temps restant: ".. time
				--print("time"..time)
			end
			if (json_obj.data[NETWORK_KILLS] ~= nil) then
				--print("KILLLL",json_obj.data[NETWORK_KILLS])
				player.nbKill = json_obj.data[NETWORK_KILLS]
				scoreKText.text = " / +"..player.nbKill
			end
				--handling self death
			if json_obj.data[NETWORK_PLAYER_UPDATE_DEAD_KEY] then

				if tostring(json_obj.data[NETWORK_PLAYER_UPDATE_ID_KEY]) == player.id then
					--print("Youhou0", isDead)
					-- storyboard.gotoScene("game" , { effect="crossFade", time=500 } )
					if (isDead == false) then
						--print("Youhou01", isDead)
						
						player.nbDeath = player.nbDeath + 1
						scoreDText.text = "-"..player.nbDeath
						--print("MOOOOOOOOOOORT",player.nbDeath,scoreDText.text)
						--print(player.nbDeath)
						isDead = true
						-- local revive = function()
						-- 	isDead = false
						-- end
						--timer.performWithDelay( 3000, revive )
					end

				else
					
				end
			elseif tostring(json_obj.data[NETWORK_PLAYER_UPDATE_ID_KEY]) == player.id  then
				isDead=false
				--print("Youhou2", isDead)
			end
			
		end


	else
		removeScoreDisplay()
	end
end

net.net_handlers[FRAMETYPE_GAME_END] = function ( json_obj )
print ("Received player update from server: " .. json.encode(json_obj))

if (json_obj.data ~= nil) then 	

			-- Show the ranking
			if (json_obj.data[NETWORK_GAME_RANKING] ~= nil  and rankOn == false) then
				rankOn = true
				Runtime:removeEventListener("tap",moveObject)	
				scoreGroup = display.newGroup()
				local scoreDisplay = display.newRect( display.contentCenterX, display.contentCenterY, display.contentWidth-20, display.contentHeight-20 )
				scoreDisplay.alpha = 0.5
				scoreGroup:insert( scoreDisplay)

				local int = 50
				
				for i,j in pairs (json_obj.data[NETWORK_GAME_RANKING]) do
					print (json_obj.data[NETWORK_GAME_RANKING][i][NETWORK_RANKING_ID])
					print (json_obj.data[NETWORK_GAME_RANKING][i][NETWORK_RANKING_NB_DEATH])
					print (json_obj.data[NETWORK_GAME_RANKING][i][NETWORK_RANKING_NB_KILL])
					print (json_obj.data[NETWORK_GAME_RANKING][i][NETWORK_RANKING_POINTS])
					
					if (((int)<scoreDisplay.contentHeight) or (json_obj.data[NETWORK_GAME_RANKING][i][NETWORK_RANKING_ID] == player.id)) then
						local plScore = display.newText(i.. " : -".. json_obj.data[NETWORK_GAME_RANKING][i][NETWORK_RANKING_NB_DEATH].." / +".. json_obj.data[NETWORK_GAME_RANKING][i][NETWORK_RANKING_NB_KILL].. " total : "..json_obj.data[NETWORK_GAME_RANKING][i][NETWORK_RANKING_POINTS] , 0, 0, native.systemFont, 16*2)
						scoreGroup:insert( plScore)
						plScore.xScale = 0.5
						plScore.yScale = 0.5
						plScore.x =  scoreDisplay.contentWidth/ 2;
						plScore.y =  int;
						if (json_obj.data[NETWORK_GAME_RANKING][i][NETWORK_RANKING_ID] == player.id) then
							plScore:setFillColor(0, 0, 1 )
						else
							plScore:setFillColor(0, 0, 0 )
						end
						int = int +30
					end
				end

				--timer.performWithDelay( 3000, removeScoreDisplay , 1 )
			end
			player.nbDeath = 0
			scoreDText.text = "-"..player.nbDeath
			player.nbKill = 0
			scoreKText.text = " / +"..player.nbKill


		end
	end
	showScore()
	Runtime:addEventListener( "enterFrame", updateLoop )
	Runtime:addEventListener("tap", moveObject)	
		--timerId = timer.performWithDelay( 1000, updateTime , -1 )


	end

-- local function myTapListener( event )

--     --code executed when the button is tapped
--     return true
-- end

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local group = self.view
	storyboard.returnTo = "menu"

	-- display a background image
	--background = display.newImageRect( "images/background.png",display.contentWidth, display.contentHeight)
	--background.x, background.y = display.contentCenterX, display.contentCenterY
	
	local group = self.view
	displayMainGroup:insert(group)
	camera = Camera:new()
	if (DEBUG_ZOOM) then
		camera:setZoomXY(200,200)				--debug zoom
	else
		camera:setZoomXY(2000,2000)	--city zoom
	end
	camera:lookAtXY(0,0)	
	gui.initGUI()
	
	-- connect to server
	print "create scene"
	local result = net.connect_to_server(SERVER_IP_ADDR, SERVER_PORT)

	net.net_handlers[FRAMETYPE_INIT] = function ( json_obj )
		dbg(Y,{"HANDLER"})
		if (json_obj.data ~= nil) then
			if (json_obj.data[NETWORK_TIME] ~= nil) then
				print(json_obj.data[NETWORK_TIME])
				gameTime =10
				time = json_obj.data[NETWORK_TIME]
			end

			NETWORK_KEY = json_obj[JSON_FRAME_DATA][NETWORK_INIT_KEY_KEY]
			print ("SENT KEY=", json_obj[JSON_FRAME_DATA][NETWORK_INIT_KEY_KEY])

			local luaMap = json_obj[JSON_FRAME_DATA][NETWORK_INIT_MAP_KEY]
			if (currentMap) then currentMap:destroy() end
			currentMap = Map:new(luaMap)

			local luaTiles = json_obj[JSON_FRAME_DATA][TYPETILES]
	    if tileBackground then tileBackground:destroy() end
	    tileBackground = TileBackground:new(luaTiles)

			initGame(json_obj[JSON_FRAME_DATA][NETWORK_INIT_PLAYER_ID_KEY])
			player:refresh()
			camera:lookAt(player:getPos())
		end
	end

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
		print "GPS pos"
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
	net.net_handlers[FRAMETYPE_GAME_END] = nil

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