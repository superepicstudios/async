![Async](Assets/banner.png)

# ⏳ Async ⋅ ![Version](https://img.shields.io/badge/Version-0.0.1_βeta-fbfaf4.svg?labelColor=313244) ![Swift](https://img.shields.io/badge/Swift-6-fbfaf4.svg?logo=swift&logoColor=fbfaf4&labelColor=313244) ![iOS](https://img.shields.io/badge/iOS-18-fbfaf4.svg?logo=apple&logoColor=fbfaf4&labelColor=313244) ![macOS](https://img.shields.io/badge/macOS-15-fbfaf4.svg?logo=apple&logoColor=fbfaf4&labelColor=313244)

Async data-over-time (DoT), flow, & extension library that builds on the amazing work of [AsyncAlgorithms](https://github.com/apple/swift-async-algorithms) & [AsyncExtensions](https://github.com/sideeffect-io/AsyncExtensions). `Async` adds additional foundational types & helpers that make working with channels, streams, sequences, subjects, and publishers _much_ simpler - all while bridging the gaps between them.

## 💬 Channels

[AsyncAlgorithms](https://github.com/apple/swift-async-algorithms) introduced two new foundational types, [AsyncChannel](https://swiftpackageindex.com/apple/swift-async-algorithms/main/documentation/asyncalgorithms/asyncchannel) & [AsyncThrowingChannel](https://swiftpackageindex.com/apple/swift-async-algorithms/main/documentation/asyncalgorithms/asyncthrowingchannel). These are great, but leave something to be desired in the context of buffered elements. The ability for a channel to buffer its elements (without suspending on send) is **required** for other foundational types, such as async subjects. `Async` adds these new channel types:

- [AsyncBufferedChannel](https://github.com/superepicstudios/Async/blob/main/Sources/Async/Async/Channel/AsyncBufferedChannel.swift)
- [AsyncThrowingBufferedChannel](https://github.com/superepicstudios/Async/blob/main/Sources/Async/Async/Channel/AsyncThrowingBufferedChannel.swift)

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

### [AsyncReplaySubject](https://github.com/superepicstudios/Async/blob/main/Sources/Async/Async/Subjects/AsyncReplaySubject.swift)

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

### [AsyncCurrentValueSubject](https://github.com/superepicstudios/Async/blob/main/Sources/Async/Async/Subjects/AsyncCurrentValueSubject.swift)

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

### [AsyncPassthroughSubject](https://github.com/superepicstudios/Async/blob/main/Sources/Async/Async/Subjects/AsyncPassthroughSubject.swift)

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

### [AsyncSignalSubject](https://github.com/superepicstudios/Async/blob/main/Sources/Async/Async/Subjects/AsyncSignalSubject.swift)

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

## 🤝🏻 TaskActor

Swift's introduction of [structured concurrency](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/concurrency) was a little heavy handed, to say the least. Even with the enhancements coming with Swift 6.2 & Xcode 26, there are still some gaps and areas that could use a little love. One of these areas is task isolation. `Async` adds a new actor, [TaskActor](https://github.com/superepicstudios/Async/blob/main/Sources/Async/Async/TaskActor.swift), that helps isolate & execute tasks from other unrelated contexts.

```swift
class ValueProvider {

    private(set) var value: Int = 0
    private let generator = NumberGenerator()
    private let updateTask = TaskActor<Int>()

    func update() async {

        self.value = await self.updateTask.run { [weak self] in
            await self?.generator.generate() ?? 0
        }

    }

}
```

## 🔀 Combine

[Combine](https://developer.apple.com/documentation/combine) - despite Apple's neglect - is still a widely used & powerful reactive framework that makes controlling the flow of data simple & declarative. With the introduction of [structured concurrency](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/concurrency), its unclear exactly how this framework fits into Swift's roadmap. That being said, its not deprecated and will likely be sticking around (and used by many) for the forseeable future. `Async` also adds some quality-of-life additions & extensions around `Combine`. Just because something is "legacy", doesn't mean it has to be ugly 🙃

### 📚 Combine Subjects

[Combine](https://developer.apple.com/documentation/combine) comes out-of-the-box with `CurrentValueSubject` & `PassthroughSubject` implementations. Additionally, `Async` adds the following subject types:

#### [GuaranteeCurrentValueSubject](https://github.com/superepicstudios/Async/blob/main/Sources/Async/Combine/Subjects/GuaranteeCurrentValueSubject.swift)

```swift
// A `CurrentValueSubject` that can never fail
let subject = GuaranteeCurrentValueSubject<Int>(0)
```

#### [GuaranteePassthroughSubject](https://github.com/superepicstudios/Async/blob/main/Sources/Async/Combine/Subjects/GuaranteePassthroughSubject.swift)

```swift
// A `PassthroughSubject` that can never fail
let subject = GuaranteePassthroughSubject<Int>()
```

#### [SignalSubject](https://github.com/superepicstudios/Async/blob/main/Sources/Async/Combine/Subjects/SignalSubject.swift)

```swift
// Broadcasts signals to downstream subscribers.

let subject = SignalSubject()

subject.sink { _ in
    print("Signal")
}

subject.send()

// → "Signal"
```

## 🧵 Thread Safety

Though not directly related to asynchronous work, thread-safety is something that goes hand-in-hand with the concept. Modern Swift concurrency helps protect us from potential unsafe operations when working with async code. However, there are some scenarios where working in an unsafe asynchronous context is unavoidable. `Async` adds some additional helpers to make these scenarios simple to navigate.

### ⚠️ Critical

When tracking critical state or values, it's important to protect against scenarios that could potentially introduce unsafe read & write operations. Different threads attempting to access a single value at the same time can be a recipe for disaster. `Async` adds a foundational [Critical](https://github.com/superepicstudios/Async/blob/main/Sources/Async/ThreadSafety/Critical.swift) type that helps protect against these scanarios.

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

### 🔒 @Mutex

Prior to iOS 18 & macOS 15, thread-safe value locking was a manual process. With the introduction of the [Synchronization](https://developer.apple.com/documentation/os/synchronization) framework, we gained a new foundational [Mutex](https://developer.apple.com/documentation/synchronization/mutex) type that automatically handles locking for us. Despite being easy to use, the framework does not provide any sort of macro implementation that a lot of us have gotten accustomed to:

```swift
@Locked var value: Int = 0
```

With the addition of modern Swift concurrency, property-wrappers are considered unsafe due to their implicit mutability (see [here](https://forums.swift.org/t/static-property-wrappers-and-strict-concurrency-in-5-10/70116) for more information). However, we can work around this by directly generating code via a _macro_. `Async` implements a `@Mutex` macro that behaves exactly like the property-wrappers of old 🙌🏻

```swift
@Mutex var value: Int = 0
```

Under the hood, this macro generates & maintains a mutex for you. All `get` & `set` operations are accessed through this mutex, and thus, protected! The generated code looks something like this:

```swift
@Mutex var value: Int = 0 {

    private let _value: Mutex<Int> = 0

    get {
        _value.withLock { $0 }
    }

    set {
        _value.withLock { $0 = newValue }
    }

}
```

## 🗺️ Roadmap

- `0.0.1` (Initial Release)

- `1.0.0` (Official Release)
  - [ ] Async & Combine macro wrappers
    - [ ] `@PublishedPipe`
    - [ ] `@PublishingValue`
    - [ ] `@PublishingPassthrough`
    - [ ] `@PublishingSignal`
    - [ ] `@Streamed`
    - [ ] `@StreamedPipe`
    - [ ] `@StreamingValue`
    - [ ] `@StreamingPassthrough`
    - [ ] `@StreamingSignal`
  - [ ] Validate macro wrappers against `ObservableObject` & `@Observable`
  - [ ] Finalize demo project

## 👨🏻‍💻 Contributing

Pull-requests are more than welcome. Bug fix? Feature? Open a PR and we'll get it merged in! 🎉
