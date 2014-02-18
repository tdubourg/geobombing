-------------------------------------------------
--
-- player.lua
--
--
-------------------------------------------------
require "camera"
require "vector2D"
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
PLAYER_FROZEN_STATE = 44

spriteWidth = 25
spriteHeight = 25

-- error accepted when moving the player
err = 1

-------------------------------------------------
-- PRIVATE FUNCTIONS
-------------------------------------------------

local PLAYER_SPRITE_SEQUENCE_DATA = {
{ name="normal", start=1, count=7, time=400}--,
--{ name="dead", start=9, count=4, time=400}
}



-------------------------------------------------
-- PUBLIC FUNCTIONS
-------------------------------------------------

function player.new( pName, pSpeed, pNbDeath)	-- constructor
	local newPlayer = {}
	setmetatable( newPlayer, player_mt )
    --Player name / speed / number of death
    newPlayer.name = pName or "Unnamed"
    newPlayer.speed = pSpeed or 0.2
    newPlayer.nbDeath = pNDeath or 0

    --Player current state : FROZEN / WALKING / DEAD
    newPlayer.currentState = PLAYER_FROZEN_STATE 

    --Player Sprite
    newPlayer.drawable=nil
    local imageSheet = graphics.newImageSheet("images/spritesheet.png", {width = PLAYER_SPRITE_RAW_WIDTH,
	height = PLAYER_SPRITE_RAW_HEIGHT, numFrames = 7})--, sheetContentWidth=PLAYER_SPRITESHEET_WIDTH, sheetContentHeight=PLAYER_SPRITESHEET_HEIGHT})
newPlayer.drawable = display.newSprite(imageSheet, PLAYER_SPRITE_SEQUENCE_DATA)

    --Player current position
    newPlayer.drawable.x = 0
    newPlayer.drawable.y = 0

    newPlayer.pos = Vector2D:new(newPlayer.drawable.x, newPlayer.drawable.y)

    --Player current destination
    newPlayer.toX=newPlayer.drawable.x
    newPlayer.toY= newPlayer.drawable.y

    --nodes to go to the final destination
    newPlayer.nodes= nil
    newPlayer.nodesI=0
    newPlayer.nodesMax=0

    --???
    newPlayer.objectType = objectType
    newPlayer.drawable.objectType = objectType
    newPlayer.drawable.playerObject = newPlayer

    -- setting player sprite resize
    newPlayer.drawable.width, newPlayer.drawable.height = spriteWidth, spriteHeight
    newPlayer.drawable.xScale = spriteWidth / PLAYER_SPRITE_RAW_WIDTH
    newPlayer.drawable.yScale = spriteHeight / PLAYER_SPRITE_RAW_HEIGHT--signof(gravityScale) * spriteHeight / PLAYER_SPRITE_RAW_HEIGHT

    --??
    addBodyWithCutCornersRectangle(newPlayer.drawable, 30)

    -- playing the sprite
    newPlayer.drawable:play()

    --???
    newPlayer.drawable.gravityScale = gravityScale

    -------------
    newPlayer.nodeFrom=nil
    newPlayer.nodeTo=nil
    newPlayer.currentArc=nil
    newPlayer.currentArcRatio=0

    -- insert in camera group
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

function player:saveNewNodes(nodes)
    self.nodes=nodes
    -- print( self.nodes[1].pos.x .. ", " .. self.nodes[1].pos.y .. " ." )
    -- print( self.nodes[2].pos.x .. ", " .. self.nodes[2].pos.y .. " ." )
   -- self.saveNewDestination(self.nodes[1])
   if (nodes~=nil) then
        self.nodesI=1
        self.nodesMax=#nodes
        print (self.nodesMax)
        self.toX=self.nodes[1].pos.x
        self.toY=self.nodes[1].pos.y
        self.nodeTo=nodes[1]
    else
        self.nodesI=0
        self.nodesMax=0
        self.nodeTo=nil
    end
end




function player:refreshPos()
    self.drawable.x=self.pos.x
    self.drawable.y = self.pos.y
    self:upCurrentArc(self.nodeFrom,self.nodeTo)
end


