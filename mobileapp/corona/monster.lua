require "camera"
require "vector2D"
local utils = require("lib.ecusson.Utils")
local CameraAwareSprite = require("camera_aware_sprite")
require "print_r"
require "arcPos"

-- error accepted when moving the monster
local accepted_error = 0.008

-------------------------------------------------
-- PRIVATE FUNCTIONS
-------------------------------------------------

local Monster = {}

-------------------------------------------------
-- PUBLIC FUNCTIONS
-------------------------------------------------

function Monster.new( pId, pSpeed, pNbDeath,arcP)   -- constructor
	local self = utils.extend(Monster)
	dbg (INFO, {"Creating monster... "})
	--Monster name / speed / number of death
	self.id = pId
	self.name ="Unknown"
	self.speed = pSpeed or 0.2
	self.nbDeath = pNDeath or 0
	self.nbKill = 0
	self.isDead = true

	--Monster current state : FROZEN / WALKING / DEAD
	self.currentState = MONSTER_FROZEN_STATE 

  self.arcPCurrent = arcP
	--Monster Sprite
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
		group = monsterLayer,
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

  
	--Monster current destination
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

function Monster:getArcPCurrent()
	return self.arcPCurrent
end

function Monster:getPos(  )
	return self.pos
end

function Monster:die()
	self.sprite:play("death")
	self.isDead = true
	return self
end

function Monster:revive()
	self.sprite:play("downstand")
	self.isDead = false
	return self
end


function Monster:setAR(arcP)
	--dbg(GAME_DBG, {"LA",arcP.arc.end1.uid,arcP.arc.end2.uid,arcP.progress})
	self.oldpos = self.pos
	local destination = arcP:getPosXY()
	self.toX=destination.x
	self.toY=destination.y
	self.pos=destination
	self.sprite:setWorldPosition(self.pos)
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
		self.currentAnimString = newAnimString
	end

end

function Monster:getCurrentStreetName()
	return self.arcPCurrent.arc.streetName
end

function Monster:destroy()
	dbg (ERRORS, {"monster:destroy()"})
	self.sprite:destroy()
end

return Monster
