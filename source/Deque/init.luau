--[[
    Deque
--]]

--------------------------------------------------------------------------------
-- CONSTANTS
--------------------------------------------------------------------------------

local CHUNK_CAPACITY = 64
local INITIAL_MASTER_CAPACITY = 8
local INITIAL_FRONT = CHUNK_CAPACITY * INITIAL_MASTER_CAPACITY
local INITIAL_BACK = INITIAL_FRONT + 1

local table_create = table.create

--------------------------------------------------------------------------------
-- CLASS INITIALIZATION
--------------------------------------------------------------------------------

local Deque = {}
Deque.__index = Deque

--------------------------------------------------------------------------------
-- CONSTRUCTORS
--------------------------------------------------------------------------------

function Deque.new()
    return setmetatable({
        _master = table_create(INITIAL_MASTER_CAPACITY, nil),
        _capacity = INITIAL_MASTER_CAPACITY,
        _front = INITIAL_FRONT,
        _back = INITIAL_BACK,
    }, Deque)
end

--------------------------------------------------------------------------------
-- INSTANCE METHODS
--------------------------------------------------------------------------------

function Deque:PushFront(item)

end

function Deque:PushBack(item)
    local master = self._master
    local back = self._back

    local back_chunk_index = (back - 1) // CHUNK_CAPACITY + 1
    local item_index = (back - 1) % CHUNK_CAPACITY + 1
    local chunk = master[back_chunk_index]

    if not chunk then
        chunk = table_create(CHUNK_CAPACITY, nil)
        master[back_chunk_index] = chunk
    end

    chunk[item_index] = item
    self._back = back + 1
end

function Deque:PopFront()
    local master = self._master
    local front = self._front

    local front_chunk_index = front // CHUNK_CAPACITY + 1
    local item_index = front % CHUNK_CAPACITY + 1
    local chunk = master[front_chunk_index]

    local item = chunk[item_index]
    
    chunk[item_index] = nil
    self._front = front + 1

    return item
end

function Deque:PopBack()

end

return Deque