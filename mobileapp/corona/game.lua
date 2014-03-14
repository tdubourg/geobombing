----------------------------------------------------------------------------------
--
-- game.lua
--
----------------------------------------------------------------------------------

local storyboard = require( "storyboard" )
local Player = require( "player" )
local Monster = require( "monster" )
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
local nameText
local others -- ajout recent à vérifier
local monsters
rankOn = false
arcs = {}

-- activate multitouch
system.activate( "multitouch" )
local maxpos, maypos, maxminuspos, mayminuspos = 2000, 2000, -2000, -2000

local function calculateDelta( previousTouches, event )
	local id,touch = next( previousTouches )
	if event.id == id then
		id,touch = next( previousTouches, id )
		assert( id ~= event.id )
	end
	 
	local dx = touch.x - event.x
	local dy = touch.y - event.y
	return dx, dy
end


function movePlayerById(id,arcP)
	local strid = tostring(id)

	local daPlayer = others[strid]
	if (not daPlayer) then
		daPlayer = Player.new(strid,0.02,0,arcP)
		others[strid] = daPlayer
	end

	daPlayer:setAR(arcP)
	
	if daPlayer == player then
		camera:lookAt(player:getPos())
	end
end

function moveMonsterById(id,arcP)
	local strid = tostring(id)
	dbg(MONSTER_UPDATES_DBG, {"Executing moveMonsterById for id", strid})

	local daMonster = monsters[strid]
	if (not daMonster) then
		daMonster = Monster.new(strid, 0.02, 0, arcP)
		monsters[strid] = daMonster
	end
	--dbg(GAME_DBG, {arcP.arc.end1.uid,arcP.arc.end2.uid,arcP.progress})
	daMonster:setAR(arcP)
	
end


function removeScoreDisplay()
	rankOn = false
	scoreGroup:removeSelf()
	--time = gameTime
	--timerId = timer.performWithDelay( 1000, updateTime , -1 )
	Runtime:addEventListener("touch", newPlayerDestination)	
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
	timeText = display.newText("Temps restant: ".. time, 0, 0,  native.systemFont, 40)
	timeText.xScale = 0.5
	timeText.yScale = 0.5
	-- timeText:setReferencePoint(display.BottomLeftReferencePoint);
	timeText.x =  display.contentWidth/ 2;
	timeText.y =  display.contentHeight - 20;
	timeText: setFillColor( 0,0.7,0.5 )

	scoreDText = display.newText("-"..player.nbDeath, 0, 0,  native.systemFont, 40)
	scoreDText.xScale = 0.5
	scoreDText.yScale = 0.5
	-- timeText:setReferencePoint(display.BottomLeftReferencePoint);
	scoreDText.x =  60 -- display.contentWidth- 20--display.contentWidth;
	scoreDText.y =  display.contentHeight - 20
	scoreDText:setFillColor(0.7, 0.1, 0.1 )

	scoreKText = display.newText(" / +"..player.nbKill, 0, 0,  native.systemFont, 40)
	scoreKText.xScale = 0.5
	scoreKText.yScale = 0.5
	-- timeText:setReferencePoint(display.BottomLeftReferencePoint);
	scoreKText.x =  90 -- display.contentWidth- 20--display.contentWidth
	scoreKText.y =  display.contentHeight - 20
	scoreKText:setFillColor( 0.1, 0.7, 0.1 )

	nameText = display.newText("Nom : "..player.name, 0, 0,  native.systemFont, 40)
	nameText.xScale = 0.5
	nameText.yScale = 0.5
	-- timeText:setReferencePoint(display.BottomLeftReferencePoint);
	nameText.x =  display.contentWidth*(4/5)-- display.contentWidth- 20--display.contentWidth;
	nameText.y =  20
	nameText:setFillColor( 0.7, 0, 0.3 )
end

function update_player_position(id, pos_obj )
	local arcP = currentMap:createArcPosByUID(pos_obj.n1, pos_obj.n2, pos_obj.c)
	movePlayerById(id, arcP)
end

function update_monster_position(id, pos_obj )
	local arcP = currentMap:createArcPosByUID(pos_obj.n1, pos_obj.n2, pos_obj.c)
	moveMonsterById(id, arcP)
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
		end
	end

end

