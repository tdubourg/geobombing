"use strict"
//* Server that deals with the data from the client

// Include module and global var
var net = require("net"); // library call
var netw = require('./network'); // import class-file network.js
var FRAME_SEPARATOR = netw.FRAME_SEPARATOR;
var decode = netw.decode_frame;
var frame_actions = require('./frame_action').frame_actions;

// tree which choose which action to perform
var frame_action = function (frame_data, stream) 
{
	if (!(frame_data.type in frame_actions)) 
	{
		console.error("Received command of type ", frame_data.type, ", not recognized, doing nothing.");
		return false;
	}
	return frame_actions[frame_data.type](frame_data.data, stream)
}


// --- server running ---
exports.start = start
function start (port) 
{
	var now = new Date();
	var server = net.createServer(function(stream) 
	{
		console.log("SERV: A new client is connected");
		stream.setTimeout(0);
		stream.setEncoding("utf8");
		stream.addListener("connect", function(){console.log("SERV: ", new Date(), "New client server connection established.")});

		var buffer = ""
		stream.addListener("data", function (data) 
		{
			console.log("SERV: ", new Date(), "Receiving data from a client")
			buffer += data
			var pos = -1
			while (-1 != (pos = buffer.indexOf(FRAME_SEPARATOR))) {//* We have found a separator, that means that the previous frame (that may be incomplete or may not) is over and a new one starts
				console.log(new Date(), "A frame is over")
				console.log(buffer)
				var frame = buffer.substr(0, pos)
				buffer = buffer.substr(pos + FRAME_SEPARATOR.length, buffer.length) //* If the second parameter is >= the maximum possible length substr can return
				var frame_data = decode(frame); // returns type (map, gps, move, bomb...)
				frame_action(frame_data, stream);
			};
			console.log("SERV: ", "Ending the client stream data receiver function") 
		});

		stream.addListener("end", function() 
		{
			console.log("SERV: ", "Closing a client server connection")
			stream.end();
		});

		stream.addListener("error", function(err) {console.log("SERV: ", "An error occured on a connection: ", err)});
	});

	server.listen(port);
}
