# Changelog

All notable changes will be documented here.

## 1.2.0

### Added

- Finding the first logical position of an item via `:Find()`.
- Erasing values at any position via `:Erase()`.

### Changed

- Implementation of generalized iteration for better performance.
- Parameter `item` to `value` for better clarity.

### Fixed

- `:PushFront()` not recentering items in place.

## 1.1.0

### Added

- Inspection of front item via `:PeekFront()`.
- Inspection of back item via `:PeekBack()`.
- Support for generalized iteration.