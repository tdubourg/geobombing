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

///--- Network Constants---
var TYPEMAP = "map";

var TYPEPLAYERUPDATE = "pu";
var TYPEPOS = "pos"; 
var TYPEBOMB = "bomb";
var TYPEDEATH = "dead";
var TYPEPOINTS = "points";

exports.TYPEMAP = TYPEMAP
exports.TYPEPLAYERUPDATE = TYPEPLAYERUPDATE
exports.TYPEPOS = TYPEPOS
exports.TYPEBOMB = TYPEBOMB
exports.TYPEDEATH = TYPEDEATH
exports.TYPEPOINTS = TYPEPOINTS

exports.FRAME_SEPARATOR = FRAME_SEPARATOR
exports.decode_frame = decode_frame
