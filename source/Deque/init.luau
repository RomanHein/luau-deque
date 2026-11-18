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

function Deque:PushFront(value)
    local directory = self._directory
    local front_cursor = self._front_cursor
    local front_chunk_index = front_cursor // CHUNK_SIZE
    local slot = front_cursor % CHUNK_SIZE + 1
    local chunk = directory[front_chunk_index]

    if not chunk then
        if front_chunk_index < 1 then
            local directory_size = self._directory_size
            local back_cursor = self._back_cursor
            local back_chunk_index = (back_cursor - 1) // CHUNK_SIZE
            local required_chunks = back_chunk_index + 1
            local in_place = required_chunks * RECENTER_MAX_OCCUPANCY_DENOMINATOR <= directory_size * RECENTER_MAX_OCCUPANCY_NUMERATOR
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

    chunk[slot] = value
    self._front_cursor = front_cursor - 1
end

function Deque:PushBack(value)
    local directory = self._directory
    local back_cursor = self._back_cursor
    local back_chunk_index = back_cursor // CHUNK_SIZE
    local slot = back_cursor % CHUNK_SIZE + 1
    local chunk = directory[back_chunk_index]

    if not chunk then
        local directory_size = self._directory_size

        if back_chunk_index > directory_size then
            local front_cursor = self._front_cursor
            local front_chunk_index = (front_cursor + 1) // CHUNK_SIZE
            local required_chunks = back_chunk_index - front_chunk_index + 1
            local in_place = required_chunks * RECENTER_MAX_OCCUPANCY_DENOMINATOR <= directory_size * RECENTER_MAX_OCCUPANCY_NUMERATOR
            local new_front_chunk_index

            if in_place then
                new_front_chunk_index = (directory_size - required_chunks) // 2 + 1
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

    chunk[slot] = value
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
    local slot = front_cursor % CHUNK_SIZE + 1
    local chunk = directory[front_chunk_index]
    local item = chunk[slot]

    if front_cursor == back_cursor then
        local directory_size = self._directory_size
        front_cursor = directory_size * HALF_CHUNK_SIZE + CURSOR_OFFSET
        back_cursor = front_cursor + 1
        self._back_cursor = back_cursor
    end

    chunk[slot] = nil
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
    local slot = back_cursor % CHUNK_SIZE + 1
    local chunk = directory[back_chunk_index]
    local item = chunk[slot]

    if front_cursor == back_cursor then
        local directory_size = self._directory_size
        front_cursor = directory_size * HALF_CHUNK_SIZE + CURSOR_OFFSET
        back_cursor = front_cursor + 1
        self._front_cursor = front_cursor
    end

    chunk[slot] = nil
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
    local slot = front_cursor % CHUNK_SIZE + 1
    local chunk = directory[front_chunk_index]
    local item = chunk[slot]

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
    local slot = back_cursor % CHUNK_SIZE + 1
    local chunk = directory[back_chunk_index]
    local item = chunk[slot]

    return item
end

function Deque:Erase(position)
    local directory = self._directory
    local front_cursor = self._front_cursor + 1
    local back_cursor = self._back_cursor - 1
    local target_cursor = front_cursor + position - 1
    local left_slots = target_cursor - front_cursor
    local right_slots = back_cursor - target_cursor

    if left_slots > right_slots then
        local first_chunk_index = target_cursor // CHUNK_SIZE
        local last_chunk_index = back_cursor // CHUNK_SIZE
        local first_slot = target_cursor % CHUNK_SIZE + 1
        local last_slot = back_cursor % CHUNK_SIZE + 1
        local last_chunk = directory[last_chunk_index]

        if first_chunk_index == last_chunk_index then
            table_move(last_chunk, first_slot + 1, last_slot, first_slot)
            last_chunk[last_slot] = nil
        else
            local first_chunk = directory[first_chunk_index]
            local shifted_value = last_chunk[1]

            table_move(last_chunk, 2, last_slot, 1)
            last_chunk[last_slot] = nil

            for chunk_index = last_chunk_index - 1, first_chunk_index + 1, -1 do
                local chunk = directory[chunk_index]
                local next_shifted_value = chunk[1]
                table_move(chunk, 2, CHUNK_SIZE, 1)
                chunk[CHUNK_SIZE] = shifted_value
                shifted_value = next_shifted_value
            end

            table_move(first_chunk, first_slot + 1, CHUNK_SIZE, first_slot)
            first_chunk[CHUNK_SIZE] = shifted_value
        end

        self._back_cursor = back_cursor
    else
        local first_chunk_index = front_cursor // CHUNK_SIZE
        local last_chunk_index = target_cursor // CHUNK_SIZE
        local first_slot = front_cursor % CHUNK_SIZE + 1
        local last_slot = target_cursor % CHUNK_SIZE + 1
        local first_chunk = directory[first_chunk_index]

        if first_chunk_index == last_chunk_index then
            table_move(first_chunk, first_slot, last_slot, first_slot + 1)
            first_chunk[first_slot] = nil
        else
            local last_chunk = directory[last_chunk_index]
            local shifted_value = first_chunk[CHUNK_SIZE]

            table_move(first_chunk, first_slot, CHUNK_SIZE - 1, first_slot + 1)
            first_chunk[first_slot] = nil

            for chunk_index = first_chunk_index + 1, last_chunk_index - 1 do
                local chunk = directory[chunk_index]
                local next_shifted_value = chunk[CHUNK_SIZE]
                table_move(chunk, 1, CHUNK_SIZE - 1, 2)
                chunk[1] = shifted_value
                shifted_value = next_shifted_value
            end

            table_move(last_chunk, 1, last_slot - 1, 2)
            last_chunk[1] = shifted_value
        end

        self._front_cursor = front_cursor
    end
end

function Deque:Find(value, position)
    local front_cursor = self._front_cursor + 1
    local back_cursor = self._back_cursor - 1

    if front_cursor > back_cursor then
        return nil
    end

    local directory = self._directory
    local start_cursor = if position then front_cursor + position - 1 else front_cursor
    local front_chunk_index = start_cursor // CHUNK_SIZE
    local back_chunk_index = back_cursor // CHUNK_SIZE
    local front_slot = start_cursor % CHUNK_SIZE + 1
    local back_slot = back_cursor % CHUNK_SIZE + 1

    for chunk_index = front_chunk_index, back_chunk_index do
        local lower_bound = if chunk_index == front_chunk_index then front_slot else 1
        local upper_bound = if chunk_index == back_chunk_index then back_slot else CHUNK_SIZE
        local chunk = directory[chunk_index]

        for slot = lower_bound, upper_bound do
            if chunk[slot] == value then
                return chunk_index * CHUNK_SIZE + slot - front_cursor
            end
        end
    end

    return nil
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
    local directory = self._directory
    local front_cursor = self._front_cursor - 1
    local back_cursor = self._back_cursor + 1
    local cursor = front_cursor
    local position = 0

    return function()
        if cursor > back_cursor then
            return nil
        end

        local chunk_index = cursor // CHUNK_SIZE
        local slot = cursor % CHUNK_SIZE + 1
        local chunk = directory[chunk_index]
        local item = chunk[slot]

        cursor += 1

        return cursor + 1, item
    end
end

return Deque