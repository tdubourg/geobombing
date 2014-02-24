socket = require "socket"
local json = require("json")
local location = require("location")
require ("consts")
require "print_r"
require "utils"
require "arcPos"

local client = nil
local FRAME_SEPARATOR = "\n"
local NETWORK_DUMP = true
local _msgsendtable = {} -- send message queue
local net_handlers = {}

function test_network()
	local ip = "127.0.0.1"
	local port = 3000
	connect_to_server(ip, port)
	if (not client) then
		print ("Unable to connect to server...", ip, port)
		return false
	end
	client:send("Bonjour!\n")
	local response_packet = ""

	response_packet = receive_until("\n")
	client:close()

	--print ("Serveur answered:", response_packet)
-- load scenetemplate.lua
end

function receive_until(end_separator)
	local str = ""
	local start, _end = str:find(end_separator)
	-- print (start, _end)
	while start == nil do
		-- print (start, _end)
		local chunk = client:receive(1)
		if (chunk == nil) then
			break
		end
		str = str .. chunk
		start, _end = str:find(end_separator)
	end
	-- if NETWORK_DUMP then
	-- 		print "NETWORK DUMP - IN"
	-- 		print(str)
	-- end
	if (str == "") then
		return nil
	end
	return str
end

function _mrcv(connection)
	connection:settimeout(0)
	local frameString, status = receive_until(FRAME_SEPARATOR)

	if frameString ~= nil then
		--print ( "Received network data: " .. frameString)
		local json_obj = json.decode(frameString)
		if (json_obj ~= nil) then
			local handler = net_handlers[json_obj.type]
			if (handler ~=nil) then
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
		timer.performWithDelay(1, function() _mrcv(client) end, 0)
		-- timer.performWithDelay(1,function() _msend(conn) end,0)
		return client
	end
end


function sendPosition()
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

function sendSerialized(obj, frameType)
	if client then
		local packet = {};
		packet[JSON_FRAME_DATA] = obj
		packet[JSON_FRAME_TYPE] = frameType
		sendString(json.encode(packet))
	end
end

function sendString(data)
	if client ~= nil then
		client:send(data .. FRAME_SEPARATOR)
		if NETWORK_DUMP then
			--print "NETWORK DUMP - OUT"
			--print(data)
		end
	end
end

-- function _msend(connection)
--     local cnt = #_msgsendtable
--     if cnt > 0 then
--       for key,msg in pairs(_msgsendtable) do 
--         if msg ~= nil then
--             connection:send(msg .. "\r\n")
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
	if (nodes == nil) then
		print ("here")
		local arc =player.arcPCurrent.arc
		local ratio = player.arcPCurrent.progress
		local ratioEnd =arcP.progress
		local to_send = {}
		local net_nodes ={}
		if (arcP.progress >= ratio) then
			net_nodes={arc.end2.uid}
		else
			net_nodes={arc.end1.uid}
			ratioEnd=1-ratioEnd
		end
	
		to_send[JSON_MOVE_NODES] = net_nodes
		to_send[JSON_MOVE_START_EDGE_POS] = ratio
		to_send[JSON_MOVE_END_EDGE_POS] = ratioEnd
		sendSerialized(to_send, FRAMETYPE_MOVE)
		
	else
		local arc = player.arcPCurrent.arc
		local ratio = player.arcPCurrent.progress
		local ratioEnd =0
		local to_send = {}
		local net_nodes ={}
		 if (arc.end1.uid == nodes[1].uid) then
		-- 	net_nodes = {arc.end2.uid}
		 	ratio=1-ratio
		 else
		-- 	net_nodes =  {arc.end1.uid}
		 end
		for i,v in ipairs(nodes) do
			net_nodes[#net_nodes+1] = v.uid
		end

		-- for _,nod in ipairs(net_nodes) do
			-- print("chemin" .. nod)
		-- end

		if (arc.end1.uid == arcP.arc.end1.uid and arc.end2.uid == arcP.arc.end2.uid) then
			if (net_nodes[#net_nodes] == arcP.arc.end1.uid) then
			--if (#net_nodes>1) then
			--net_nodes[#net_nodes+1] = arcP.arc.end2.uid
			--end
			ratioEnd =1- arcP.progress
			-- print ("ratioooooo" .. ratioEnd)
			elseif (net_nodes[#net_nodes] == arcP.arc.end2.uid)  then
			--if (#net_nodes>1) then
			--net_nodes[#net_nodes+1] = arcP.arc.end1.uid
			--end
			ratioEnd = arcP.progress
			-- print ("ratioooooo 1-" .. ratioEnd)

			else
				print("error in sendPathToServer")
			end
		else
		 	if (net_nodes[#net_nodes] == arcP.arc.end1.uid) then
			--if (#net_nodes>1) then
				net_nodes[#net_nodes+1] = arcP.arc.end2.uid
			--end
				ratioEnd =arcP.progress
				-- print ("ratioooooo" .. ratioEnd)
			elseif (net_nodes[#net_nodes] == arcP.arc.end2.uid)  then
			--if (#net_nodes>1) then
				net_nodes[#net_nodes+1] = arcP.arc.end1.uid
			--end
				ratioEnd = 1- arcP.progress
				-- print ("ratioooooo 1-" .. ratioEnd)

			else
				print("error in sendPathToServer")
			end
		end

		-- for _,nod in ipairs(net_nodes) do
		-- 			print("chemin apres" .. nod)
		-- 			end
		to_send[JSON_MOVE_NODES] = net_nodes
		to_send[JSON_MOVE_START_EDGE_POS] = ratio
		to_send[JSON_MOVE_END_EDGE_POS] = ratioEnd
		sendSerialized(to_send, FRAMETYPE_MOVE)
	end
end

return
{
	  connect_to_server = connect_to_server
	, sendSerialized = sendSerialized
	, sendPosition = sendPosition
	, sendPathToServer = sendPathToServer
	, net_handlers = net_handlers
}