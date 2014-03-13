require "camera"
require "vector2D"
local utils = require("lib.ecusson.Utils")
local CameraAwareSprite = require("camera_aware_sprite")
require "print_r"
require "arcPos"

-- error accepted when moving the player
local accepted_error = 0.008

-------------------------------------------------
-- PRIVATE FUNCTIONS
-------------------------------------------------

local Player = {}

-------------------------------------------------
-- PUBLIC FUNCTIONS
-------------------------------------------------

function Player.new( pId, pSpeed, pNbDeath,arcP)   -- constructor
	local self = utils.extend(Player)
	dbg (INFO, {"Creating player... "})
	--Player name / speed / number of death
	self.id = pId
	self.name ="Unknown"
	self.speed = pSpeed or 0.2
	self.nbDeath = pNDeath or 0
	self.nbKill = 0
	self.isDead = true

	--Player current state : FROZEN / WALKING / DEAD
	self.currentState = PLAYER_FROZEN_STATE 

  self.arcPCurrent = arcP
	--Player Sprite
	self.pos = Vector2D:new(0, 0)
	self.oldpos = Vector2D:new(0, 0)

	self.currentAnimString = "downstand"

	self.sprite = CameraAwareSprite.create {
		spriteSet = "man",
		animation = self.currentAnimString,
		anchor = "bc",
		worldPosition = self.pos,
		scale = 1,
		position = camera:worldToScreen(self.pos),
		group = playerLayer,
	}

	r = math.random()
	g = math.random()
	b = math.random()

	total = r+g+b

	r = r*255/total
	g = g*255/total
	b = b*255/total

	self.color = {r,g,b}

	self.colorSprite = CameraAwareSprite.create {
		spriteSet = "manc",
		animation = "leftwalk",
		anchor = "bc",
		worldPosition = self.pos,
		scale = 1,
		color = self.color,
		position = camera:worldToScreen(self.pos),
		group = playerLayer,
	}

	self.nodeFrom=self.arcPCurrent.arc.end1
	self.nodeTo=self.arcPCurrent.arc.end2
	self.currentArcRatio=self.arcPCurrent.progress
	-- self.currentArc=nodeF.arcs[nodeT]
	-- if(self.currentArc.end1==nodeF) then
	--     self.currentArcRatio=0
	-- else
	--     self.currentArcRatio=1
	-- end

  
	--Player current destination
	self.arcPDest = nil
	self.toX= self.pos.x
	self.toY= self.pos.y

	--nodes to go to the final destination
	self.nodes= nil
	self.nodesI=0
	self.nodesMax=0

	--???
	self.objectType = objectType

	return self
end

function Player:getArcPCurrent()
	return self.arcPCurrent
end

function Player:getPos(  )
	return self.pos
end

function Player:die()
	self.sprite:play("death")
	self.colorSprite:play("death")
	self.isDead = true
	return self
end

function Player:revive()
	self.sprite:play("downstand")
	self.colorSprite:play("downstand")
	self.isDead = false
	return self
end

function Player:saveNewNodes(nodes, arcP)
	self.nodes=nodes
	self.arcPDest=arcP
   -- self.saveNewDestination(self.nodes[1])
   if (nodes~=nil) then
		self.nodesI=1
		self.nodesMax=#nodes
		-- print (self.nodesMax .." BOUH")
		self.toX=self.nodes[1].pos.x
		self.toY=self.nodes[1].pos.y
		self.nodeTo=nodes[1]
   else
		self.nodesI=0
		self.nodesMax=0
		if (arcP ~=nil) then
			 self:goToAR(arcP)
		end
		--self.nodeTo=nil
	end
end

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


