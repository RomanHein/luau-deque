# Changelog

All notable changes will be documented here.

## 1.2.0

### Added

- Finding the logical index of the first occurence of an item via `:Find()`.

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