-------------------------------------------------
--
-- player.lua
--
--
-------------------------------------------------
require "camera"
require "vector2D"
local utils = require("lib.ecusson.utils")
local CameraAwareSprite = require("camera_aware_sprite")

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
local accepted_error = 0.005

-------------------------------------------------
-- PRIVATE FUNCTIONS
-------------------------------------------------

local PLAYER_SPRITE_SEQUENCE_DATA = {
{ name="normal", start=1, count=7, time=400}--,
--{ name="dead", start=9, count=4, time=400}
}

local Player = {}

-------------------------------------------------
-- PUBLIC FUNCTIONS
-------------------------------------------------

function Player.create( pName, pSpeed, pNbDeath)	-- constructor
	local self = utils.extend(Player)
    print ( "Creating player... " )
    --Player name / speed / number of death
    self.name = pName or "Unnamed"
    self.speed = pSpeed or 0.2
    self.nbDeath = pNDeath or 0

    --Player current state : FROZEN / WALKING / DEAD
    self.currentState = PLAYER_FROZEN_STATE 

    --Player Sprite
    self.pos = Vector2D:new(0, 0)
    print ("worldToScreen:", camera:worldToScreen(self.pos).x, camera:worldToScreen(self.pos).y)
    self.sprite = CameraAwareSprite.create {
        spriteSet = "bonhomme",
        animation = "idle",
        worldPosition = self.pos,
        position = camera:worldToScreen(self.pos),
    }
 --    local imageSheet = graphics.newImageSheet("images/spritesheet.png", {width = PLAYER_SPRITE_RAW_WIDTH,
	-- height = PLAYER_SPRITE_RAW_HEIGHT, numFrames = 7})--, sheetContentWidth=PLAYER_SPRITESHEET_WIDTH, sheetContentHeight=PLAYER_SPRITESHEET_HEIGHT})
 --    self.drawable = display.newSprite(imageSheet, PLAYER_SPRITE_SEQUENCE_DATA)

    --Player current position
    -- self.drawable.x = 0
    -- self.drawable.y = 0

    --Player current destination
    self.toX= self.pos.x
    self.toY= self.pos.y

    --nodes to go to the final destination
    self.nodes= nil
    self.nodesI=0
    self.nodesMax=0

    --???
    self.objectType = objectType
    -- self.drawable.objectType = objectType
    -- self.drawable.playerObject = self

    -- setting player sprite resize
    -- self.drawable.width, self.drawable.height = spriteWidth, spriteHeight
    -- self.drawable.xScale = spriteWidth / PLAYER_SPRITE_RAW_WIDTH
    -- self.drawable.yScale = spriteHeight / PLAYER_SPRITE_RAW_HEIGHT--signof(gravityScale) * spriteHeight / PLAYER_SPRITE_RAW_HEIGHT

    --??
    -- addBodyWithCutCornersRectangle(self.drawable, 30)

    -- playing the sprite
    -- self.drawable:play()

    --???
    -- self.drawable.gravityScale = gravityScale

    -------------
    self.nodeFrom=nil
    self.nodeTo=nil
    self.currentArc=nil
    self.currentArcRatio=0

    -- insert in camera group
    --cameraGroup:insert(self.drawable)
     return self
end

function Player:getPos(  )
    return self.pos
end

-------------------------------------------------

function Player:printPlayerSpeed()
	print( self.name .. " is at speed " .. self.speed .. " ." )
end

-------------------------------------------------

function Player:setPlayerNbDeath(newNbDeath)
	self.nbDeath = newNbDeath
end

-------------------------------------------------

function Player:printPlayerNbDeath()
	print( self.name .. " is at dead " .. self.nbDeath .. " time(s)." )
end


-------------------------------------------------

function Player:printPlayerX()
	print( self.name .. " is at x = " .. self.sprite.position.x .. " ." )
end

 -------------------------------------------------

 function Player:printPlayerY()
 	print( self.name .. " is at y = " .. self.sprite.position.y .. " ." )
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

