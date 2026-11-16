--!native
--[[
    Deque
--]]

--------------------------------------------------------------------------------
-- CONSTANTS
--------------------------------------------------------------------------------

local CHUNK_SIZE = 64
local INITIAL_DIRECTORY_SIZE = 8
local RECENTER_MAX_OCCUPANCY_NUMERATOR = 5      -- recenter in place while the needed chunks
local RECENTER_MAX_OCCUPANCY_DENOMINATOR = 8    -- are at most 5/8 of the directory

local HALF_CHUNK_SIZE = CHUNK_SIZE // 2
local CURSOR_OFFSET = CHUNK_SIZE - 1
local INITIAL_FRONT_CURSOR = HALF_CHUNK_SIZE * INITIAL_DIRECTORY_SIZE + CURSOR_OFFSET
local INITIAL_BACK_CURSOR = INITIAL_FRONT_CURSOR + 1

local table_create = table.create
local table_move = table.move

--------------------------------------------------------------------------------
-- FUNCTIONS
--------------------------------------------------------------------------------

local function iterate(self, traversal_cursor)
    local back_cursor = self._back_cursor - 1

    if traversal_cursor > back_cursor then
        return nil
    end

    local directory = self._directory
    local chunk_index = traversal_cursor // CHUNK_SIZE
    local item_index = traversal_cursor % CHUNK_SIZE + 1
    local chunk = directory[chunk_index]
    local item = chunk[item_index]

    return traversal_cursor + 1, item
end

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
        _directory = table_create(INITIAL_DIRECTORY_SIZE),
        _directory_size = INITIAL_DIRECTORY_SIZE,
        _front_cursor = INITIAL_FRONT_CURSOR,
        _back_cursor = INITIAL_BACK_CURSOR,
    }, Deque)
end

--------------------------------------------------------------------------------
-- INSTANCE METHODS
--------------------------------------------------------------------------------

function Deque:PushFront(item)
    local directory = self._directory
    local front_cursor = self._front_cursor
    local front_chunk_index = front_cursor // CHUNK_SIZE
    local item_index = front_cursor % CHUNK_SIZE + 1
    local chunk = directory[front_chunk_index]

    if not chunk then
        if front_chunk_index < 1 then
            local directory_size = self._directory_size
            local back_cursor = self._back_cursor
            local back_chunk_index = (back_cursor - 1) // CHUNK_SIZE
            local needed_chunks = back_chunk_index + 1
            local in_place = needed_chunks * RECENTER_MAX_OCCUPANCY_DENOMINATOR <= directory_size * RECENTER_MAX_OCCUPANCY_NUMERATOR
            local new_front_chunk_index

            if in_place then
                new_front_chunk_index = (directory_size - back_chunk_index) // 2 + 2
                table_move(directory, 1, back_chunk_index, new_front_chunk_index)
            else
                local new_directory_size = directory_size * 2
                local new_directory = table_create(new_directory_size)
                new_front_chunk_index = (new_directory_size - back_chunk_index) // 2 + 2
                table_move(directory, 1, back_chunk_index, new_front_chunk_index, new_directory)

                directory = new_directory
                self._directory = new_directory
                self._directory_size = new_directory_size
            end

            local chunk_shift = new_front_chunk_index - 1
            local cursor_shift = chunk_shift * CHUNK_SIZE

            front_chunk_index = front_chunk_index + chunk_shift
            front_cursor = front_cursor + cursor_shift
            self._back_cursor = back_cursor + cursor_shift

            if in_place then
                for i = 1, front_chunk_index - 1 do
                    directory[i] = nil
                end
            end
        end

        chunk = table_create(CHUNK_SIZE)
        directory[front_chunk_index] = chunk
    end

    chunk[item_index] = item
    self._front_cursor = front_cursor - 1
end

