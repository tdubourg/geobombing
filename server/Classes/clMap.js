//classe Map
var clMap = function() 
{
    //Attributs    
    this.mapName = "";
    this.mapId = 0;
    this.mapListNode = null; // Array of Node (all the point)
	this.mapListWay = null; // Array of Ways (all the segment of the same street name)
};

exports.clMap = clMap