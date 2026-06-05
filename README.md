![Async](Assets/banner.png)

# ⏳ Async ⋅ ![Version](https://img.shields.io/badge/Version-0.1.0_βeta-fbfaf4.svg?labelColor=313244) ![Swift](https://img.shields.io/badge/Swift-6.3-fbfaf4.svg?logo=swift&logoColor=fbfaf4&labelColor=313244) ![iOS](https://img.shields.io/badge/iOS-18-fbfaf4.svg?logo=apple&logoColor=fbfaf4&labelColor=313244) ![macOS](https://img.shields.io/badge/macOS-15-fbfaf4.svg?logo=apple&logoColor=fbfaf4&labelColor=313244)

Async data-over-time, flow, & extension library that builds on the amazing work of [AsyncAlgorithms](https://github.com/apple/swift-async-algorithms), [AsyncExtensions](https://github.com/sideeffect-io/AsyncExtensions) and [CombineExt](https://github.com/combineCommunity/CombineExt). Async adds additional foundational types & helpers that make working with streams, sequences, channels, and publishers a breeze 😎

## 📖 Table of Contents

- [⬇️ Installation](#-installation)
- [📁 Structure](#-structure)
- [🌊 Streams](#-streams)
- [📡 Relays & Drivers](#-relays-&-drivers)
- [😶‍🌫️ Erasure](#-erasure)
- [📦 Property Wrappers](#property-wrappers)
- [🤝🏻 TaskActor](#-taskactor)
- [🔀 Combine](#-combine)
- [🧵 Thread Safety](#-thread-safety)
- [🗺️ Roadmap](#-roadmap)
- [👨🏻‍💻 Contributing](#-contributing)

## ⬇️ Installation

### SPM

The easiest way to get started, is installing via Xcode. All you have to do is add a package dependency with the following url: `https://github.com/superepicstudios/Async`. Developing your own package and want to depend on Async? Just add a package entry to your `Package.swift`:

```swift
.package(
    url: "https://github.com/superepicstudios/Async",
    from: "0.1.0"
)
```

## 📁 Structure

This package is split into three distinct modules:

- [Async](#): Core module containing stable types & features.
- [AsyncTesting](./Sources/AsyncTesting/README.md): Module containing async testing support & helpers.
- [AsyncExperiments](./Sources/AsyncExperiments/README.md): Module containing unstable types & features.
  Code in this module is subject to change, and may not ever be released. Use at your own risk.

## 🌊 Streams

Streams are unions between the standard library's [AsyncSequence](https://developer.apple.com/documentation/Swift/AsyncSequence) and Combine's [Publisher](https://developer.apple.com/documentation/combine/publisher). They can be used in either context, help bridge the gap between [Combine](https://developer.apple.com/documentation/combine) and modern async api's, and above all else - make working with async data fun again 🎉. In addition to wrapping `AsyncSequence` and `Publisher`, they also come with a wide range of built-in helpers, shortcuts, and syntax sugar.

### Sequencing & Observation

> [!WARNING]
> **TODO**: Explain the different stream observation methods, and when to use which one.
> Also explain why synchronous sequence & observe functions are preferred over direct iteration via `makeAsyncSequence()`.

- `sequence(body:)` & `sequenceOnMain(body:)`
- `observe(priority:receiveElement:receiveFailure:)` & `observeOnMain(receiveElement:receiveFailure:)`

### Stream Types

Streams have several different flavors that both reflect and extend their Combine [subject](https://developer.apple.com/documentation/combine/subject) counterparts.

#### [ReplayStream](https://github.com/superepicstudios/Async/blob/main/Sources/Async/Async/Streams/ReplayStream.swift)

A stream that replays a buffered amount of elements to downstream consumers.

```swift
let stream = ReplayStream<Int, Never>(buffering: 2)

stream.send(0) // dropped (outside buffer)
stream.send(1)
stream.send(2)

stream.sequence { seq in
    for try await e in seq {
        print("Received: \(e)")
    }
    print("Finished")
}

stream.send(3)
stream.send(completion: .finished)

// → "Received: 1"
// → "Received: 2"
// → "Received: 3"
// → "Finished"
```

#### [ValueStream](https://github.com/superepicstudios/Async/blob/main/Sources/Async/Async/Streams/ValueStream.swift)

A stream that buffers a single element, and sends it to downstream consumers.

```swift
let stream = ValueStream<Int, Never>(1)

stream.sequence { seq in
    for try await e in seq {
        print("Received: \(e)")
    }
    print("Finished")
}

stream.send(2)
stream.send(3)
stream.send(completion: .finished)

// → "Received: 1"
// → "Received: 2"
// → "Received: 3"
// → "Finished"
```

#### [PassthroughStream](https://github.com/superepicstudios/Async/blob/main/Sources/Async/Async/Streams/PassthroughStream.swift)

A stream that doesn't buffer any elements, and sends new ones to downstream consumers.

```swift
let stream = PassthroughStream<Int, Never>()

stream.send(0) // dropped (no consumers)

stream.sequence { seq in
    for try await e in seq {
        print("Received: \(e)")
    }
    print("Finished")
}

stream.send(1)
stream.send(2)
stream.send(3)
stream.send(completion: .finished)

// → "Received: 1"
// → "Received: 2"
// → "Received: 3"
// → "Finished"
```

#### [SignalStream](https://github.com/superepicstudios/Async/blob/main/Sources/Async/Async/Streams/SignalStream.swift)

A stream that sends signals to downstream consumers.

```swift
let stream = SignalStream<Never>()

stream.sequence { seq in
    for try await _ in seq {
        print("Received")
    }
    print("Finished")
}

stream.send()
stream.send(completion: .finished)

// → "Received"
// → "Finished"
```

#### [JustStream](https://github.com/superepicstudios/Async/blob/main/Sources/Async/Async/Streams/JustStream.swift)

A stream that buffers a single constant element, sends it to downstream consumers, never produces failures, and finishes immediately.

```swift
let stream = JustStream<Int>(1)

stream.sequence { seq in
    for await e in seq {
        print("Received: \(e)")
    }
    print("Finished")
}

// → "Received: 1"
// → "Finished"
```

#### [EmptyStream](https://github.com/superepicstudios/Async/blob/main/Sources/Async/Async/Streams/EmptyStream.swift)

A stream that produces no elements or failures, and finishes immediately.

```swift
let stream = EmptyStream()

stream.sequence { seq in
    for await e in seq {
        print("Received") // never called
    }
    print("Finished")
}

// → "Finished"
```

## 📡 Relays & Drivers

Streams are already easy to work with, but we don't always need the failure semantics most of them carry. When working in no-failure situations, we can leverage the specialized non-failable `Relay` and `Driver` streams.

### Relay

Simply put, relays are just streams that _never_ send failures. Or rather, they either never produce, or swallow errors internally. Relays are not concrete stream types like the ones shown above. Instead, you _erase_ existing streams into relays. More on that in the next section.

### [Driver](https://github.com/superepicstudios/Async/blob/main/Sources/Async/Async/Streams/Driver.swift)

Drivers are specialized streams that buffer a single element, send it to downstream consumers, never produce failures, and guarantee delivery on the main-actor. Unlike relays, drivers _are_ concrete stream types, and can be used similarly to the ones shown above.

```swift
let driver = Driver<Int>(1)

driver.sequenceOnMain { seq in
    for await e in seq {
        print("Received: \(e)")
    }
    print("Finished")
}

driver.send(2)
driver.send(3)
driver.send(completion: .finished)

// → "Received: 1"
// → "Received: 2"
// → "Received: 3"
// → "Finished"
```

> [!IMPORTANT]
> While drivers guarantee element _delivery_ on the main-actor, that same isolation cannot be enforced for direct `AsyncSequence` _observation_.
> It's recommended to use `sequenceOnMain(body:)` or `observeOnMain(receiveElement:)` as these enforce main-actor isolation for delivery _and_
> observation.

## 😶‍🌫️ Erasure

Similar to a Combine publisher's [eraseToAnyPublisher()](https://developer.apple.com/documentation/combine/publisher/erasetoanypublisher()), all streams support some form of type-erasure. Depending on the source stream, you can perform erasure using the following functions:

- `eraseToAnyStream()`
- `eraseToAnyRelay()`
- `eraseToAnyDriver()`

### [AnyStream](https://github.com/superepicstudios/Async/blob/main/Sources/Async/Async/Streams/AnyStream.swift)

A type-erased stream of elements.

```swift
let stream: ValueStream<Int, Never>(1)
let erased: AnyStream<Int, Never> = stream.eraseToAnyStream()

erased.sequence { seq in
    for try await e in seq {
        print("Received: \(e)")
    }
    print("Finished")
}

stream.send(2)
stream.send(3)
stream.send(completion: .finished)

// → "Received: 1"
// → "Received: 2"
// → "Received: 3"
// → "Finished"
```

### [AnyRelay](https://github.com/superepicstudios/Async/blob/main/Sources/Async/Async/Streams/AnyRelay.swift)

A type-erased stream of elements that never produces failures.

```swift
let stream = ValueStream<Int, Never>(1)
let erased: AnyRelay<Int> = stream.eraseToAnyRelay()

erased.sequence { seq in
    for await e in seq {
        print("Received: \(e)")
    }
    print("Finished")
}

stream.send(2)
stream.send(3)

// → "Received: 1"
// → "Received: 2"
// → "Received: 3"
// → "Finished"
```

### [AnyDriver](https://github.com/superepicstudios/Async/blob/main/Sources/Async/Async/Streams/AnyDriver.swift)

A type-erased stream of elements that never produces failures, and guarantees delivery on the main-actor.

```swift
let driver = Driver<Int>(1)
let erased: AnyDriver<Int> = driver.eraseToAnyDriver()

erased.sequenceOnMain { seq in
    for await e in seq {
        print("Received: \(e)")
    }
    print("Finished")
}

driver.send(2)
driver.send(3)

// → "Received: 1"
// → "Received: 2"
// → "Received: 3"
// → "Finished"
```

## 📦 Property Wrappers

Async also comes with a bunch of property wrappers that further simplify stream usage. It's a common practice to privately write, but publically expose a read-only stream. For example:

```swift
protocol ModelProtocol: Sendable {
    var count: AnyStream<Int, Never> { get }
}

final class Model: ModelProtocol {
    
    private let _count = ValueStream<Int, Never>(0)
    var count: AnyStream<Int, Never> {
        _count.eraseToAnyStream()
    }

    func increment() {
        let newCount = _count.latest + 1
        _count.send(newCount)
    }
}
```

Pretty straight-forward, but we can do better:

```swift
final class Model: ModelProtocol {
    
    @Stream<Int, Never>(0) var count
    // count: AnyStream<Int, Never>
    // $count: ValueStream<Int, Never>

    func increment() {
        let newCount = $count.latest + 1
        $count.send(newCount)
    }
}
```

> [!CAUTION]
> Property wrappers don't play nice with Swift 6 sendability requirements. The backing storage is always generated as a mutable `var`, regardless
> if it's actually mutable or not. Until Swift adds support for immutable backing storage for property wrappers, it's recommended to use streams
> directly. Alternatively, you can add `@unchecked Sendable` conformance to your enclosing type _if_ you're certain about its thread-safety semantics.

### [@Streamed](https://github.com/superepicstudios/Async/blob/main/Sources/Async/Async/Streams/PropertyWrappers/@Streamed.swift)

Wraps an element, and exposes an erased read-only ``AnyStream``.

```swift
@Streamed var value: Int = 1

$value.sequence { seq in
    for try await e in seq {
        print("Element: \(e)")
    }
}

value = 2
value = 3

// → "Element: 1"
// → "Element: 2"
// → "Element: 3"
```

### [@Stream](https://github.com/superepicstudios/Async/blob/main/Sources/Async/Async/Streams/PropertyWrappers/@Stream.swift)

Wraps a `ValueStream`, and exposes an erased read-only `AnyStream`.

```swift
@Stream<Int, Never>(1) var stream

stream.sequence { seq in
    for try await e in seq {
        print("Element: \(e)")
    }
    print("Finished")
}
    
$stream.send(2)
$stream.send(3)
$stream.send(completion: .finished)

// → "Element: 1"
// → "Element: 2"
// → "Element: 3"
// → "Finished"
```

### [@Relay](https://github.com/superepicstudios/Async/blob/main/Sources/Async/Async/Streams/PropertyWrappers/@Relay.swift)

Wraps a `ValueStream`, and exposes an erased read-only `AnyRelay`.

```swift
@Relay<Int>(1) var relay

relay.sequence { seq in
    for await e in seq {
        print("Element: \(e)")
    }
    print("Finished")
}

$relay.send(2)
$relay.send(3)
$relay.send(completion: .finished)

// → "Element: 1"
// → "Element: 2"
// → "Element: 3"
// → "Finished"
```

### [@Drive](https://github.com/superepicstudios/Async/blob/main/Sources/Async/Async/Streams/PropertyWrappers/@Drive.swift)

Wraps a `Driver`, and exposes an erased read-only `AnyDriver`.

```swift
@Drive<Int>(1) var driver

driver.sequenceOnMain { seq in
    for await e in seq {
        print("Element: \(e)")
    }
    print("Finished")
}

$driver.send(2)
$driver.send(3)
$driver.send(completion: .finished)

// → "Element: 1"
// → "Element: 2"
// → "Element: 3"
// → "Finished"
```

### [@Passthrough](https://github.com/superepicstudios/Async/blob/main/Sources/Async/Async/Streams/PropertyWrappers/@Passthrough.swift)

Wraps a `PassthroughStream`, and exposes an erased read-only `AnyStream`.

```swift
@Passthrough<Int, Never> var stream

$stream.send(0) // dropped (no consumers)

stream.sequence { seq in
    for try await e in seq {
        print("Element: \(e)")
    }
    print("Finished")
}

$stream.send(1)
$stream.send(2)
$stream.send(3)
$stream.send(completion: .finished)

// → "Element: 1"
// → "Element: 2"
// → "Element: 3"
// → "Finished"
```

### [@PassthroughRelay](https://github.com/superepicstudios/Async/blob/main/Sources/Async/Async/Streams/PropertyWrappers/@PassthroughRelay.swift)

Wraps a `PassthroughStream`, and exposes an erased read-only `AnyRelay`.

```swift
@PassthroughRelay<Int> var relay

$relay.send(0) // dropped (no consumers)

relay.sequence { seq in
    for await e in seq {
        print("Element: \(e)")
    }
    print("Finished")
}

$relay.send(1)
$relay.send(2)
$relay.send(3)
$stream.send(completion: .finished)

// → "Element: 1"
// → "Element: 2"
// → "Element: 3"
// → "Finished"
```

### [@Signal](https://github.com/superepicstudios/Async/blob/main/Sources/Async/Async/Streams/PropertyWrappers/@Signal.swift)

Wraps a `SignalStream`, and exposes an erased read-only `AnyStream`.

```swift
@Signal<Never> var stream

stream.sequence { seq in
    for try await _ in seq {
        print("Received")
    }
    print("Finished")
}

$stream.send()
$stream.send(completion: .finished)

// → "Received"
// → "Finished"
```

### [@SignalRelay](https://github.com/superepicstudios/Async/blob/main/Sources/Async/Async/Streams/PropertyWrappers/@SignalRelay.swift)

Wraps a `SignalStream`, and exposes an erased read-only `AnyRelay`.

```swift
@SignalRelay var relay

relay.sequence { seq in
    for await _ in seq {
        print("Received")
    }
    print("Finished")
}

$relay.send()
$relay.send(completion: .finished)

// → "Received"
// → "Finished"
```

### [@Pipe](https://github.com/superepicstudios/Async/blob/main/Sources/Async/Async/Streams/PropertyWrappers/@Pipe.swift)

Wraps an element, connects to an external stream, and re-streams its elements.

```swift
let stream = ValueStream<Int, Never>(1)

@Pipe var pipe: Int = 0
print("Pipe: \(pipe)")

$pipe.connect(to: stream)
print("Pipe: \(pipe)")

stream.send(2)
print("Pipe: \(pipe)")

stream.send(3)
print("Pipe: \(pipe)")

// → "Pipe: 0"
// → "Pipe: 1"
// → "Pipe: 2"
// → "Pipe: 3"
```

## 🤝🏻 TaskActor

Swift's introduction of [structured concurrency](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/concurrency) was a little heavy handed, to say the least. Even with recent enhancements, there are still some gaps and areas that could use a little love. One of these areas is task isolation. Async adds a new actor, [TaskActor](https://github.com/superepicstudios/Async/blob/main/Sources/Async/Async/TaskActor.swift), that helps isolate & execute tasks from other unrelated contexts.

```swift
final class ValueProvider: Sendable {

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

[Combine](https://developer.apple.com/documentation/combine) - despite Apple's neglect - is still a widely used & powerful reactive framework that makes controlling the flow of data simple & declarative. With the introduction of [structured concurrency](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/concurrency), its unclear exactly how this framework fits into Swift's roadmap. That being said, its not deprecated and will likely be sticking around (and used by many) for the forseeable future. Async also adds some quality-of-life additions and extensions around [Combine](https://developer.apple.com/documentation/combine). Just because something isn't the new hotness, doesn't mean it has to be ugly 🙃

### 📚 Subjects

[Combine](https://developer.apple.com/documentation/combine) comes out-of-the-box with `CurrentValueSubject` & `PassthroughSubject` implementations. Additionally, Async adds the following subject types:

### [SignalSubject](https://github.com/superepicstudios/Async/blob/main/Sources/Async/Combine/Subjects/SignalSubject.swift)

A subject that sends signals to downstream subscribers.

```swift
let subject = SignalSubject()

subject.sink { _ in
    print("Signal")
}

subject.send()

// → "Signal"
```

### [GuaranteeCurrentValueSubject](https://github.com/superepicstudios/Async/blob/main/Sources/Async/Combine/Guaranteee/GuaranteeCurrentValueSubject.swift)

A specialized [CurrentValueSubject](https://developer.apple.com/documentation/combine/currentvaluesubject) that can never fail.

```swift
let subject = GuaranteeCurrentValueSubject<Int>(0)
```

### [GuaranteePassthroughSubject](https://github.com/superepicstudios/Async/blob/main/Sources/Async/Combine/Guaranteee/GuaranteePassthroughSubject.swift)

A specialized [PassthroughSubject](https://developer.apple.com/documentation/combine/passthroughsubject) that can never fail.

```swift
let subject = GuaranteePassthroughSubject<Int>()
```

### [GuaranteeReplaySubject](https://github.com/superepicstudios/Async/blob/main/Sources/Async/Combine/Guaranteee/GuaranteeReplaySubject.swift)

A specialized [ReplaySubject](https://github.com/CombineCommunity/CombineExt/blob/main/Sources/Subjects/ReplaySubject.swift) that can never fail.

```swift
let subject = GuaranteeReplaySubject<Int>(buffering: 2)
```

## 🧵 Thread Safety

Though not directly related to asynchronous work, thread-safety is something that goes hand-in-hand with the concept. Modern Swift concurrency helps protect us from potential unsafe operations when working with async code. However, there are some scenarios where working in an unsafe asynchronous context is unavoidable. Async adds some additional helpers to make these scenarios are simple to navigate.

### 🔒 @Mutex

Prior to iOS 18 & macOS 15, thread-safe value locking was a manual process. With the introduction of the [Synchronization](https://developer.apple.com/documentation/os/synchronization) framework, we gained a new foundational [Mutex](https://developer.apple.com/documentation/synchronization/mutex) type that automatically handles locking for us. Despite being easy to use, the framework does not provide a macro implementation that a lot of us are accustomed to. For example:

```swift
@Locked var value: Int = 0
```

With the addition of modern Swift concurrency, property wrappers are considered unsafe due to their implicit mutability (see [here](https://forums.swift.org/t/static-property-wrappers-and-strict-concurrency-in-5-10/70116) for more information). However, we can work around this by directly generating code via a _macro_. Async implements a `@Mutex` macro that behaves exactly like the property wrappers of yore 👴🏻

```swift
@Mutex var value: Int = 0
```

Under the hood, this macro generates and maintains a mutex for you. All `get` & `set` operations are accessed through this mutex, and thus, protected! The generated code looks something like this:

```swift
@Mutex var value: Int = 0 {
    
    private let _value: Mutex<Int> = 0
    
    get { _value.withLock { $0 }}
    set { _value.withLock { $0 = newValue }}
}
```

## 🗺️ Roadmap

- [x] `0.0.1` (Initial Release)
- [ ] `0.1.0` (Stable Beta Release)
- [ ] `1.0.0` (Official Release)
  - [ ] Full documentation pass
  - [ ] Full test-coverage pass
  - [ ] Finalize demo project

## 👨🏻‍💻 Contributing

Pull-requests are more than welcome. Bug fix? Feature? Open a PR and we'll get it merged in! 🎉
