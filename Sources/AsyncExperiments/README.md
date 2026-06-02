# 👨🏻‍🔬 AsyncExperiments

This module contains experimental code that is not yet (and might never be) pulled into the core Async module.
Stuff here is **not** battle-tested, and should not be used in production environments.

## 📖 Table of Contents

- [💬 Channels](#-channels)
- [📚 Async Subjects](#-async-subjects)
- [⚠️ Critical](#-critical)

## 💬 Channels

[AsyncAlgorithms](https://github.com/apple/swift-async-algorithms) introduced two new foundational types, [AsyncChannel](https://swiftpackageindex.com/apple/swift-async-algorithms/main/documentation/asyncalgorithms/asyncchannel) & [AsyncThrowingChannel](https://swiftpackageindex.com/apple/swift-async-algorithms/main/documentation/asyncalgorithms/asyncthrowingchannel). These are great, but leave something to be desired in the context of buffered elements. The ability for a channel to buffer its elements (without suspending on send) is **required** for other foundational types, such as async subjects. Async adds these new channel types:

- [AsyncBufferedChannel](https://github.com/superepicstudios/Async/blob/main/Sources/AsyncExperiments/Channel/AsyncBufferedChannel.swift)
- [AsyncThrowingBufferedChannel](https://github.com/superepicstudios/Async/blob/main/Sources/AsyncExperiments/Channel/AsyncThrowingBufferedChannel.swift)

Both of these function almost identically to their `AsyncAlgorithms` counterparts. However, as their names suggest, they _buffer_ their elements without suspending on `send`. One important thing to note, channels do **not** share (multicast) their elements. If multiple consumers are iterating over a channel, its elements will be _spread_ across them.

```swift
let channel = AsyncBufferedChannel<Int>()

Task {
    for await e in channel {
        print("Received: \(e)")
    }
    print("Finished")
}

channel.send(1)
channel.send(2)
channel.send(3)
channel.send(.finished)

// → "Received: 1"
// → "Received: 2"
// → "Received: 3"
// → "Finished"
```

**Note**: [AsyncExtensions](https://github.com/sideeffect-io/AsyncExtensions) also contains its own implementations for `AsyncBufferedChannel` & `AsyncThrowingBufferedChannel`. We've opted to roll our own (though heavily inspired by them) to reduce library overlap.

## 📚 Async Subjects

Building off buffered channels, async subjects provide a declarative way to send data to downstream consumers. However, unlike channels, async subjects broadcast their elements (i.e. _share_, _multicast_) to any amount of consumers. If you're familiar with [Combine](https://developer.apple.com/documentation/combine) subjects, these are their async counterparts. `Async` adds these async subjects types:

### [AsyncReplaySubject](https://github.com/superepicstudios/Async/blob/main/Sources/AsyncExperiments/Subjects/AsyncReplaySubject.swift)

```swift
// Replays a buffered amount of elements to downstream consumers.
let subject = AsyncReplaySubject<Int>(2)

subject.send(1)
subject.send(2)
subject.send(3)
subject.send(.finished)

Task {
    for await e in subject {
        print("Received: \(e)")
    }
    print("Finished")
}

// → "Received: 2"
// → "Received: 3"
// → "Finished"
```

### [AsyncCurrentValueSubject](https://github.com/superepicstudios/Async/blob/main/Sources/AsyncExperiments/Subjects/AsyncCurrentValueSubject.swift)

```swift
// Buffers a single element, and broadcasts it to downstream consumers.
let subject = AsyncCurrentValueSubject<Int>(1)

Task {
    for await e in subject {
        print("Received: \(e)")
    }
    print("Finished")
}

subject.send(2)
subject.send(3)
subject.send(.finished)

// → "Received: 1"
// → "Received: 2"
// → "Received: 3"
// → "Finished"
```

### [AsyncPassthroughSubject](https://github.com/superepicstudios/Async/blob/main/Sources/AsyncExperiments/Subjects/AsyncPassthroughSubject.swift)

```swift
// Broadcasts new elements to downstream consumers.
let subject = AsyncPassthroughSubject<Int>()

subject.send(1) // Dropped (no consumers)

Task {
    for await e in subject {
        print("Received: \(e)")
    }
    print("Finished")
}

subject.send(2)
subject.send(3)
subject.send(.finished)

// → "Received: 2"
// → "Received: 3"
// → "Finished"
```

### [AsyncSignalSubject](https://github.com/superepicstudios/Async/blob/main/Sources/AsyncExperiments/Subjects/AsyncSignalSubject.swift)

```swift
// Broadcasts signals to downstream consumers.
let subject = AsyncSignalSubject()

Task {
    for await _ in subject {
        print("Signal")
    }
    print("Finished")
}

subject.send()
subject.send(.finished)

// → "Signal"
// → "Finished"
```

### ⚠️ Critical

When tracking critical state or values, it's important to protect against scenarios that could potentially introduce unsafe read & write operations. Different threads attempting to access a single value at the same time can be a recipe for disaster. Async adds a foundational [Critical](https://github.com/superepicstudios/Async/blob/main/Sources/Experiments/Critical.swift) type that helps protect against these scanarios.

```swift
let critical = Critical<Int>(0)
var value = critical.get()

print(value) // 0

critical.set(1)
value = critical.get()

print(value) // 1
```

**Note**: This is a public re-implementation of [ManagedCriticalState](https://github.com/apple/swift-async-algorithms/blob/main/Sources/AsyncAlgorithms/Locking.swift#L131) from `AsyncAlgorithms`. If `ManagedCriticalState` is ever made public, this will likely be migrated to a typealias:

```swift
public typealias Critical<Value> = ManagedCriticalState<Value>
```
