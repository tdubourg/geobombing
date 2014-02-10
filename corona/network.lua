socket = require "socket"
require "utils"
function test_network()
	local ip = "127.0.0.1"
	local port = 3000
	local client = connect_to_server(ip, port)
	if (not client) then
		print ("Unable to connect to server...", ip, port)
		return false
	end
	client:send("Bonjour!\n")
	local response_packet = ""

	response_packet = receive_until(client, "\n")
	client:close()

	print ("Serveur answered:", response_packet)
-- load scenetemplate.lua
end

function connect_to_server( ip, port )
	local client = socket.connect(ip, port)
	if (client == nil) then
		return false
	else
		return client
	end
end

function receive_until(client, end_separator )
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
