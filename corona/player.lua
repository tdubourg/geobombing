-------------------------------------------------
--
-- player.lua
--
--
-------------------------------------------------
require "camera"
local physics = require( "physics" )

local player = {}
local player_mt = { __index = player }	-- metatable
-- The following constants define the widht and height of the player in percentage of the screen so that the player
-- takes the same amount of space on a small and on a big screen
PLAYER_WIDTH_IN_PERCENTAGE = 10
PLAYER_HEIGHT_IN_PERCENTAGE = 10

PLAYER_SPRITE_RAW_WIDTH = 237
PLAYER_SPRITE_RAW_HEIGHT = 513
PLAYER_SPRITESHEET_WIDTH = 2037
PLAYER_SPRITESHEET_HEIGHT = 513

PLAYER_DEAD_STATE = 42
PLAYER_WALKING_STATE = 43
PLAYER_FROZE_STATE = 44

spriteWidth = 25
spriteHeight = 25

-------------------------------------------------
-- PRIVATE FUNCTIONS
-------------------------------------------------

local PLAYER_SPRITE_SEQUENCE_DATA = {
{ name="normal", start=1, count=8, time=400}--,
--{ name="dead", start=9, count=4, time=400}
}



-------------------------------------------------
-- PUBLIC FUNCTIONS
-------------------------------------------------

function player.new( pName, pSpeed, pNbDeath)	-- constructor
	local newPlayer = {}
	setmetatable( newPlayer, player_mt )
	newPlayer.name = pName or "Unnamed"
	newPlayer.speed = pSpeed or 0.2
	newPlayer.nbDeath = pNDeath or 0
	newPlayer.currentState = PLAYER_FROZE_STATE 
	newPlayer.drawable=nil
    

	--newPlayer.drawable = display.newImageRect( "images/bomberman.jpg",25,25)

	local imageSheet = graphics.newImageSheet("images/spritesheet.png", {width = PLAYER_SPRITE_RAW_WIDTH,
	height = PLAYER_SPRITE_RAW_HEIGHT, numFrames = 7})--, sheetContentWidth=PLAYER_SPRITESHEET_WIDTH, sheetContentHeight=PLAYER_SPRITESHEET_HEIGHT})

newPlayer.drawable = display.newSprite(imageSheet, PLAYER_SPRITE_SEQUENCE_DATA)

newPlayer.drawable.x = display.contentWidth/2
newPlayer.drawable.y = display.contentHeight/2
newPlayer.toX=newPlayer.drawable.x
newPlayer.toY= newPlayer.drawable.y
-- newPlayer.x = display.contentCenterX
-- newPlayer.y = display.contentCenterY

newPlayer.objectType = objectType
newPlayer.drawable.objectType = objectType
newPlayer.drawable.playerObject = newPlayer
newPlayer.drawable.width, newPlayer.drawable.height = spriteWidth, spriteHeight
newPlayer.drawable.xScale = spriteWidth / PLAYER_SPRITE_RAW_WIDTH
    newPlayer.drawable.yScale = spriteHeight / PLAYER_SPRITE_RAW_HEIGHT--signof(gravityScale) * spriteHeight / PLAYER_SPRITE_RAW_HEIGHT
    addBodyWithCutCornersRectangle(newPlayer.drawable, 30)

    newPlayer.drawable:play()
    newPlayer.drawable.gravityScale = gravityScale

    cameraGroup:insert(newPlayer.drawable)
    return newPlayer
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

-- @function addBodyWithCutCornersRectangle
-- will add a DYNAMIC body to the physics engine after cutting the corners of the displayObject rectangle
-- it will cut the corners at percentageOfCut percentage of the corner (percentageOfCut = 10 and displayObject has a
-- widht of 200 would mean for instance that we will transform the 200 edge into a 200-2*200*10/100 edge (cutting
-- corners on both sides at 10 percent...)
-- with a density of 1 and a friction of 1
function addBodyWithCutCornersRectangle(displayObject, percentageOfCut)
    -- If the user is stupid enough to give 0, avoid tue division by zero by falling back to a percentage of 10
    if percentageOfCut == 0 or percentageOfCut == nil then
    	percentageOfCut = 10
    end
    h, w = displayObject.height, displayObject.width

    local collisionFilter = { categoryBits = 2, maskBits = 5 } -- collides with player only

    physics.addBody(displayObject, "dynamic", { shape = {
        -- shape is counter-clockwisedly descripted
        -- bottom left corner --
        -w/2, -h/2 + h*percentageOfCut/100,
        -w/2 + w*percentageOfCut/100, -h/2,
        -- bottom right corner --
        w/2 - w*percentageOfCut/100, -h/2,
        w/2, -h/2 + h*percentageOfCut/100,
        -- top right corner --
        w/2, h/2 - h*percentageOfCut/100,
        w/2 - w*percentageOfCut/100, h/2,
        -- top left corner --
        -w/2 + w*percentageOfCut/100, h/2,
        -w/2, h/2 - h*percentageOfCut/100,
        }, filter=collisionFilter, friction = 0.0})
    displayObject.isFixedRotation = true
end

function player:goTo(nodes)
  for i=1,#nodes do
 		-- lookAt(worldPos)
         local from = Vector2D:new(self.drawable.x, self.drawable.y)
         local dist =from:Dist(from, nodes[i].pos)
    --speed=dist/time
    transition.to(self.drawable,{time=dist/self.speed,x=nodes[i].pos.x,y=nodes[i].pos.y})
end
	-- -- lookAt(worldPos)
 --  	local from = Vector2D:new(self.drawable.x, self.drawable.y)
 --  	local dist =from:Dist(from, nodes[1].pos)
 --    --speed=dist/time
 -- transition.to(self.drawable,{time=dist/self.speed,x=nodes[1].pos.x,y=nodes[1].pos.y})
end

function player:saveNewDestination(e)
    
    local screenPos = Vector2D:new(e.x, e.y)
    local  worldPos = screenToWorld(screenPos)
    self.toX=worldPos.x
    self.toY=worldPos.y
end


function player:refresh()

    if(self.drawable.x==self.toX and self.drawable.y == self.toY) then
        self.currentState = PLAYER_FROZE_STATE 
    else 
     self.currentState = PLAYER_WALKING_STATE 
     local from = Vector2D:new(self.drawable.x, self.drawable.y)
     local to = Vector2D:new(self.toX, self.toY)
     local vectDir = Vector2D:new(0,0)
     vectDir = Vector2D:Sub(to,from)
     vectDir:normalize()
  -- vecteur normalisé de la direction * la vitesse * delta temps
  self.drawable.x= self.drawable.x+(vectDir.x*self.speed)
  self.drawable.y= self.drawable.y+(vectDir.y*self.speed)
end

end


return player