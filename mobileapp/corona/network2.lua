socket = require "socket"
local json = require("json")
local location = require("location")
require ("consts")
require "print_r"
require "utils"
require "arcPos"

local client = nil
local FRAME_SEPARATOR = "\n"

local _msgsendtable = {} -- send message queue
local net_handlers = {}
local mrcvTimer = nil
NETWORK_KEY = ""
local net_buffer = ""
local net_line_buffer = "" 

function test_network()
	local ip = "127.0.0.1"
	local port = 3000
	connect_to_server(ip, port)
	if (not client) then
		dbg (ERRORS, {"Unable to connect to server...", ip, port})
		return false
	end
	client:send("Bonjour!\n")
	local response_packet = ""

	response_packet = receive_line() -- receive_until("\n")
	client:close()
end

function receive_line()
	local result
	result, status, partial = client:receive() -- with no parameter = receive a line
	if (result == nil and partial ~= nil) then 
		-- We did not manage to read a full line 
		-- but we still read something, keep it 
		-- to complete it afterwards
		net_line_buffer = net_line_buffer .. partial
	elseif (result ~= nil) then
		-- We had a result, that is to say, an end of line
		-- concatenate it to the line buffer so that in case
		-- we previously had a partial line and this is in fact the
		-- end of the line, we have the full line in "result" variable
		result = net_line_buffer .. result
		-- and thus, also clear the line buffer!
		net_line_buffer = "" -- reset the buffer
	end
	dbg(NETW_DBG_MODE, {"result=", result})
	dbg(NETW_DBG_MODE, {"status=", status})
	dbg(NETW_DBG_MODE, {"partial=", partial})
	return result
end

function receive_until(end_separator)
	dbg(NETW_DBG_MODE, {"Entering receive_until"})
	local start, _end = net_buffer:find(end_separator)
	dbg(NETW_DBG_MODE, {"(net_buffer) start=", start, "_end=", _end})
	-- print (start, _end)
	while start == nil do
		-- print (start, _end)
		local chunk = client:receive(1)
		dbg(NETW_DBG_MODE, {"chunk=", chunk})
		if (chunk == nil) then
			break
		end
		-- Note: doing the find() on chunk for optimization (chunk is much smaller than net_buffer)
		-- as here we just want to know whether there's a end_separator or not
		start, _end = chunk:find(end_separator)
		dbg(NETW_DBG_MODE, {"(chunk) start=", start, "_end=", _end})
		net_buffer = net_buffer .. chunk
	end
	-- Then re-doing the find here, to have the right value
	start, _end = net_buffer:find(end_separator)
	dbg(NETW_DBG_MODE, {"(net_buffer) start=", start, "_end=", _end})
	if (start == nil) then
		return nil
	end
	local curr_frame = string.sub(net_buffer, 1, start)
	net_buffer = string.sub(net_buffer, _end+1)
	dbg(NETW_DUMP_MODE, {"curr_frame=", curr_frame, "net_buffer=", net_buffer})
	return curr_frame
end

function _mrcv()
	client:settimeout(0)
	local frameString, status = receive_line()-- receive_until(FRAME_SEPARATOR)

	if frameString ~= nil then
		local json_obj = json.decode(frameString)
		if (json_obj ~= nil) then
			if(not (type(json_obj) == "table")) then -- not valid json, probably
				dbg(ERRORS, {"Received an invalid frame: ", json_obj})
				return nil
			end
			dbg(NETW_DBG_MODE, {"json_obj.type=", json_obj.type})
			local handler = net_handlers[json_obj.type]
			dbg(NETW_DBG_MODE, {"Found handler", handler, "for this data"})
			if (handler ~= nil) then
				handler(json_obj)
			end
		end
	end        
end

function connect_to_server( ip, port )
	client = socket.connect(ip, port)
	if (client == nil) then
		return false
	else
		--setup timers to handle update and receive
		-- mrcvTimer = timer.performWithDelay(1, function() _mrcv(client) end, 0)
		-- timer.performWithDelay(1,function() _msend(conn) end,0)
		return client
	end
end

function start_background_networking()
	mrcvTimer = timer.performWithDelay(1, function() _mrcv(client) end, 0)
end

function stop_background_networking()
	if mrcvTimer then
		timer.cancel(mrcvTimer)
		mrcvTimer = nil
	end	
end

function disconnect()
	if client then
		client:close()
	end

	if mrcvTimer then
		timer.cancel(mrcvTimer)
	end
end


function createNetworkPosObjFromArcPos( arcPos )
	local s = {}
	s[NETWORK_POS_N1] = arcPos.arc.end1
	s[NETWORK_POS_N2] = arcPos.arc.end2
	s[NETWORK_POS_C] = arcPos.progress
	return s
end


function sendGPSPosition()
	if client ~= nil then
		location.enable_location()
		packet = {}
		packet[JSON_GPS_LATITUDE] = currentLatitude
		packet[JSON_GPS_LONGITUDE] = currentLongitude
	 	sendSerialized(packet, FRAMETYPE_GPS)
		location.disable_location()
	end
