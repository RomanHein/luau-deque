# Introduction

A Deque is an object that contains values in the order they were added. It exposes the front (first item) and back (last item) that was added. Removing items moves the front/back to the next logical item.

```lua
local deque = Deque.new()

deque:AddBack("World")
deque:AddBack("!")
deque:AddFront("Hello")

for i = 1, 3 do
    print(deque:PopFront())
end
```

```text
Hello
World
!
```

# Sections

[Install guide](docs/installation.md)  
[API documentation](docs/api.md)  