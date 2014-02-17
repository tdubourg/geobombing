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

///--- Network Classes---

//classe Way
var clPosition = function() 
{
    //Attributs    
	this.n1 = 0;
	this.n2 = 0;
    this.c = -1; // coeficient [0-1] of position between node1 & node2
};

exports.clPosition = clPosition

// provides "attributes" and "methods" for the "class" server.js
exports.FRAME_SEPARATOR = FRAME_SEPARATOR
exports.decode_frame = decode_frame
