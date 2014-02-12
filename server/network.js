"use strict"

// Utils for network
var FRAME_SEPARATOR = "\n"

var decode_frame = function (frame_string) 
{
	var decoded_frame;
	try{decoded_frame = JSON.parse(frame_string);} // deserialization JSON
	catch (e){decoded_frame = {type: "unknown", data: frame_string};}
	return decoded_frame;
}

// provides "attributes" and "methods" for the "class" server.js
exports.FRAME_SEPARATOR = FRAME_SEPARATOR
exports.decode_frame = decode_frame
