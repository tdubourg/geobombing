require "camera"
require "vector2D"
local utils = require("lib.ecusson.utils")
local CameraAwareSprite = require("camera_aware_sprite")
require "print_r"
require "arcPos"

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
--local accepted_error = 0.005

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

function Player.new( pId, pSpeed, pNbDeath,arcP)   -- constructor
	local self = utils.extend(Player)
    print ( "Creating player... " )
    --Player name / speed / number of death
    self.id = pId or 0
    self.speed = pSpeed or 0.2
    self.nbDeath = pNDeath or 0

    --Player current state : FROZEN / WALKING / DEAD
    self.currentState = PLAYER_FROZEN_STATE 

  self.arcPCurrent = arcP
    --Player Sprite
    self.pos = Vector2D:new(0, 0)
    print ("worldToScreen:", camera:worldToScreen(self.pos).x, camera:worldToScreen(self.pos).y)
    self.sprite = CameraAwareSprite.create {
        spriteSet = "bonhomme",
        animation = "idle",
        worldPosition = self.pos,
        scale = 0.4,
        position = camera:worldToScreen(self.pos),
    }

    --self.nodeFrom=nodeF
    --self.nodeTo=nodeT
    -- self.currentArc=nodeF.arcs[nodeT]
    -- if(self.currentArc.end1==nodeF) then
    --     self.currentArcRatio=0
    -- else
    --     self.currentArcRatio=1
    -- end

  
    --Player current destination
    -- self.arcPDest = nil
    -- self.toX= self.pos.x
    -- self.toY= self.pos.y

    --nodes to go to the final destination
    -- self.nodes= nil
    -- self.nodesI=0
    -- self.nodesMax=0

    --???
    self.objectType = objectType

    return self
end

function Player:getPos(  )
    return self.pos
end


-- function Player:saveNewNodes(nodes)
--     self.nodes=nodes
--     -- print( self.nodes[1].pos.x .. ", " .. self.nodes[1].pos.y .. " ." )
--     -- print( self.nodes[2].pos.x .. ", " .. self.nodes[2].pos.y .. " ." )
--    -- self.saveNewDestination(self.nodes[1])
--    if (nodes~=nil) then
--         self.nodesI=1
--         self.nodesMax=#nodes
--         -- print (self.nodesMax .." BOUH")
--         self.toX=self.nodes[1].pos.x
--         self.toY=self.nodes[1].pos.y
--         self.nodeTo=nodes[1]
--    else
--         self.nodesI=0
--         self.nodesMax=0
--         --self.nodeTo=nil
--     end
-- end

-- function Player:saveNewDestination(e)

--     local screenPos = Vector2D:new(e.x, e.y)
--     local worldPos = screenToWorld(screenPos)
--     self.toX=worldPos.x
--     self.toY=worldPos.y

-- end

-- function Player:saveNewDestinationVect(e)

--     self.toX=e.x
--     self.toY=e.y

-- end

-- function Player:saveNewDestinationNode(e)

--     self.toX=e.pos.x
--     self.toY=e.pos.y 

-- end


-- function Player:refresh()

--     if(self.pos.x<= (self.toX+accepted_error) and self.pos.x>=(self.toX-accepted_error) and self.pos.y <=(self.toY+accepted_error) and  self.pos.y>=(self.toY-accepted_error)) then
--         self.currentState = PLAYER_FROZEN_STATE 
--         self.nodesI=self.nodesI+1

--         if (self.nodesI>self.nodesMax) then
--             self.nodesI=0
--             self.nodesMax=0
--             if (self.arcPDest ~= nil) then
--                 self:goToAR(self.arcPDest)
--             end
--             --print_r(self.pos)
--             --self.nodeFrom=self.nodeTo
--             --self.nodeTo=nil

--             -- self.upCurrentArc(self.nodeFrom,self.nodeTo)
--         else
--             self.toX=self.nodes[self.nodesI].pos.x
--             self.toY=self.nodes[self.nodesI].pos.y
--             self.nodeFrom=self.nodes[self.nodesI-1]
--             self.nodeTo=self.nodes[self.nodesI]
--             --self.upCurrentArc(self.nodeFrom,self.nodeTo)
--             self:refresh()
--         end
--     else 
--         self.currentState = PLAYER_WALKING_STATE 
--         local to = Vector2D:new(self.toX, self.toY)
--         local vectDir = Vector2D:new(0,0)
--         vectDir = Vector2D:Sub(to,self.pos)
--         vectDir:normalize()
--         -- vecteur normalisé de la direction * la vitesse * delta temps
--         tempVectDir = Vector2D:Mult(vectDir, self.speed)
--         temp = Vector2D:Add(self.pos,tempVectDir)
--         vectDir:mult(self.speed)
--         self.pos:add(vectDir)
--         self:upCurrentArc(self.nodeFrom,self.nodeTo)
--         self.sprite:redraw()    
--     end
-- end


-- function Player:upCurrentArc(from, to)
--     if (from == nil) then
--         -- print ("from == nil")
--     elseif (to == nil) then
--         print ("to == nil")
--     elseif (from == to) then
--         print ("from == to") 
--     elseif (from.arcs[to] == nil) then
--         print ("from.arc[to] == nil") 
--         print (from.uid .."  à " .. to.uid)
--     else 
--         local dist = Vector2D:Dist(from.pos,self.pos)
--         self.currentArc=from.arcs[to]
--         if(self.currentArc.end1==from) then
--             self.currentArcRatio=(dist/self.currentArc.len)
--         else
--             self.currentArcRatio=1-(dist/self.currentArc.len)
--         end
--         --print(from.uid.. " to " ..to.uid .." ratio " ..  self.currentArcRatio)
--     end
-- end

-- function Player:goToAR(arcP)

--     local destination = arcP:getPosXY()
--     self.toX=destination.x
--     self.toY=destination.y
--     self.arcPDest = nil
--     print("ICI")
    
-- end

function Player:setAR(arcP)

    local destination = arcP:getPosXY()
    -- self.toX=destination.x
    -- self.toY=destination.y
    self.pos=destination
    self.sprite:setWorldPosition(self.pos)
    self.arcPCurrent = arcP
end

return Player
