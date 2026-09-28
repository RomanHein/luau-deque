local Deque = require("../source/init")

local deque = Deque.new()

assert(deque:IsEmpty() == true, "IsEmpty() returns false on an empty deque")
assert(#deque == 0, "length operator does not return 0 on an empty deque")
assert(deque:PeekFront() == nil, "PeekFront() does not return nil on an empty deque")
assert(deque:PeekBack() == nil, "PeekFront() does not return nil on an empty deque")