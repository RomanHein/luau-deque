# Overview

### Types

[Deque](#deque)  

### Constructor

[new](#new)  

### Methods

[AddFront](#addfront)  
[AddBack](#addback)  
[PopFront](#popfront)  
[PopBack](#popback)  
[PeekFront](#peekfront)  
[PeekBack](#peekback)  
[Clear](#clear)  
[IsEmpty](#isempty)  

### Other

[Length](#length)  
[Iterator](#iterator)  
[Stringification](#stringification)  

## Deque

> An object that contains items in the order they were added while exposing the first and last contained item.

**Type Parameters**

| Name | Description |
| --- | --- |
| T | The type of the contained items |

**Example**

```lua
function foo(deque: Deque.Deque<number>)
    -- ...
end
```

## new

> Creates a Deque.

**Returns**

| Type | Description |
| --- | --- |
| Deque\<unknown\> | The Deque |

**Example**

```lua
local deque = Deque.new()

print(deque)
```

```text
Deque(nil, nil)
```

## AddFront

> Adds an item to the front of a Deque.

**Parameters**

| Name | Type | Description |
| --- | --- | --- |
| deque | Deque\<T\> | The Deque to add the item to |
| item | T | The item to add |

**Example**

```lua
local deque = Deque.new()

deque:AddFront(5)
deque:AddFront(10)

print(deque)
```

```text
Deque(10, 5)
```

## AddBack

> Adds an item to the back of a Deque.

**Parameters**

| Name | Type | Description |
| --- | --- | --- |
| deque | Deque\<T\> | The Deque to add the item to |
| item | T | The item to add |

**Example**

```lua
local deque = Deque.new()

deque:AddBack(5)
deque:AddBack(10)

print(deque)
```

```text
Deque(5, 10)
```

## PopFront

> Removes the item at the front of a Deque and returns it.

**Notes**

* Throws an error if the Deque is empty

**Parameters**

| Name | Type | Description |
| --- | --- | --- |
| deque | Deque\<T\> | The Deque to pop |

**Returns**

| Type | Description |
| --- | --- |
| T | The item at the front of the Deque |

**Example**

```lua
local deque = Deque.new()

deque:AddBack(5)
deque:AddBack(10)

print(deque:PopFront())
```

```text
5
```

## PopBack

> Removes the item at the back of a Deque and returns it.

**Notes**

* Throws an error if the Deque is empty

**Parameters**

| Name | Type | Description |
| --- | --- | --- |
| deque | Deque\<T\> | The Deque to pop |

**Returns**

| Type | Description |
| --- | --- |
| T | The item at the back of the Deque |

**Example**

```lua
local deque = Deque.new()

deque:AddBack(5)
deque:AddBack(10)

print(deque:PopBack())
```

```text
10
```

## PeekFront

> Checks the front of a Deque.

**Notes**

* Returns nil if the Deque is empty

**Parameters**

| Name | Type | Description |
| --- | --- | --- |
| deque | Deque\<T\> | The Deque to peek |

**Returns**

| Type | Description |
| --- | --- |
| T? | The item at the front of the Deque |

**Example**

```lua
local deque = Deque.new()

deque:AddBack(5)
deque:AddBack(10)

print(deque:PeekFront())
```

```text
5
```

## PeekBack

> Checks the back of a Deque.

**Notes**

* Returns nil if the Deque is empty

**Parameters**

| Name | Type | Description |
| --- | --- | --- |
| deque | Deque\<T\> | The Deque to peek |

**Returns**

| Type | Description |
| --- | --- |
| T? | The item at the back of the Deque |

**Example**

```lua
local deque = Deque.new()

deque:AddBack(5)
deque:AddBack(10)

print(deque:PeekBack())
```

```text
10
```

## Clear

> Removes all items of a Deque.

**Parameters**

| Name | Type | Description |
| --- | --- | --- |
| deque | Deque\<T\> | The Deque to clear |

**Example**

```lua
local deque = Deque.new()

deque:AddBack(5)
deque:AddBack(10)
deque:Clear()

print(deque)
```

```text
Deque(nil, nil)
```

## IsEmpty

> Checks whether a Deque contains any items.

**Parameters**

| Name | Type | Description |
| --- | --- | --- |
| deque | Deque\<T\> | The Deque to check |

**Returns**

| Type | Description |
| --- | --- |
| boolean | Whether the deque contains any items. |

**Example**

```lua
local deque = Deque.new()

print(deque:IsEmpty())
```

```text
true
```

## Length

> The length of a Deque can be determined by using the # length operator.

**Example**

```lua
local deque = Deque.new()

print(#deque)
```

```text
0
```

## Iterator

> Iterate through a Deque the same way as with a table.

**Example**

```lua
local deque = Deque.new()

deque:AddBack("Hello")
deque:AddBack("World")
deque:AddBack("!")

for i, item in deque do
    print(i, item)
end
```

```text
1 Hello
2 World
3 !
```

## Stringification

> When stringifying a Deque, the item at the front and back of the Deque are displayed inside of parantheses.

**Example**

```lua
local deque = Deque.new()

deque:AddBack(5) -- front
deque:AddBack(10) -- back

print(deque)
```

```text
Deque(5, 10)
```