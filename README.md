# Introduction

A Deque is an object that contains values in the order they were added. It exposes a front and back which correspond to the first and last added item. Removing items moves the front/back to the next logical item.

```lua
local deque = Deque.new()

deque:AddBack("World")
deque:AddBack("!")
deque:AddFront("Hello")

for i = 1, #deque do
    print(deque:RemoveFront())
end
```

```text
Hello
World
!
```

# Benefits

Deques offer faster raw performance than arrays for frequent insertions and deletes and can reduce the amount of lines necessary to perform operations due to the wide selection of methods.

```lua
local deque = {}

table.insert(deque, 1)
table.insert(deque, 2)
table.insert(deque, 3)

for i = 1, #deque do
    local item = deque[1]
    table.remove(deque, 1)

    print(item)
end
```

```lua
local deque = Deque.new()

deque:AddBack(1)
deque:AddBack(2)
deque:AddBack(3)

for i = 1, #deque do
    print(deque:RemoveFront())
end
```

# Sections

[Install guide](docs/installation.md)  
[API documentation](docs/api.md)  