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

///--- Network Constants on Server---
var TYPEPLAYERINIT = "init" // new map, new list bomb (no positions)
var TYPEMAP = "map"

var TYPEGAMEEND = "end" // new map, new list bomb (no positions)
var TYPERANKING = "ranking" // list points, winner

var TYPEPLAYERUPDATE = "pu" // new position, new bomb?, new death?, new points
var TYPEPOS = "pos" 
var TYPEDEATH = "dead"
var TYPEPOINTS = "points"
var TYPEGONE = "gone"

var TYPEBOMBUPDATE = "bu"
var TYPEBOMBID = "bid"
var TYPEBOMBSTATE = "bs" // 0 = new, 1 = exploding
var TYPEBOMBTYPE = "btype" // 0 to ...

exports.TYPEPLAYERINIT = TYPEPLAYERINIT
exports.TYPEMAP = TYPEMAP

exports.TYPEGAMEEND = TYPEGAMEEND
exports.TYPERANKING = TYPERANKING

exports.TYPEPLAYERUPDATE = TYPEPLAYERUPDATE
exports.TYPEPOS = TYPEPOS
exports.TYPEDEATH = TYPEDEATH
exports.TYPEPOINTS = TYPEPOINTS
exports.TYPEGONE = TYPEGONE

exports.TYPEBOMBUPDATE = TYPEBOMBUPDATE
exports.TYPEBOMBID = TYPEBOMBID
exports.TYPEBOMBSTATE = TYPEBOMBSTATE
exports.TYPEBOMBTYPE = TYPEBOMBTYPE

exports.FRAME_SEPARATOR = FRAME_SEPARATOR
exports.decode_frame = decode_frame