function Deque:PushBack(item)
    local directory = self._directory
    local back_cursor = self._back_cursor
    local back_chunk_index = back_cursor // CHUNK_SIZE
    local item_index = back_cursor % CHUNK_SIZE + 1
    local chunk = directory[back_chunk_index]

    if not chunk then
        local directory_size = self._directory_size

        if back_chunk_index > directory_size then
            local front_cursor = self._front_cursor
            local front_chunk_index = (front_cursor + 1) // CHUNK_SIZE
            local needed_chunks = back_chunk_index - front_chunk_index + 1
            local in_place = needed_chunks * RECENTER_MAX_OCCUPANCY_DENOMINATOR <= directory_size * RECENTER_MAX_OCCUPANCY_DENOMINATOR
            local new_front_chunk_index

            if in_place then
                new_front_chunk_index = (directory_size - needed_chunks) // 2 + 1
                table_move(directory, front_chunk_index, directory_size, new_front_chunk_index)
            else
                local new_directory_size = directory_size * 2
                local new_directory = table_create(new_directory_size)
                new_front_chunk_index = directory_size - (back_chunk_index - front_chunk_index) // 2
                table_move(directory, front_chunk_index, directory_size, new_front_chunk_index, new_directory)

                directory = new_directory
                self._directory = new_directory
                self._directory_size = new_directory_size
            end

            local chunk_shift = new_front_chunk_index - front_chunk_index
            local cursor_shift = chunk_shift * CHUNK_SIZE

            back_chunk_index = back_chunk_index + chunk_shift
            back_cursor = back_cursor + cursor_shift
            self._front_cursor = front_cursor + cursor_shift

            if in_place then
                for i = back_chunk_index + 1, directory_size do
                    directory[i] = nil
                end
            end
        end

        chunk = table_create(CHUNK_SIZE)
        directory[back_chunk_index] = chunk
    end

    chunk[item_index] = item
    self._back_cursor = back_cursor + 1
end

function Deque:PopFront()
    local front_cursor = self._front_cursor + 1
    local back_cursor = self._back_cursor - 1

    if front_cursor > back_cursor then
        return nil
    end

    local directory = self._directory
    local front_chunk_index = front_cursor // CHUNK_SIZE
    local item_index = front_cursor % CHUNK_SIZE + 1
    local chunk = directory[front_chunk_index]
    local item = chunk[item_index]

    if front_cursor == back_cursor then
        local directory_size = self._directory_size
        front_cursor = directory_size * HALF_CHUNK_SIZE + CURSOR_OFFSET
        back_cursor = front_cursor + 1
        self._back_cursor = back_cursor
    end

    chunk[item_index] = nil
    self._front_cursor = front_cursor

    return item
end

function Deque:PopBack()
    local front_cursor = self._front_cursor + 1
    local back_cursor = self._back_cursor - 1

    if front_cursor > back_cursor then
        return nil
    end

    local directory = self._directory
    local back_chunk_index = back_cursor // CHUNK_SIZE
    local item_index = back_cursor % CHUNK_SIZE + 1
    local chunk = directory[back_chunk_index]
    local item = chunk[item_index]

    if front_cursor == back_cursor then
        local directory_size = self._directory_size
        front_cursor = directory_size * HALF_CHUNK_SIZE + CURSOR_OFFSET
        back_cursor = front_cursor + 1
        self._front_cursor = front_cursor
    end

    chunk[item_index] = nil
    self._back_cursor = back_cursor

    return item
end

function Deque:PeekFront()
    local front_cursor = self._front_cursor + 1
    local back_cursor = self._back_cursor - 1

    if front_cursor > back_cursor then
        return nil
    end

    local directory = self._directory
    local front_chunk_index = front_cursor // CHUNK_SIZE
    local item_index = front_cursor % CHUNK_SIZE + 1
    local chunk = directory[front_chunk_index]
    local item = chunk[item_index]

    return item
end

function Deque:PeekBack()
    local front_cursor = self._front_cursor + 1
    local back_cursor = self._back_cursor - 1

    if front_cursor > back_cursor then
        return nil
    end

    local directory = self._directory
    local back_chunk_index = back_cursor // CHUNK_SIZE
    local item_index = back_cursor % CHUNK_SIZE + 1
    local chunk = directory[back_chunk_index]
    local item = chunk[item_index]

    return item
end

function Deque:Clear()
    self._directory = table_create(INITIAL_DIRECTORY_SIZE)
    self._directory_size = INITIAL_DIRECTORY_SIZE
    self._front_cursor = INITIAL_FRONT_CURSOR
    self._back_cursor = INITIAL_BACK_CURSOR
end

function Deque:IsEmpty()
    return self._front_cursor + 1 > self._back_cursor - 1
end

function Deque:Begin()
    return self._front_cursor
end

function Deque:End()
    return self._back_cursor
end

--------------------------------------------------------------------------------
-- META METHODS
--------------------------------------------------------------------------------

function Deque:__tostring()
    return "Deque"
end

function Deque:__len()
    return self._back_cursor - self._front_cursor - 1
end

function Deque:__iter()
    return iterate, self, self._front_cursor + 1
end

return Deque