require "camera"
require "vector2D"
local utils = require("lib.ecusson.Utils")
local CameraAwareSprite = require("camera_aware_sprite")
require "print_r"
require "arcPos"
local Deque = require "deque"

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
	dbg(Y,{"ID is", self.id})
	self.color = idToColor(self.id)

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
	local delta = 0.00001 -- TODO: Move this constant and document it, cf server for now
	local distToWalk = 0.1/30.0 -- TODO: Move this constant and document it, cf server for now

	if (self.arcPCurrent == nil) then
		dbg(PREDICTION_DBG, {"Not enough information to run prediction: arcPCurrent is nil"})
		return
	elseif (self.predictionDestination == nil) then
		dbg(PREDICTION_DBG, {"Not enough information to run prediction: self.predictionDestination is nil"})
		return
	end
	if (self.arcPCurrent:equals(self.predictionDestination, delta)) then
		dbg(PREDICTION_DBG, {"STANDING STILL (up to precision), NOT RUNNING PREDICTION"})
		return
	end
	dbg(PREDICTION_DBG, {"self.arcPCurrent=", self.arcPCurrent.arc.end1.uid, self.arcPCurrent.arc.end2.uid, self.arcPCurrent.progress})
	dbg(PREDICTION_DBG, {"self.predictionDestination=", self.predictionDestination.arc.end1.uid, self.predictionDestination.arc.end2.uid, self.predictionDestination.progress})
	dbg(PREDICTION_DBG, {"Running prediction!"})

	-- local currentArc = self.arcPCurrent.arc
	-- local currentArcDist = self.arcPCurrent.dist
	-- local targetArcDist = self.predictionDestination.progress
	local copyOfArcPCurrent = self.arcPCurrent:clone()
	if (self.currPredictionNode == nil) then
		-- self.currPredictionNode = Deque.popleft(self.predictionNodes)
		if (self.predictionNodes.length > 0) then
			self.nextPredictionNode = Deque.popleft(self.predictionNodes)
		end
	end		
	while (distToWalk > delta) do
		-- Iterate until we have walked the entire distance we can walk in a single round
		-- This has to be done in multiple iterations when we need to change arc 
		-- (the distance to walk is > to the distance until the end of the current arc)

		-- Distance between current pos and the next destination (next node on path)
		local distToNextDest
		if (self.predictionNodes.length == 0) then
			-- If we are on the final arc of the path, the distance is the final position
			-- on the arc, minus the current position
			copyOfArcPCurrent:addDistTowards(distToWalk, self.nextPredictionNode)
			distToWalk = 0 -- Either we walked all in the current arc, or we could have walked more, but we stoppped, in all cases, we do not want to walk more than once on final arc!
			-- distToNextDest = targetArcDist - currentArcDist
			dbg(PREDICTION_DBG, {"We are moving on the final arc."})
		else
			-- If we are not on the final arc of the path, the distance to the next node is
			-- the total length of current arc minus the current position on this arc
			local remainder_dist = copyOfArcPCurrent:addDistTowards(distToWalk, self.nextPredictionNode)
			if (remainder_dist ~= nil) then
				-- There is still some distance to walk, and it was returned by the addDistTowards
				distToWalk = remainder_dist
				dbg(PREDICTION_DBG, {"Time to switch arc"})
				self.currPredictionNode = self.nextPredictionNode
				self.nextPredictionNode = Deque.popleft(self.predictionNodes)
				dbg(PREDICTION_DBG, {"self.nextPredictionNode=", self.nextPredictionNode.uid})
				copyOfArcPCurrent = currentMap:createArcPos(self.currPredictionNode, self.nextPredictionNode, 0)
				if (copyOfArcPCurrent) then
					dbg(PREDICTION_DBG, {"Switching to arc (", copyOfArcPCurrent.arc.end1.uid, copyOfArcPCurrent.arc.end2.uid, ")"})
				else
					dbg(PREDICTION_DBG, {"#########################################################################################"})
					dbg(PREDICTION_DBG, {"#########################################################################################"})
					dbg(PREDICTION_DBG, {"[Game Model Error]: couldn't find a path from node", self.currPredictionNode.uid, "to node", nextNode.uid})
					dbg(PREDICTION_DBG, {"#########################################################################################"})
					dbg(PREDICTION_DBG, {"#########################################################################################"})
				end
			end
			dbg(PREDICTION_DBG, {"Not final arc, distToNextDest=", distToNextDest})
		end
	end
	dbg(PREDICTION_DBG, {"Prediction is setting AR to", copyOfArcPCurrent.arc.end1.uid, ",", copyOfArcPCurrent.arc.end2.uid, ",", copyOfArcPCurrent.progress})
	self:setAR(copyOfArcPCurrent)
	
	-- local proximity = Vector2D:Sub(self.pos, currentDestination)
	-- dbg(PREDICTION_DBG, {"Proximity is:", proximity})
	-- dbg(PREDICTION_DBG, {"accepted_error:", accepted_error})
	-- if (proximity <= accepted_error) then
	-- 	Deque.popleft(self.predictionNodes) -- we reached this node, pop it
	-- 	currentDestination = Deque.first(self.predictionNodes) -- and change the destination
	-- end
	-- -- TODO: Differentiate between self.pos, the actual pos sent by the server and self.predictedPos, the pos predicted by the client, AND USE PREDICTED POS FOR DISPLAY
	-- -- First: grab the Vecto2D of destination and store it in destinationV2d
	-- local destinationV2d = nil
	-- -- Then, updating the predictedPos to the new one, after adding the speed of the player to the previous predicted pos
	-- self.predictedPos:add(Vector2D.Sub(destinationV2d, self.predictedPos))
	-- update_player_position()
end

function Player:setPredictionNodes( nodes )
	dbg(PREDICTION_DBG, {"Setting prediction nodes"})
	self.predictionNodes = Deque.new()
	self.currPredictionNode = nil
	self.nextPredictionNode = nil
	if (nodes == nil) then
		return
	end
	for i,v in ipairs(nodes) do
		dbg(PREDICTION_DBG, {"Adding node", tostring(i), v.uid, "to predictionNodes"})
		Deque.pushright(self.predictionNodes, v)
	end
end

function Player:setPredictionDestination(arcP)
	dbg(PREDICTION_DBG, {"Setting prediction destination to", arcP.arc.end1.uid, arcP.arc.end2.uid, arcP.progress})
	self.predictionDestination = arcP
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

	if not self.isDead then
		local newAnimString = self.dirString..self.animString
		if self.currentAnimString ~= newAnimString then
			self.sprite:play(newAnimString)
			self.colorSprite:play(newAnimString)
			self.currentAnimString = newAnimString
		end
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