end

-- function receiveMap()
-- 	if client ~= nil then
-- 		jsonMap = receive_until(FRAME_SEPARATOR)
-- 		print ("JSON MAP RECEIVED :"..jsonMap)
-- 		luaMap = json.decode(jsonMap)
-- 		print "DESERIALIZED MAP"
-- 		print_r(luaMap)
-- 		return luaMap
-- 	end
-- 	return nil
-- end

function sendBombRequestToServer(  )
	-- local pos = createNetworkPosObjFromArcPos(player:getArcPCurrent())
	sendSerialized({}, FRAMETYPE_BOMB)
end

function receivedBombUpdate( network_data )
	itemsManager:bombUpdate(network_data.data)
end

function receivedGameEnd( network_data )
	--itemsManager:gameEnd(network_data.data) -- todo
end

function sendSerialized(obj, frameType)
	if client then
		local packet = {};
		packet[JSON_FRAME_DATA] = obj
		packet[JSON_FRAME_TYPE] = frameType
		packet[JSON_FRAME_KEY] = NETWORK_KEY
		sendString(json.encode(packet))
	end
end

function sendString(data)
	if client ~= nil then
		client:send(data .. FRAME_SEPARATOR)
	end
end

-- function _msend(client)
--     local cnt = #_msgsendtable
--     if cnt > 0 then
--       for key,msg in pairs(_msgsendtable) do 
--         if msg ~= nil then
--             client:send(msg .. "\r\n")
--         end    
--         _msgsendtable[key] = nil
--       end    
--     end    
-- end
 
--send function queues data for transmission 
-- function msgsend(data)
--   table.insert(_msgsendtable,data)
-- end
 
function sendPathToServer( nodes, arcP )
	local to_send = {}
	if (nodes == nil) then
		--if there a movement on the same arc
		--get the current arc (player.arcPCurrent.arc == arcP)
		local arc =player.arcPCurrent.arc
		--get the current ration (useless?)
		local ratio = player.arcPCurrent.progress
		--get the ratio of the final destination
		local ratioEnd =arcP.progress

		local net_nodes ={}
		
		-- we need the node that is the nearest to the final destination
		-- on the arc
		if (arcP.progress >= ratio) then
			net_nodes={arc.end2.uid}
		else
			net_nodes={arc.end1.uid}
			-- if the nearest is 1 we need to invert the ration
			ratioEnd=1-ratioEnd
		end
		--send infos
		to_send[JSON_MOVE_NODES] = net_nodes
		to_send[JSON_MOVE_START_EDGE_POS] = ratio
		to_send[JSON_MOVE_END_EDGE_POS] = ratioEnd
	else
		--if there is at least a node on which we need to go
		--get the current arc 
		local arc = player.arcPCurrent.arc
		--get the current ration (useless?)
		local ratio = player.arcPCurrent.progress
		--get the ratio of the final destination
		local ratioEnd =0

		local to_send = {}
		local net_nodes ={}
		
		 if (arc.end1.uid == nodes[1].uid) then
		 	ratio=1-ratio
		 end

		for i,v in ipairs(nodes) do
			net_nodes[#net_nodes+1] = v.uid
		end

		-- Add the second node of the final destination's arc
	 	if (net_nodes[#net_nodes] == arcP.arc.end1.uid) then
			net_nodes[#net_nodes+1] = arcP.arc.end2.uid
			ratioEnd =arcP.progress
		elseif (net_nodes[#net_nodes] == arcP.arc.end2.uid)  then
			net_nodes[#net_nodes+1] = arcP.arc.end1.uid
			-- invert the ratio 
			ratioEnd = 1- arcP.progress
		else
			print("error in sendPathToServer")
		end

		--Send infos
		to_send[JSON_MOVE_NODES] = net_nodes
		to_send[JSON_MOVE_START_EDGE_POS] = ratio
		to_send[JSON_MOVE_END_EDGE_POS] = ratioEnd
	end
	dbg(PREDICTION_DBG, {"----------------------------"})
	dbg(PREDICTION_DBG, {"Sending move request to server:", to_send})
	dbg(PREDICTION_DBG, {"----------------------------"})
	sendSerialized(to_send, FRAMETYPE_MOVE)
end

net_handlers[FRAMETYPE_BOMB_UPDATE] = receivedBombUpdate
net_handlers[FRAMETYPE_GAME_END] = receivedGameEnd

return
{
	  connect_to_server = connect_to_server
	, sendSerialized = sendSerialized
	, sendGPSPosition = sendGPSPosition
	, sendPathToServer = sendPathToServer
	, net_handlers = net_handlers
	, sendBombRequestToServer = sendBombRequestToServer
	, disconnect = disconnect
	, update = _mrcv
	, start_background_networking = start_background_networking
	, stop_background_networking = stop_background_networking
}