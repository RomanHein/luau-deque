--!native
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
        _directory = table_create(8),
        _directory_size = 8,
        _front_cursor = 319,
        _back_cursor = 320,
    }, Deque)
end

--------------------------------------------------------------------------------
-- INSTANCE METHODS
--------------------------------------------------------------------------------

function Deque:PushFront(item)
    local directory = self._directory
    local front_cursor = self._front_cursor

    local front_chunk_index = bit32_rshift(front_cursor, 6)
    local item_index = bit32_band(front_cursor, 63) + 1
    local chunk = directory[front_chunk_index]

    if not chunk then
        if front_chunk_index < 1 then
            local directory_size = self._directory_size
            local back_cursor = self._back_cursor

            local back_chunk_index = bit32_rshift(back_cursor - 1, 6)
            local needed_chunks = back_chunk_index + 1

            if needed_chunks * 8 <= directory_size * 5 then
                local new_front_chunk_index = bit32_rshift(directory_size - back_chunk_index, 1) + 2

                table_move(directory, 1, back_chunk_index, new_front_chunk_index)

                local chunk_shift = new_front_chunk_index - 1
                local cursor_shift = chunk_shift * 64

                front_cursor = front_cursor + cursor_shift
                front_chunk_index = front_chunk_index + chunk_shift

                for i = 1, front_chunk_index - 1 do
                    directory[i] = nil
                end

                self._back_cursor = back_cursor + cursor_shift
            else
                local new_directory_size = directory_size * 2
                local new_directory = table_create(new_directory_size)
                local new_front_chunk_index = bit32_rshift(new_directory_size - back_chunk_index, 1) + 2

                table_move(directory, 1, back_chunk_index, new_front_chunk_index, new_directory)

                local chunk_shift = new_front_chunk_index - 1
                local cursor_shift = chunk_shift * 64

                front_cursor = front_cursor + cursor_shift
                front_chunk_index = front_chunk_index + chunk_shift
                directory = new_directory

                self._directory = new_directory
                self._back_cursor = back_cursor + cursor_shift
                self._directory_size = new_directory_size
            end
        end

        chunk = table_create(64)
        directory[front_chunk_index] = chunk
    end

    chunk[item_index] = item
    self._front_cursor = front_cursor - 1
end

function Deque:PushBack(item)
    local directory = self._directory
    local back_cursor = self._back_cursor

    local back_chunk_index = bit32_rshift(back_cursor, 6)
    local item_index = bit32_band(back_cursor, 63) + 1
    local chunk = directory[back_chunk_index]

    if not chunk then
        local directory_size = self._directory_size

        if back_chunk_index > directory_size then
            local front_cursor = self._front_cursor

            local front_chunk_index = bit32_rshift(front_cursor + 1, 6)
            local needed_chunks = back_chunk_index - front_chunk_index + 1

            if needed_chunks * 8 <= directory_size * 5 then
                local new_front_chunk_index = bit32_rshift(directory_size - needed_chunks, 1) + 1

                table_move(directory, front_chunk_index, directory_size, new_front_chunk_index)

                local chunk_shift = new_front_chunk_index - front_chunk_index
                local cursor_shift = chunk_shift * 64

                back_chunk_index = back_chunk_index + chunk_shift
                back_cursor = back_cursor + cursor_shift

                for i = back_chunk_index + 1, directory_size do
                    directory[i] = nil
                end

                self._front_cursor = front_cursor + cursor_shift
            else
                local new_directory_size = directory_size * 2
                local new_directory = table_create(new_directory_size)
                local new_front_chunk_index = directory_size - bit32_rshift(back_chunk_index - front_chunk_index, 1)

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
        end

        chunk = table_create(64)
        directory[back_chunk_index] = chunk
    end

    chunk[item_index] = item
    self._back_cursor = back_cursor + 1
end

function Deque:PopFront()
    local front_cursor = self._front_cursor + 1
    local back_cursor = self._back_cursor - 1

    if front_cursor < back_cursor then
        local directory = self._directory

        local front_chunk_index = bit32_rshift(front_cursor, 6)
        local item_index = bit32_band(front_cursor, 63) + 1
        local chunk = directory[front_chunk_index]
        local item = chunk[item_index]

        chunk[item_index] = nil
        self._front_cursor = front_cursor

        return item
    end

    if front_cursor > back_cursor then
        return nil
    end

    local directory = self._directory
    local directory_size = self._directory_size

    local new_front_cursor = directory_size * 32 + 63
    local front_chunk_index = bit32_rshift(front_cursor, 6)
    local item_index = bit32_band(front_cursor, 63) + 1
    local chunk = directory[front_chunk_index]
    local item = chunk[item_index]
    
    chunk[item_index] = nil
    self._front_cursor = new_front_cursor
    self._back_cursor = new_front_cursor + 1

    return item
end

function Deque:PopBack()
    local front_cursor = self._front_cursor + 1
    local back_cursor = self._back_cursor - 1

    if front_cursor < back_cursor then
        local directory = self._directory

        local back_chunk_index = bit32_rshift(back_cursor, 6)
        local item_index = bit32_band(back_cursor, 63) + 1
        local chunk = directory[back_chunk_index]
        local item = chunk[item_index]

        chunk[item_index] = nil
        self._back_cursor = back_cursor

        return item
    end

    if front_cursor > back_cursor then
        return nil
    end

    local directory = self._directory
    local directory_size = self._directory_size

    local new_front_cursor = directory_size * 32 + 63
    local back_chunk_index = bit32_rshift(back_cursor, 6)
    local item_index = bit32_band(back_cursor, 63) + 1
    local chunk = directory[back_chunk_index]
    local item = chunk[item_index]
    
    chunk[item_index] = nil
    self._front_cursor = new_front_cursor
    self._back_cursor = new_front_cursor + 1

    return item
end

return Deque