local trans
local last_newPlayerDestination = 0
function newPlayerDestination(e)
	if(trans)then
		transition.cancel(trans)
	end

	if (btnBombClicked) then
		btnBombClicked = false
	else
		local timeLimit = now() - PLAYER_MOVE_ON_DRAG_UPDATE_INTERVAL_IN_MS
		if (e.phase ~= "began" and last_newPlayerDestination > timeLimit) then
			-- Do not do anything, to avoid spamming player move requests on each pixel 
			return
		end
		dbg(PREDICTION_DBG, {"Setting new player destination"})
		last_newPlayerDestination = now()
		local screenPos = Vector2D:new(e.x,e.y)
		local worldPos = camera:screenToWorld(screenPos)

		local from = currentMap:getClosestNode(player.pos)	

		local arcP = currentMap:getClosestPos(worldPos)

		if (arcP ~= nil) then 
			if (arcP.progress<0) then
				dbg (ERRORS, {arcP.progress.." ERROR"})
			end
			arcs={}
			--currentMap.mapGroup:removeSelf()
			if (player.arcPCurrent.arc.end1.uid == arcP.arc.end1.uid and player.arcPCurrent.arc.end2.uid == arcP.arc.end2.uid) then
				net.sendPathToServer(nil,arcP)
				-- draw line
				local pos = player.arcPCurrent:getPosXY()
				local arcPEnd = arcP:getPosXY()
				arcs[arcP.arc] = {pos,arcPEnd}
				
				
			else
				local nodes = currentMap:findPathArcs(player.arcPCurrent,arcP)
				if (nodes == nil) then -- FIXME!
					dbg(ERRORS, {"WHAT?! WTF?"})
				else
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
				player:setPredictionNodes(nodes)
				player:setPredictionDestination(arcP)
				net.sendPathToServer(nodes,arcP)
				if (nodes ~= nil) then
					local pos = player.arcPCurrent:getPosXY()
					arcs[player.arcPCurrent] ={pos,nodes[1].pos}
					for i= 1, #nodes-1 do
						local path = nodes[i].arcs[nodes[i+1]]
						arcs[path] = {path.end1.pos,path.end2.pos}
					end
					if(nodes[#nodes] == arcP.arc.end1) then
						local arcPEnd = arcP:getPosXY()
						arcs[arcP.arc] =  {arcP.arc.end1.pos,arcPEnd}
					else
						local arcPEnd = arcP:getPosXY()
						arcs[arcP.arc] =  {arcP.arc.end2.pos,arcPEnd}
					end
				end
			end
		else
			dbg(ERRORS, {"arcP == nil"})
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

	monsters = {}

	net.net_handlers[FRAMETYPE_PLAYERS_UPDATE] = function ( json_obj )
		if (not rankOn) then
			if (json_obj.data ~= nil) then
				-- There's some data to crunch
				local updates = json_obj.data[NETWORK_PLAYER_UPDATE_PLAYERS_KEY]

				if (updates == nil) then
					return
				end

				local t = json_obj.data[NETWORK_PLAYER_UPDATE_TIMESTAMP_KEY]
				local discard_timestamp_limit = now() - PLAYER_UPDATE_DISCARD_DELAY_IN_MS
				local dt = t - discard_timestamp_limit
				dbg(NETW_DBG_MODE, {"timestamp frame=", t})
				dbg(NETW_DBG_MODE, {"discard timestamp limit=", discard_timestamp_limit})
				dbg(NETW_DBG_MODE, {"ts_frame - ts_limit=", dt})

				for k,v in pairs(updates) do
					dbg(T, {"k=",k, "v=", v})
					local dead = v[NETWORK_PLAYER_UPDATE_DEAD_KEY]
					local kills = v[NETWORK_KILLS]

					-- Frame too old and does not contain information we want to read even if old ? Discard it!
					if (
						    dt < 0 -- old enough
						and dead == nil and kills == nil -- no important info in the frame
						and NETW_DISCARD_PU_OPTIMIZATION -- and optimization is not disabled
					) then
						dbg(DISCARDED_PLAYER_UPDATES_MSG, {"DISCARDED player update"})
					else
						-- The position has to be updated
						local pos = v[NETWORK_PLAYER_UPDATE_POS_KEY]
						local player_id = tostring(v[NETWORK_PLAYER_UPDATE_ID_KEY])
						if (pos ~= nil) then
							-- Then take it into account!
							update_player_position(
								player_id,
								pos
							)
						end

						if (json_obj.data[NETWORK_REMAINING_TIME] ~= nil) then
							time = json_obj.data[NETWORK_REMAINING_TIME]
							timeText.text = "Temps restant: " .. time
						end

						if (kills ~= nil) then
							dbg(NETW_KILLS_DBG, {"Received the player_update with a kills key:", kills})
							if (player_id == player.id) then
								dbg(NETW_KILLS_DBG, {"And the player is me", kills})
								player.nbKill = kills
								scoreKText.text = " / +" .. player.nbKill
							else
								dbg(NETW_KILLS_DBG, {"But the player is not më, I am=", player.id, "and it is=", player_id})
							end
						end

						--handling self death
						if dead then
							--dbg (GAME_DBG, {"init = ",json.encode(json_obj) })
							if player_id == player.id then
								-- storyboard.gotoScene("game" , { effect="crossFade", time=500 } )
								if (player.isDead == false) then
									player.nbDeath = player.nbDeath + 1
									scoreDText.text = "-"..player.nbDeath
									player:die()
								end
							else
								local daPlayer = others[player_id]
								if (daPlayer.isDead == false) then
									--daPlayer.nbDeath = daPlayer.nbDeath + 1
									daPlayer:die()
								end
							end
						elseif player_id == player.id  then
							if (player.isDead) then
								player:revive()
							end
						else
							local daPlayer = others[player_id]
							if (daPlayer.isDead) then
								--daPlayer.nbDeath = daPlayer.nbDeath + 1
								daPlayer:revive()
							end
						end
					end
				end
			end
		else
			removeScoreDisplay()
		end
	end

	net.net_handlers[FRAMETYPE_MONSTERS_UPDATE] = function ( json_obj )
		dbg(MONSTER_UPDATES_DBG, {"Received a monster update frame: ", json_obj})
		if (not rankOn) then
			if (json_obj.data ~= nil) then
				
				-- There's some data to crunch
				local updates = json_obj.data[NETWORK_MONSTER_UPDATE_MONSTERS_KEY]
				if (updates == nil) then
					return
				end

				local t = json_obj.data[NETWORK_MONSTER_UPDATE_TIMESTAMP_KEY]
				local discard_timestamp_limit = now() - PLAYER_UPDATE_DISCARD_DELAY_IN_MS -- same delay for monsters
				local dt = t - discard_timestamp_limit
				dbg(MONSTER_UPDATES_DBG, {"monster update:", json_obj.data})


				for k,v in pairs(updates) do
					dbg(T, {"k=",k, "v=", v})
					local dead = v[NETWORK_MONSTER_UPDATE_DEAD_KEY]

					-- Frame too old and does not contain information we want to read even if old ? Discard it!
					if (
						    dt < 0 -- old enough
						and dead == nil -- no important info in the frame
						and NETW_DISCARD_PU_OPTIMIZATION -- and optimization is not disabled
					) then
						dbg(DISCARDED_PLAYER_UPDATES_MSG, {"DISCARDED monster update"})
					else
						-- The position has to be updated
						local pos = v[NETWORK_MONSTER_UPDATE_POS_KEY]
						local monster_id = tostring(v[NETWORK_MONSTER_UPDATE_ID_KEY])
						if (pos ~= nil) then
							-- Then take it into account!
							 update_monster_position(
								monster_id,
								pos
							)
						end

						--handling monster death
						if dead then
							dbg (GAME_DBG, {"init = ",json.encode(json_obj) })
							local daMonster = monsters[monster_id]
							if (daMonster.isDead == false) then
								--daPlayer.nbDeath = daPlayer.nbDeath + 1
								daMonster:die()
							end
						else
							local daMonster = monsters[monster_id]
							if (daMonster.isDead) then
								--daPlayer.nbDeath = daPlayer.nbDeath + 1
								daMonster:revive()
							end
						end
					end
				end
			end
		else
			removeScoreDisplay()
		end
	end

	net.net_handlers[FRAMETYPE_GAME_END] = function ( json_obj )
		if (json_obj.data ~= nil) then 	
			-- Show the ranking
			if (json_obj.data[NETWORK_GAME_RANKING] ~= nil  and rankOn == false) then
				rankOn = true
				Runtime:removeEventListener("touch",newPlayerDestination)	
				scoreGroup = display.newGroup()
				local scoreDisplay = display.newRect( display.contentCenterX, display.contentCenterY, display.contentWidth-20, display.contentHeight-20 )
				scoreDisplay.alpha = 0.5
				scoreGroup:insert( scoreDisplay)

				local int = 50
				local rank = 1

				local prev =math.huge
				for i,j in pairs (json_obj.data[NETWORK_GAME_RANKING]) do
					if (((int)<scoreDisplay.contentHeight) or (json_obj.data[NETWORK_GAME_RANKING][i][NETWORK_RANKING_ID] == player.id)) then
						if (json_obj.data[NETWORK_GAME_RANKING][i][NETWORK_RANKING_POINTS] == prev) then
							local tempR = rank-1
							local plScore = display.newText(tempR.." = "..i.. " : -".. json_obj.data[NETWORK_GAME_RANKING][i][NETWORK_RANKING_NB_DEATH].." / +".. json_obj.data[NETWORK_GAME_RANKING][i][NETWORK_RANKING_NB_KILL].. " total : "..json_obj.data[NETWORK_GAME_RANKING][i][NETWORK_RANKING_POINTS] , 0, 0, native.systemFont, 16*2)
						else
							local plScore = display.newText(rank.." = "..i.. " : -".. json_obj.data[NETWORK_GAME_RANKING][i][NETWORK_RANKING_NB_DEATH].." / +".. json_obj.data[NETWORK_GAME_RANKING][i][NETWORK_RANKING_NB_KILL].. " total : "..json_obj.data[NETWORK_GAME_RANKING][i][NETWORK_RANKING_POINTS] , 0, 0, native.systemFont, 16*2)
							scoreGroup:insert( plScore)
							plScore.xScale = 0.5
							plScore.yScale = 0.5
							plScore.x =  scoreDisplay.contentWidth/ 2;
							plScore.y =  int;
							if (tostring(json_obj.data[NETWORK_GAME_RANKING][i][NETWORK_RANKING_ID]) == player.id) then
								plScore:setFillColor(0, 0, 1 )
							else
								plScore:setFillColor(0, 0, 0 )
							end
							int = int +30
							rank=rank+1
						end
						
					end
				end
			end
			player.nbDeath = 0
			scoreDText.text = "-"..player.nbDeath
			player.nbKill = 0
			scoreKText.text = " / +"..player.nbKill
		end
	end
	showScore()
	Runtime:addEventListener( "enterFrame", updateLoop )
	Runtime:addEventListener( "enterFrame", gui.update )
	Runtime:addEventListener("touch", newPlayerDestination)	

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
	--camera:setZoomXY(ZOOM_X,ZOOM_Y)
	camera:setZoomUniform(ZOOM)
	camera:lookAtXY(0,0)	
	gui.initGUI()
	
	-- connect to server
	local result = net.connect_to_server(SERVER_IP_ADDR, SERVER_PORT)

	net.net_handlers[FRAMETYPE_INIT] = function ( json_obj )
		dbg(Y,{"HANDLER"})
		--dbg (GAME_DBG, {"init = ",json.encode(json_obj) })
		if (json_obj.data ~= nil) then
			if (json_obj.data[NETWORK_TIME] ~= nil) then
				gameTime =10
				time = json_obj.data[NETWORK_TIME]
			end

			NETWORK_KEY = json_obj[JSON_FRAME_DATA][NETWORK_INIT_KEY_KEY]

			local luaMap = json_obj[JSON_FRAME_DATA][NETWORK_INIT_MAP_KEY]
			if (currentMap) then currentMap:destroy() end
			currentMap = Map:new(luaMap)

			local luaTiles = json_obj[JSON_FRAME_DATA][TYPETILES]
	    if tileBackground then tileBackground:destroy() end
	    tileBackground = TileBackground:new(luaTiles)

			initGame(json_obj[JSON_FRAME_DATA][NETWORK_INIT_PLAYER_ID_KEY])
			if (json_obj.data[NETWORK_NAME] ~= nil) then
				--dbg (GAME_DBG, {"name = ",json_obj.data[NETWORK_NAME] })
				player.name = json_obj.data[NETWORK_NAME]
				nameText.text = "Nom = "..player.name
			end
			player:refresh()
			camera:lookAt(player:getPos())
		end
	end

	if result then
		dbg (INFO, {"!!CONNECTED!!"} )
		net.net_handlers[FRAMETYPE_PLAYER_DISCONNECT] = function ( json_obj )
			local strid = tostring(json_obj.data.id)
			local playerObj = others[strid]
			if playerObj then
				playerObj:destroy()
				others[strid] = nil
			end
		end
		net.sendGPSPosition()
	else
		dbg (ERRORS, {"Could no connect to server"} )
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
	Runtime:removeEventListener( "enterFrame", gui.update )
	Runtime:removeEventListener("touch",newPlayerDestination)	

	net.net_handlers[FRAMETYPE_PLAYER_DISCONNECT] = nil
	net.net_handlers[FRAMETYPE_INIT] = nil
	net.net_handlers[FRAMETYPE_PLAYERS_UPDATE] = nil
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

	if tileBackground then
		tileBackground:destroy()
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