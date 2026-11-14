--[[
    Deque
--]]

--------------------------------------------------------------------------------
-- CONSTANTS
--------------------------------------------------------------------------------

local table_create = table.create
local table_move = table.move

local bit32_band = bit32.band
local bit32_rshift = bit32.rshift

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
        _directory = table_create(8, nil),
        _directory_size = 8,
        _front_cursor = 256,
        _back_cursor = 257,
    }, Deque)
end

--------------------------------------------------------------------------------
-- INSTANCE METHODS
--------------------------------------------------------------------------------

function Deque:PushFront(item)

end

function Deque:PushBack(item)
    local directory = self._directory
    local back_cursor = self._back_cursor - 1

    local back_chunk_index = bit32_rshift(back_cursor, 6) + 1
    local item_index = bit32_band(back_cursor, 63) + 1
    local chunk = directory[back_chunk_index]

    if not chunk then
        local directory_size = self._directory_size

        if back_chunk_index > directory_size then
            local front_cursor = self._front_cursor

            local front_chunk_index = bit32_rshift(front_cursor, 6) + 1
            local new_front_chunk_index = directory_size - bit32_rshift(directory_size - front_chunk_index, 1)

            local new_directory_size = directory_size * 2
            local new_directory = table_create(new_directory_size, nil)

            table_move(directory, front_chunk_index, directory_size, new_front_chunk_index, new_directory)

            local chunk_shift = new_front_chunk_index - front_chunk_index
            local cursor_shift = chunk_shift * 64

            back_chunk_index = back_chunk_index + chunk_shift
            back_cursor = back_cursor + cursor_shift
            directory = new_directory

            self._directory = new_directory
            self._front_cursor = front_cursor + cursor_shift
            self._directory_size = new_directory_size
        end

        chunk = table_create(64, nil)
        directory[back_chunk_index] = chunk
    end

    chunk[item_index] = item
    self._back_cursor = back_cursor + 2
end

function Deque:PopFront()
    
end

function Deque:PopBack()
    
end

return Deque