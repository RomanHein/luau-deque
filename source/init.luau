--[[
	Deque.luau
	
	An object that keeps the order of items that were added while
	exposing the first and last item that was added.
]]

----------------------------------------------------------------------
-- TYPES
----------------------------------------------------------------------

type DequeClass = {
	new: typeof(
		--[[
			Creates a Deque.
		]]
		function(): Deque<unknown>
		end
	),
}

export type Deque<T> = {
	AddFront: typeof(
		--[[
			Adds an item to the front of a Deque.
		]]
		function(deque: Deque<T>, item: T): () 
		end
	),

	AddBack: typeof(
		--[[
			Adds an item to the back of a Deque.
		]]
		function(deque: Deque<T>, item: T): () 
		end
	),

	RemoveFront: typeof(
		--[[
			Removes the item at the front of a Deque and returns it.
		]]
		function(deque: Deque<T>): T
		end
	),

	RemoveBack: typeof(
		--[[
			Removes the item at the back of a Deque and returns it.
		]]
		function(deque: Deque<T>): T 
		end
	),

	PeekFront: typeof(
		--[[
			Checks the front of a Deque.
		]]
		function(deque: Deque<T>): T? 
		end
	),

	PeekBack: typeof(
		--[[
			Checks the back of a Deque.
		]]
		function(deque: Deque<T>): T? 
		end
	),

	Clear: typeof(
		--[[
			Removes all items of a Deque.
		]]
		function(deque: Deque<T>): () 
		end
	),

	IsEmpty: typeof(
		--[[
			Checks whether a Deque contains any items.
		]]
		function(deque: Deque<T>): boolean 
		end
	),

	[number]: T,
}

----------------------------------------------------------------------
-- FUNCTIONS
----------------------------------------------------------------------

local function iterate(deque, index)
	local current = deque._first + index

	if current > deque._last then
		return nil
	end

	local item = deque._array[current]

	return index + 1, item
end

----------------------------------------------------------------------
-- IMPLEMENTATION
----------------------------------------------------------------------

local Deque = {} :: DequeClass
Deque.__index = Deque

function Deque.new()
	return setmetatable({
		_array = {},
		_first = 0,
		_last = -1,
	}, Deque)
end

function Deque:AddFront(item)
	local first = self._first - 1
	self._first = first
	self._array[first] = item
end

function Deque:AddBack(item)
	local last = self._last + 1
	self._last = last
	self._array[last] = item
end

function Deque:RemoveFront()
	local first = self._first
	local last = self._last
	
	if first > last then
		error("cannot remove front item from an empty queue", 2)
	end
	
	local array = self._array
	local item = array[first]
	
	self._first = first + 1
	array[first] = nil

	if first + 1 > last then
		self._first = 0
		self._last = -1
	end

	return item
end

function Deque:RemoveBack()
	local first = self._first
	local last = self._last
	
	if first > last then
		error("cannot remove back item from an empty queue", 2)
	end
	
	local array = self._array
	local item = array[last]

	self._last = last - 1
	array[last] = nil

	if first > last - 1 then
		self._first = 0
		self._last = -1
	end

	return item
end

function Deque:PeekFront()
	return self._array[self._first]
end

function Deque:PeekBack()
	return self._array[self._last]
end

function Deque:Clear()
	table.clear(self._array)
	self._first = 0
	self._last = -1
end

function Deque:IsEmpty()
	return self._first > self._last
end

----------------------------------------------------------------------
-- METAMETHODS
----------------------------------------------------------------------

function Deque:__tostring()
	local front = tostring(self._array[self._first])
	local back = tostring(self._array[self._last])
	
	return "Deque("..front..", "..back..")"
end

function Deque:__iter()
	return iterate, self, 0
end

function Deque:__len()
	return self._last - self._first + 1
end

return Deque