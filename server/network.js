"use strict"

// Utils for network
var FRAME_SEPARATOR = "\n"

var decode_frame = function (frame_string) 
{
	console.log("decode_frame" + frame_string);
	var frame = {type: "map", data: "frame_string"} //TODO implement that
	return frame;
}

// provides "attributes" and "methods" for the "class" server.js
exports.FRAME_SEPARATOR = FRAME_SEPARATOR
exports.decode_frame = decode_frame
