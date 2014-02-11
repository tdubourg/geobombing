socket = require "socket"
local json = require("json")
local location = require("location")
require "print_r"
require "utils"

local client = nil
local FRAME_SEPARATOR = "\n"

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

	print ("Serveur answered:", response_packet)
-- load scenetemplate.lua
end

function connect_to_server( ip, port )
	client = socket.connect(ip, port)
	if (client == nil) then
		return false
	else
		return client
	end
end

function receive_until(end_separator )
	local str = ""
	local start, _end = str:find(end_separator)
	-- print (start, _end)
	while start == nil do
		-- print (start, _end)
		chunk = client:receive(1)
		str = str .. chunk
		start, _end = str:find(end_separator)
	end
	return str
end

function sendPosition()
	if client ~= nil then
		location.enable_location()
		packet = {latitude=currentLatitude, longitude=currentLongitude}
		sendData(json.encode(packet))
		location.disable_location()
	end
end

function receiveMap()
	if client ~= nil then
		jsonMap = receive_until(FRAME_SEPARATOR)
		print ("JSON MAP RECEIVED :"..jsonMap)
		luaMap = json.decode(jsonMap)
		print "DESERIALIZED MAP"
		print_r(luaMap)
		return luaMap
	end
	return nil
end

function sendData(data)
	if client ~= nil then
		client:send(data..FRAME_SEPARATOR)
	end
end