function Player:refresh()
	if(self.pos.x<= (self.toX+accepted_error) and self.pos.x>=(self.toX-accepted_error) and self.pos.y <=(self.toY+accepted_error) and  self.pos.y>=(self.toY-accepted_error)) then
		self.currentState = PLAYER_FROZEN_STATE 
		self.nodesI=self.nodesI+1

		if (self.nodesI>self.nodesMax ) then
			self.nodesI=0
			self.nodesMax=0
			if (self.arcPDest ~= nil) then
				self:goToAR(self.arcPDest)
			end
			--print_r(self.pos)
			--self.nodeFrom=self.nodeTo
			--self.nodeTo=nil

			-- self.upCurrentArc(self.nodeFrom,self.nodeTo)
		else
			self.toX=self.nodes[self.nodesI].pos.x
			self.toY=self.nodes[self.nodesI].pos.y
			self.nodeFrom=self.nodes[self.nodesI-1]
			self.nodeTo=self.nodes[self.nodesI]
			--self.upCurrentArc(self.nodeFrom,self.nodeTo)
			self:refresh()
		end
	else 
		self.currentState = PLAYER_WALKING_STATE 
		local to = Vector2D:new(self.toX, self.toY)
		local vectDir = Vector2D:new(0,0)
		local vectDir = Vector2D:Sub(to,self.pos)
		vectDir:normalize()
		-- vecteur normalisé de la direction * la vitesse * delta temps
		local tempVectDir = Vector2D:Mult(vectDir, self.speed)
		local temp = Vector2D:Add(self.pos,tempVectDir)
		vectDir:mult(self.speed)
		self.pos:add(vectDir)
		self:upCurrentArc(self.nodeFrom,self.nodeTo)


		-- self.sprite:redraw()    
		-- self.colorSprite:redraw()    
	end
end


function Player:upCurrentArc(from, to)
	if (from == nil) then
		dbg (INFO, {"from == nil"})
	elseif (to == nil) then
		dbg (INFO, {"to == nil"})
	elseif (from == to) then
		dbg (INFO, {"from == to"})
		dbg (INFO, {from.uid .."  à " .. to.uid})
	elseif (from.arcs[to] == nil) then
		dbg (INFO, {"from.arc[to] == nil"})
		dbg (INFO, {from.uid .."  à " .. to.uid})
	else 
		local dist = Vector2D:Dist(from.pos,self.pos)
		self.arcPCurrent.arc=from.arcs[to]
		if(self.arcPCurrent.arc.end1==from) then
			self.arcPCurrent.progress=(dist/self.arcPCurrent.arc.len)
		else
			self.arcPCurrent.progress=1-(dist/self.arcPCurrent.arc.len)
		end
		--print(from.uid.. " to " ..to.uid .." ratio " ..  self.currentArcRatio)
	end
end

function Player:goToAR(arcP)

	local destination = arcP:getPosXY()
	self.nodeFrom=arcP.arc.end1
	self.nodeTo=arcP.arc.end2
	self.toX=destination.x
	self.toY=destination.y
	self.arcPDest = nil
end

function Player:setAR(arcP)
	self.oldpos = self.pos
	local destination = arcP:getPosXY()
	self.toX=destination.x
	self.toY=destination.y
	self.pos=destination
	self.sprite:setWorldPosition(self.pos)
	self.colorSprite:setWorldPosition(self.pos)
	self.arcPCurrent = arcP

	-- update sprites
	local myCuteDir = Vector2D:Sub(self.pos, self.oldpos)
	if myCuteDir.x==0 and myCuteDir.y==0 then
		self.animString = "stand"
	else
		self.animString = "walk"
		if math.abs(myCuteDir.x) > math.abs(myCuteDir.y) then
			if myCuteDir.x > 0 then -- right
				self.dirString = "right"
			else                    -- left
				self.dirString = "left"
			end
		else
			if myCuteDir.y < 0 then -- up
				self.dirString = "up"
			else                    -- down
				self.dirString = "down"
			end
		end
	end

	local newAnimString = self.dirString..self.animString
	if self.currentAnimString ~= newAnimString then
		self.sprite:play(newAnimString)
		self.colorSprite:play(newAnimString)
		self.currentAnimString = newAnimString
	end

end

function Player:getCurrentStreetName()
	return self.arcPCurrent.arc.streetName
end

function Player:destroy()
	dbg (ERRORS, {"player:destroy()"})
	self.sprite:destroy()
end

return Player
