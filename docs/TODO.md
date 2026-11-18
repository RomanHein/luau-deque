# TODO

### Add

- `:Size()`.
- `:Capacity()`.
- `:Shrink()`?
- `:Erase()`.
- `:Insert()`.
- Asserts which validate user arguments?

### Change

- Avoid recomputation of upper and lower bound inside `:Find()` with every chunk.
- Use `*_capacity` instead of `*_size` for variables and constants.
- `:Pop*()` to `:Remove*()` and `:Push*()` to `:Add*()`?
- `:Clear()` to keep allocated chunks?

### Fix

- Fix `__iter`.