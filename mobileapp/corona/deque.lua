-- Taken from http://stackoverflow.com/questions/18843610/fast-implementation-of-queues-in-lua

local Deque = {}

function Deque.new ()
	return {first = 0, last = -1}
end

function Deque.pushleft (deque, value)
	local first = deque.first - 1
	deque.first = first
	deque[first] = value
end

function Deque.pushright (deque, value)
	local last = deque.last + 1
	deque.last = last
	deque[last] = value
end

function Deque.popleft (deque)
	local first = deque.first
	if first > deque.last then error("deque is empty") end
	local value = deque[first]
	deque[first] = nil        -- to allow garbage collection
	deque.first = first + 1
	return value
end

function Deque.first(deque)
	return deque[deque.first]
end

function Deque.last(deque)
	return deque[deque.first]
end

function Deque.popright (deque)
	local last = deque.last
	if deque.first > last then error("deque is empty") end
	local value = deque[last]
	deque[last] = nil         -- to allow garbage collection
	deque.last = last - 1
	return value
end

return Deque