"use strict"

// Utils for network
var FRAME_SEPARATOR = "\n"
var decode_frame = function (frame_string) 
{
	var decoded_frame;
	try 
	{
		decoded_frame = JSON.parse(frame_string); // deserialization JSON
	} catch (e) 
	{
		console.error("Error parsing JSON for frame:", frame_string)
		decoded_frame = {type: "unknown", data: frame_string};
	}
	return decoded_frame;
}

///--- Network Constants on Server---
var TYPEPLAYERINIT = "init" // new map, new list bomb (no positions)
var TYPENAME = "name"
var TYPEMAP = "map"
var TYPETIMEREMAINING = "tr"
var TYPETILES = "tiles"

var TYPEGAMEEND = "end" // new map, new list bomb (no positions)
var TYPERANKING = "ranking" // tab of players, and points
var TYPEPLAYERDEADS = "pdeads" // number of deaths of the player
var TYPEPLAYERKILLS = "pkills" // number of people killed by the player
var TYPEPLAYERPOINTS = "ppoints" // number of points of the player

var TYPEMONSTERSUPDATE = "mu" // new position, new death for all monsters
var TYPEMONSTERS = "ms" // monsters
var TYPEPLAYERSUPDATE = "pu" // new position, new death, new points for all players
var TYPEPLAYERS = "pl" // players
var TYPETIMESTAMP  = "ts"
var TYPEID = "id"
var TYPEKEY = "key"
var TYPEPOS = "pos" 
var TYPEDEAD = "dead"
var TYPEKILLS = "k"
var TYPEGONE = "gone"

var TYPEBOMBUPDATE = "bu"
var TYPEBOMBID = "bid"
var TYPERADIUS = "rad" // power
var TYPEBOMBSTATE = "bs" // 0 = new, 1 = exploding
var TYPEBOMBTYPE = "btype" // 0 to ...

exports.TYPEPLAYERINIT = TYPEPLAYERINIT
exports.TYPENAME = TYPENAME
exports.TYPEMAP = TYPEMAP
exports.TYPETIMEREMAINING = TYPETIMEREMAINING
exports.TYPETILES = TYPETILES

exports.TYPEGAMEEND = TYPEGAMEEND
exports.TYPERANKING = TYPERANKING
exports.TYPEPLAYERDEADS = TYPEPLAYERDEADS
exports.TYPEPLAYERKILLS = TYPEPLAYERKILLS
exports.TYPEPLAYERPOINTS = TYPEPLAYERPOINTS

exports.TYPETIMESTAMP  = TYPETIMESTAMP 
exports.TYPEMONSTERSUPDATE = TYPEMONSTERSUPDATE
exports.TYPEMONSTERS = TYPEMONSTERS
exports.TYPEPLAYERSUPDATE = TYPEPLAYERSUPDATE
exports.TYPEPLAYERS = TYPEPLAYERS
exports.TYPEID = TYPEID
exports.TYPEKEY = TYPEKEY
exports.TYPEPOS = TYPEPOS
exports.TYPEDEAD = TYPEDEAD
exports.TYPEKILLS = TYPEKILLS
exports.TYPEGONE = TYPEGONE

exports.TYPEBOMBUPDATE = TYPEBOMBUPDATE
exports.TYPEBOMBID = TYPEBOMBID
exports.TYPEBOMBSTATE = TYPEBOMBSTATE
exports.TYPERADIUS = TYPERADIUS
exports.TYPEBOMBTYPE = TYPEBOMBTYPE

exports.FRAME_SEPARATOR = FRAME_SEPARATOR
exports.decode_frame = decode_frame
