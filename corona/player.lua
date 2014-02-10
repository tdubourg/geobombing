-------------------------------------------------
--
-- player.lua
--
--
-------------------------------------------------
require "camera"
local player = {}
local player_mt = { __index = player }	-- metatable

-------------------------------------------------
-- PRIVATE FUNCTIONS
-------------------------------------------------

-- local function getDogYears( realYears )	-- local; only visible in this module
-- return realYears * 7
-- end

-------------------------------------------------
-- PUBLIC FUNCTIONS
-------------------------------------------------

function player.new( pName, pSpeed, pNbDeath, pX, pY, drawable )	-- constructor
	local newPlayer = {
	name = pName or "Unnamed",
	speed = pSpeed or 0.2,
	nbDeath = pNDeath or 0,
	x = pX or 0,
	y= pY or 0,
	drawable = display.newImageRect("images/bomberman.jpg", 25, 25)
	
}
cameraGroup:insert(newPlayer.drawable)
return setmetatable( newPlayer, player_mt )
end

-------------------------------------------------





function player:printPlayerSpeed()
	print( self.name .. " is at speed " .. self.speed .. " ." )
end

-------------------------------------------------


function player:setPlayerNbDeath(newNbDeath)
	self.nbDeath = newNbDeath
end

-------------------------------------------------



function player:printPlayerNbDeath()
	print( self.name .. " is at dead " .. self.nbDeath .. " time(s)." )
end


-------------------------------------------------





function player:printPlayerX()
	print( self.name .. " is at x = " .. self.drawable.x .. " ." )
end

 -------------------------------------------------





function player:printPlayerY()
	print( self.name .. " is at y = " .. self.drawable.y .. " ." )
end

-------------------------------------------------
return player