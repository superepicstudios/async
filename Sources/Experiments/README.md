# 👨🏻‍🔬 Experiments

This directory contains experimental / WIP code that is not yet (and might never be) intended to be used.
Stuff here is **not** battle-tested, and should not be used in production applications.

## 🎁 PropertyWrappers

The following property wrappers were implemented before Swift 6 concurrency updates. Since property wrappers
are implicitly unsafe when using newer concurrency features, these have been pulled out of the library, and
will need to be re-implemented as _macros_.

### Async

- `@Streamed`
- `@StreamedPipe`
- `@StreamingValue`
- `@StreamingPassthrough
- `@StreamingSignal`

### Combine

- `@PublishedPipe`
- `@PublishingValue`
- `@PublishingPassthrough
- `@PublishingSignal`