function player:saveNewDestination(e)

    local screenPos = Vector2D:new(e.x, e.y)
    local  worldPos = screenToWorld(screenPos)
    self.toX=worldPos.x
    self.toY=worldPos.y

end

function player:saveNewDestinationVect(e)

    self.toX=e.x
    self.toY=e.y

end

function player:saveNewDestinationNode(e)

    self.toX=e.pos.x
    self.toY=e.pos.y

end


function player:refresh()

    if(self.drawable.x<= (self.toX+err) and self.drawable.x>=(self.toX-err) and self.drawable.y <=(self.toY+err) and  self.drawable.y>=(self.toY-err)) then
        self.currentState = PLAYER_FROZEN_STATE 
        self.nodesI=self.nodesI+1
        if (self.nodesI>self.nodesMax) then
            self.nodesI=0
            self.nodesMax=0
            err = 1

            self.nodeFrom=self.nodeTo
            self.nodeTo=nil

            -- self.upCurrentArc(self.nodeFrom,self.nodeTo)


        else
            self.nodeFrom=self.nodes[self.nodesI-1]
            self.toX=self.nodes[self.nodesI].pos.x
            self.toY=self.nodes[self.nodesI].pos.y
            self.nodeTo=self.nodes[self.nodesI]
            --self.upCurrentArc(self.nodeFrom,self.nodeTo)
            self:refresh()

        end

    else 
       self.currentState = PLAYER_WALKING_STATE 
       local to = Vector2D:new(self.toX, self.toY)
       local vectDir = Vector2D:new(0,0)
       vectDir = Vector2D:Sub(to,self.pos)
       vectDir:normalize()
        -- vecteur normalisé de la direction * la vitesse * delta temps

        tempVectDir = Vector2D:Mult(vectDir, self.speed)
        -- check if there is an obstacle
        temp = Vector2D:Add(self.pos,tempVectDir)
        -- if (temp.x<= (100+err) and temp.x>=(100-err) and temp.y <=(20+err) and  temp.y>=(20-err)) then
        --     self.currentState = PLAYER_FROZEN_STATE 
        --     self.nodesI=0
        --     self.nodesMax=0
        --     err = 1
        --     -- check if there is a bonus
        --     elseif (temp.x<= (20+err) and temp.x>=(20-err) and temp.y <=(200+err) and  temp.y>=(200-err)) then
        --         self.speed= self.speed+1
        --         vectDir:mult(self.speed)
        --         self.pos:add(vectDir)
        --         self:refreshPos()
        --         err = err +1

        --     else
        vectDir:mult(self.speed)
        self.pos:add(vectDir)
        self:refreshPos()

            -- end
            
        end

    end


function player:upCurrentArc(from, to)
        if (from == nil) then
            print ("from == nil")
        end
        if (to == nil) then
            print ("end == nil")
         end
        if (from.arcs[to] == 0) then
            print ("from.arc[to] == nil")    
        end
        local dist = Vector2D:Dist(from.pos,self.pos)
        self.currentArc=from.arcs[to]
        if(self.currentArc.end1==from) then
        self.currentArcRatio=(dist/self.currentArc.len)*100
    else
        self.currentArcRatio=100-(dist/self.currentArc.len)*100
    end
    print(from.uid.. " to " ..to.uid .." ratio" ..  self.currentArcRatio)
end

function player:goToAR(arc,ratio)
    local from = arc.end1.pos
    print(from.x .. " , " ..from.y )
    local to = arc.end2.pos
    print(to.x .. " , " ..to.y )
    local vectDir = Vector2D:new(0,0)
    vectDir = Vector2D:Sub(to,from)
    print(vectDir.x .. " , " ..vectDir.y )
    vectDir:mult(ratio/100)
    print(vectDir.x .. " , " ..vectDir.y )
    from:add(vectDir)
    print(from.x .. " , " ..from.y )
    print(" ratio" ..  ratio)
    self.toX=from.x
    self.toY=from.y
    
end

function player:setAR(arc,ratio)
    local from = arc.end1.pos
    local to = arc.end2.pos
    local vectDir = Vector2D:new(0,0)
    vectDir = Vector2D:Sub(to,from)
    vectDir:mult(ratio/100)
    local destination = Vector2D:Add(from, vectDir)
    self.pos=destination
end

return player