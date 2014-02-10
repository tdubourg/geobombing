"use strict"
//* Server that deals with the data from the client

// Include module and global var
var net = require("net"); // library call
var utils = require('./common');
var netw = require('./network'); // import class-file network.js
var sd = require('./shared_data');
var FRAME_SEPARATOR = netw.FRAME_SEPARATOR;
var DBG = true;
var m = sd.MAP; // handy shortcut, for even shorter use
var db = sd.pgsql;
var decode = netw.decode_frame;


// executed function according to client result
var sendmap_action = function (frame_data, stream) 
{
	console.log("sendmap_action");
	// todo delete test
	var mapObj = utils.CreateFakeMap();
	var data = JSON.stringify(mapObj); // parsage JSON
	// end todo delete

	console.log("Sending Map: ", data)
	stream.write(data + FRAME_SEPARATOR, function () {console.log("Data sent:\n" + data)})
}

var sendInit_location = function (frame_data, stream) {}


var frame_actions = 
{
	"map": sendmap_action,
	"loc": sendInit_location
}
var frame_action = function (frame_data, stream) 
{
	if (!(frame_data.type in frame_actions)) 
	{
		console.error("Received command of type ", frame_data.type, ", not recognized, doing nothing.")
		return false
	}
	return frame_actions[frame_data.type](frame_data, stream)
}


// --- server running ---
exports.start = start
function start (port) 
{
	var server = net.createServer(function(stream) 
	{
		console.log("SERV: A new client is connected")
		stream.setTimeout(0);
		stream.setEncoding("utf8");

		stream.addListener("connect", function(){
			console.log("SERV: ", new Date(), "New client server connection established.")
		});

		var buffer = ""
		stream.addListener("data", function (data) {
			console.log("SERV: ", new Date(), "Receiving data from a client:", data)
			buffer += data
			var pos = -1
			while (-1 != (pos = buffer.indexOf(FRAME_SEPARATOR))) {//* We have found a separator, that means that the previous frame (that may be incomplete or may not) is over and a new one starts
				console.log(new Date(), "A frame is over")
				console.log(buffer)
				var frame = buffer.substr(0, pos)
				buffer = buffer.substr(pos + FRAME_SEPARATOR.length, buffer.length) //* If the second parameter is >= the maximum possible length substr can return, substr just returns the maximum length possible, so who cares substracting?
				var frame_data = decode(frame)
				frame_action(frame_data, stream)
			};
			console.log("SERV: ", "Ending the client stream data receiver function") //* Mainly for the purpose of being able to check when the VELOV_FRAME_EVENT handler function is executed with respect to the current function execution
		});

		stream.addListener("end", function() {
			console.log("SERV: ", "Closing a client server connection")
			stream.end();
		});
		stream.addListener("error", function(err) {
			console.log("SERV: ", "An error occured on a connection: ", err)
		});
	});

	server.listen(port);
}
