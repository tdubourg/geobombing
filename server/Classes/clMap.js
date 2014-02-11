//classe Map
var clMap = function() 
{
    //Attributs  
    this.mapName = "";
    this.mapId = 0; // to know the players who are in the same instance of map (even if same location)
    this.mapListNode = null; // Array of Node (all the point)
	this.mapListWay = null; // Array of Ways (all the segment of the same street name)
};

exports.clMap = clMap