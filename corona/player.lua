-------------------------------------------------
--
-- player.lua
--
--
-------------------------------------------------
 
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
 
function player.new( pName, pSpeed, pNbDeath, pX, pY )	-- constructor
local newPlayer = {
name = pName or "Unnamed",
speed = pSeed or 0.2,
nbDeath = pNDeath or 0,
x = pX or 0,
y= pY or 0
}
return setmetatable( newPlayer, player_mt )
end
 
-------------------------------------------------

function player:setPlayerSpeed(newSpeed)
self.speed = newSpeed
end
 
-------------------------------------------------

function player:getPlayerSpeed()
return self.speed
end
 
-------------------------------------------------


 
function player:printPlayerSpeed()
print( self.name .. " is at speed " .. getPlayerSpeed() .. " ." )
end
 
-------------------------------------------------


function player:setPlayerNbDeath(newNbDeath)
self.nbDeath = newNbDeath
end
 
-------------------------------------------------

function player:getPlayerNbDeath()
return self.nbDeath
end
 
-------------------------------------------------


 
function player:printPlayerNbDeath()
print( self.name .. " is at dead " .. getPlayerNbDeath() .. " time(s)." )
end
 

-------------------------------------------------

function player:setPlayerX(newX)
self.x = newX
end
 
-------------------------------------------------

function player:getPlayerX()
return self.x
end
 
-------------------------------------------------


 
function player:printPlayerX()
print( self.name .. " is at x = " .. getPlayerX() .. " ." )
end
 
 -------------------------------------------------

function player:setPlayerY(newY)
self.y = newY
end
 
-------------------------------------------------

function player:getPlayerY()
return self.y
end
 
-------------------------------------------------


 
function player:printPlayerY()
print( self.name .. " is at y = " .. getPlayerY() .. " ." )
end
 
-------------------------------------------------
return player