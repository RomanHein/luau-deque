--[[
    Benchmark
--]]

--------------------------------------------------------------------------------
-- DEPENDENCIES
--------------------------------------------------------------------------------

local Deque = require("../Source/Deque")

--------------------------------------------------------------------------------
-- CONSTANTS
--------------------------------------------------------------------------------

local table_create = table.create
local table_sort = table.sort

local os_clock = os.clock

--------------------------------------------------------------------------------
-- FUNCTIONS
--------------------------------------------------------------------------------

local function format_time(time)
    if time >= 1 then
        return string.format("%.3fs", time)
    elseif time >= 1e-3 then
        return string.format("%.3fms", time * 1e3)
    elseif time >= 1e-6 then
        return string.format("%.3fus", time * 1e6)
    elseif time >= 1e-9 then
        return string.format("%.3fns", time * 1e9)
    else
        return "small"
    end
end

local function benchmark(name, iterations, callback, ...)
    local samples = table_create(iterations, nil)
    local elapsed = 0
    local total = 0
    local now = 0

    for i = 1, iterations do
        now = os_clock()
        callback(...)
        elapsed = os_clock() - now

        samples[i] = elapsed
        total = total + elapsed
    end

    table_sort(samples, nil)

    print(`{name}: median: {format_time(samples[iterations // 2])} total: {format_time(total)}`)
end

--------------------------------------------------------------------------------
-- SOURCE
--------------------------------------------------------------------------------