function Player:saveNewNodes(nodes)
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




function Player:refreshPos()
    self.sprite:setWorldPosition(self.pos)
    self:upCurrentArc(self.nodeFrom,self.nodeTo)
end


function Player:saveNewDestination(e)

    local screenPos = Vector2D:new(e.x, e.y)
    local worldPos = screenToWorld(screenPos)
    self.toX=worldPos.x
    self.toY=worldPos.y

end

function Player:saveNewDestinationVect(e)

    self.toX=e.x
    self.toY=e.y

end

function Player:saveNewDestinationNode(e)

    self.toX=e.pos.x
    self.toY=e.pos.y

end

-- part of the contract with Camera
-- function Player:redraw()
--   local newPos = camera:worldToScreen(self.pos)
--   self.drawable.x = newPos.x
--   self.drawable.y = newPos.y
-- end

function Player:refresh()

    if(self.sprite.position.x<= (self.toX+accepted_error) and self.sprite.position.x>=(self.toX-accepted_error) and self.sprite.position.y <=(self.toY+accepted_error) and  self.sprite.position.y>=(self.toY-accepted_error)) then
        self.currentState = PLAYER_FROZEN_STATE 
        self.nodesI=self.nodesI+1
        if (self.nodesI>self.nodesMax) then
            self.nodesI=0
            self.nodesMax=0

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
        -- if (temp.x<= (100+accepted_error) and temp.x>=(100-accepted_error) and temp.y <=(20+accepted_error) and  temp.y>=(20-accepted_error)) then
        --     self.currentState = PLAYER_FROZEN_STATE 
        --     self.nodesI=0
        --     self.nodesMax=0
        --     accepted_error = 1
        --     -- check if there is a bonus
        --     elseif (temp.x<= (20+accepted_error) and temp.x>=(20-accepted_error) and temp.y <=(200+accepted_error) and  temp.y>=(200-accepted_error)) then
        --         self.speed= self.speed+1
        --         vectDir:mult(self.speed)
        --         self.pos:add(vectDir)
        --         self:refreshPos()
        --         accepted_error = accepted_error +1

        --     else
        vectDir:mult(self.speed)
        self.pos:add(vectDir)
        self:refreshPos()

            -- end
            
        end

    end


function Player:upCurrentArc(from, to)
    if (from == nil) then
        -- print ("from == nil")
    elseif (to == nil) then
        print ("to == nil")
    elseif (from.arcs[to] == nil) then
        print ("from.arc[to] == nil")    
    else 
        local dist = Vector2D:Dist(from.pos,self.pos)
        self.currentArc=from.arcs[to]
        if(self.currentArc.end1==from) then
            self.currentArcRatio=(dist/self.currentArc.len)*100
        else
            self.currentArcRatio=100-(dist/self.currentArc.len)*100
        end
        print(from.uid.. " to " ..to.uid .." ratio" ..  self.currentArcRatio)
    end
end

function Player:goToAR(arc,ratio)

    local from = arc.end1.pos
    self.nodeFrom = arc.end1
    print(from.x .. " , " ..from.y )
    local to = arc.end2.pos
    self.nodeTo = arc.end2
    print(to.x .. " , " ..to.y )
    local vectDir = Vector2D:new(0,0)
    vectDir = Vector2D:Sub(to,from)
    print(vectDir.x .. " , " ..vectDir.y )
    vectDir:mult(ratio/100)
    print(vectDir.x .. " , " ..vectDir.y )
    local finalPos = Vector2D:Add(from,vectDir)
    print(from.x .. " , " ..from.y )
    print(" ratio" ..  ratio)
    self.toX=from.x
    self.toY=from.y
    
end

function Player:setAR(arc,ratio)
    local from = arc.end1.pos
    local to = arc.end2.pos
    local vectDir = Vector2D:new(0,0)
    vectDir = Vector2D:Sub(to,from)
    vectDir:mult(ratio/100)
    local destination = Vector2D:Add(from, vectDir)
    self.pos=destination
end

return Player
