Vector2D = {}
 
function Vector2D:new(x, y)  
	local object = { x = x, y = y }
	setmetatable(object, { __index = Vector2D })  
	return object
end

function v2FromJSON(jsonVect)
	return Vector2D:new(jsonVect["x"], jsonVect["y"])
end
 
function Vector2D:copy()
	return Vector2D:new(self.x, self.y)
end
 
function Vector2D:magnitude()
	return math.sqrt(self.x^2 + self.y^2)
end
 
function Vector2D:normalize()
	local temp
	temp = self:magnitude()
	if temp > 0 then
		self.x = self.x / temp
		self.y = self.y / temp
	end
	return self -- alows chaining
end
 
function Vector2D:abs()
	self.x = math.abs(self.x)
	self.y = math.abs(self.y)
	return self -- alows chaining
end

function Vector2D:limit(l)
	if self.x > l then
		self.x = l		
	end
	
	if self.y > l then
		self.y = l		
	end
	return self -- alows chaining
end
 
function Vector2D:equals(vec)
	if self.x == vec.x and self.y == vec.y then
		return true
	else
		return false
	end
end
 
function Vector2D:add(vec)
	self.x = self.x + vec.x
	self.y = self.y + vec.y
	return self -- alows chaining
end
 
function Vector2D:sub(vec)
	self.x = self.x - vec.x
	self.y = self.y - vec.y
	return self -- alows chaining
end
 
function Vector2D:mult(s)
	self.x = self.x * s
	self.y = self.y * s
	return self -- alows chaining
end
 
function Vector2D:div(s)
	self.x = self.x / s
	self.y = self.y / s
	return self -- alows chaining
end
 
function Vector2D:dot(vec)
	return self.x * vec.x + self.y * vec.y
end
 
function Vector2D:dist(vec2)
	local dx = (vec2.x - self.x)
	local dy = (vec2.y - self.y)
	return math.sqrt( dx*dx + dy*dy )
end

function Vector2D:distSquared(vec2)
	local dx = (vec2.x - self.x)
	local dy = (vec2.y - self.y)
	return dx*dx + dy*dy
end
 
-- Class Methods
 
function Vector2D:Abs(vect)
	return vect:copy():abs()
end

function Vector2D:Normalize(vec)	
	local tempVec = Vector2D:new(vec.x,vec.y)
	local temp
	temp = tempVec:magnitude()
	if temp > 0 then
		tempVec.x = tempVec.x / temp
		tempVec.y = tempVec.y / temp
	end
	
	return tempVec
end
 
function Vector2D:Limit(vec,l)
	local tempVec = Vector2D:new(vec.x,vec.y)
	
	if tempVec.x > l then
		tempVec.x = l		
	end
	
	if tempVec.y > l then
		tempVec.y = l		
	end
	
	return tempVec
end
 
function Vector2D:Add(vec1, vec2)
	local vec = Vector2D:new(0,0)
	vec.x = vec1.x + vec2.x
	vec.y = vec1.y + vec2.y
	return vec
end
 
function Vector2D:Sub(vec1, vec2)
	local vec = Vector2D:new(0,0)
	vec.x = vec1.x - vec2.x
	vec.y = vec1.y - vec2.y
	
	return vec
end
 
function Vector2D:Mult(vec, s)
	local tempVec = Vector2D:new(0,0)
	tempVec.x = vec.x * s
	tempVec.y = vec.y * s
	
	return tempVec
end
 
function Vector2D:Div(vec, s)
	local tempVec = Vector2D:new(0,0)
	tempVec.x = vec.x / s
	tempVec.y = vec.y / s
	
	return tempVec
end
 
function Vector2D:Dist(vec1, vec2)
	local dx = (vec2.x - vec1.x)
	local dy = (vec2.y - vec1.y)
	return math.sqrt( dx*dx + dy*dy )
end

function Vector2D:Lerp(vec1, vec2, ratio)
	local ratioComp = 1-ratio
	local x = vec1.x * ratioComp + vec2.x * ratio
	local y = vec1.y * ratioComp + vec2.y * ratio
	return Vector2D:new(x,y)
end
 
return Vector2D