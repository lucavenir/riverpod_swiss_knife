# Riverpod Swiss knife

A collection of utilities and extensions for Riverpod.

## Features

Here's what you can do with this package.

### Caching strategies
- `cacheFor`: cache the value for a specified duration
- `addDisposeDelay`: delay the disposal of a provider by a specified duration

### Ref utilities
- `debounceFor`: debounce a provider for a specified duration
- `timeout`: triggers a callback after a specified duration
- `onRepeat`: triggers a callback repeatedly, with the specified interval
- `run`: executes an async provider, keeping it alive until its futures completes

### Invalidation strategies
- `invalidateSelfAfter`: self-invalidates after a specified duration
- `invalidatePeriodically`: invalidates a provider periodically at the specified interval

### Notifier utilities

- `update`: update the state based on the previous state, similarly to AsyncNotifier's `update` method.


## Usage

See the example folder for more details.

## Important note

Please read the API docs *carefully* before using any of the above utilities.
