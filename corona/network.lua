socket = require "socket"
require "utils"
function test_network()
	local client = socket.connect("127.0.0.1", 3000)
	client:send("Bonjour!\n")
	local response_packet = ""

	response_packet = receive_until(client, "\n")
	client:close()

	print ("Serveur answered:", response_packet)
-- load scenetemplate.lua
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
