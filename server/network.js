"use strict"

// Utils for network
var FRAME_SEPARATOR = "\n"

var decode_frame = function (frame_string) 
{
	var decoded_frame = JSON.parse(frame_string); // deserialization JSON
	var frame;
	switch (decoded_frame.type)
    { 
        case "move": frame = {type: "move", data: decoded_frame.data}; break;
        case "bomb": frame = {type: "bomb", data: decoded_frame.data}; break;
        case "map": frame = {type: "map", data: decoded_frame.data}; break;
        case "gps": frame = {type: "gps", data: decoded_frame.data}; break;
        default: frame = {type: "unknown", data: decoded_frame.data}; break;
    }
	//var frame = {type: "map", data: "frame_string"}; //TODO implement that
	return frame;
}

// provides "attributes" and "methods" for the "class" server.js
exports.FRAME_SEPARATOR = FRAME_SEPARATOR
exports.decode_frame = decode_frame
