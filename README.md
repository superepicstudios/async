![Async](Assets/banner.png)

# ⏳ Async ⋅ ![Version](https://img.shields.io/badge/Version-0.1.0_βeta-fbfaf4.svg?labelColor=313244) ![Swift](https://img.shields.io/badge/Swift-6.3-fbfaf4.svg?logo=swift&logoColor=fbfaf4&labelColor=313244) ![iOS](https://img.shields.io/badge/iOS-18-fbfaf4.svg?logo=apple&logoColor=fbfaf4&labelColor=313244) ![macOS](https://img.shields.io/badge/macOS-15-fbfaf4.svg?logo=apple&logoColor=fbfaf4&labelColor=313244)

Async data-over-time (DoT), flow, & extension library that builds on the amazing work of [AsyncAlgorithms](https://github.com/apple/swift-async-algorithms), [AsyncExtensions](https://github.com/sideeffect-io/AsyncExtensions) and [CombineExt](https://github.com/combineCommunity/CombineExt). Async adds additional foundational types & helpers that make working with streams, sequences, channels, and publishers _much_ simpler.

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

The easiest way to get started, is installing via Xcode. All you have to do is add a package dependency with the following url: `https://github.com/superepicstudios/Async`
Developing your own package and want to depend on Async? Just add a package entry to your `Package.swift`:

```swift
.package(
    url: "https://github.com/superepicstudios/Async",
    from: "0.0.1"
)
```

## 📁 Structure

This package is split into three distinct modules:

- [Async](#): Core module containing stable types & features.
- [AsyncTesting](./Sources/AsyncTesting/README.md): Module containing async testing support & helpers.
- [AsyncExperiments](./Sources/AsyncExperiments/README.md): Module containing experimental/unstable types & features.
  Code in this module is subject to change, and may not ever be released.

## 🌊 Streams

Streams are unions between the standard library's [AsyncSequence](https://developer.apple.com/documentation/Swift/AsyncSequence) and Combine's [Publisher](https://developer.apple.com/documentation/combine/publisher). They can be used in either context, and help bridge the gap between [Combine](https://developer.apple.com/documentation/combine) and modern async api's. In addition to `AsyncSequence` and `Publisher` conformance, they also have a wide range of built-in helpers, shortcuts, and syntax sugar. Streams come in several different flavors that both extend, and reflect the various Combine [subjects](https://developer.apple.com/documentation/combine/subject).

### [ReplayStream](https://github.com/superepicstudios/Async/blob/main/Sources/Async/Async/Streams/ReplayStream.swift)

An observable stream that replays a buffered amount of elements to downstream consumers.

```swift
let stream = ReplayStream<Int, Never>(2)

stream.send(1)
stream.send(2)
stream.send(3)
stream.send(completion: .finished)

Task { 
    for try await e in stream {
        print("Received: \(e)")
    }
    print("Finished")
}

// → "Received: 2"
// → "Received: 3"
// → "Finished"
```

### [ValueStream](https://github.com/superepicstudios/Async/blob/main/Sources/Async/Async/Streams/ValueStream.swift)

An observable stream that buffers a single element, and sends it to downstream consumers.

```swift
let stream = ValueStream<Int, Never>(1)

Task {
    for try await e in stream {
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

### [PassthroughStream](https://github.com/superepicstudios/Async/blob/main/Sources/Async/Async/Streams/PassthroughStream.swift)

An observable stream that doesn't buffer elements, and sends new ones to downstream consumers.

```swift
let stream = PassthroughStream<Int, Never>()

stream.send(1) // Dropped (no consumers)

Task {
    for try await e in stream {
        print("Received: \(e))
    }
    print("Finished")
}

stream.send(2)
stream.send(3)
stream.send(completion: .finished)

// → "Received: 2"
// → "Received: 3"
// → "Finished"
```

### [SignalStream](https://github.com/superepicstudios/Async/blob/main/Sources/Async/Async/Streams/SignalStream.swift)

An observable stream that sends signals to downstream consumers.

```swift
let stream = SignalStream<Never>()

Task {
    for try await _ in stream {
        print("Received")
    }
    print("Finished")
}

stream.send()
stream.send(completion: .finished)

// → "Received"
// → "Finished"
```

### [JustStream](https://github.com/superepicstudios/Async/blob/main/Sources/Async/Async/Streams/JustStream.swift)

An observable stream that buffers a single constant element, and sends it to downstream consumers.

```swift
let stream = JustStream<Int>(0)

Task {
    for await e in stream {
        print("Received: \(e)")
    }
}

// → "Received: 0"
```

### [EmptyStream](https://github.com/superepicstudios/Async/blob/main/Sources/Async/Async/Streams/EmptyStream.swift)

An observable stream that produces no elements.

```swift
let stream = EmptyStream()

Task {
    for await _ in stream {
        print("Received") // Never called
    }
}
```

## 📡 Relays & Drivers

Streams are already easy to work with, but we don't always need the failure semantics they carry. When working in no-failure situations, we can leverage the specialized non-failable `Relay` and `Driver` stream types.

### Relays

Simply put, relays are just streams that *never* produce failures. Or rather, they either never produce, or swallow errors internally. Relays are not concrete stream types like the ones shown above. Instead, you _erase_ existing streams into relays. More on that in the next section.

### [Driver](https://github.com/superepicstudios/Async/blob/main/Sources/Async/Async/Streams/Driver.swift)

Drivers are specialized observable streams that buffer a single element, send it to downstream consumers, never produces failures, and guarantee delivery on the main-actor. Unlike relays, drivers _are_ concrete stream types, and can be used similarly to the ones hows above.

```swift
let driver = Driver<Int>(1)

driver.observeOnMain { e in
    print("Received: \(e)")
}

driver.send(2)
driver.send(3)

// → "Received: 1"
// → "Received: 2"
// → "Received: 3"
```

## 😶‍🌫️ Erasure

In a similar fashion to a Combine publisher's [eraseToAnyPublisher()](https://developer.apple.com/documentation/combine/publisher/erasetoanypublisher()), all streams support some form of type-erasure. Depending on the source stream, erasure is achieved via `eraseToAnyStream()`, `eraseToAnyRelay()`, or `eraseToAnyDriver()`.

### [AnyStream](https://github.com/superepicstudios/Async/blob/main/Sources/Async/Async/Streams/AnyStream.swift)

A type-erased observable stream of elements.

```swift
let stream = ValueStream<Int, Never>(1)
let erased: AnyStream<Int, Never> = stream.eraseToAnyStream()

Task {
    for try await e in erased {
        print("Received: \(e)")
    }
}

stream.send(2)
stream.send(3)

// → "Received: 1"
// → "Received: 2"
// → "Received: 3"
```

### [AnyRelay](https://github.com/superepicstudios/Async/blob/main/Sources/Async/Async/Streams/AnyRelay.swift)

A type-erased observable stream of elements that never produces failures.

```swift
let stream = ValueStream<Int, Never>(1)
let erased: AnyRelay<Int> = stream.eraseToAnyRelay()

Task {
    for await e in erased {
        print("Received: \(e)")
    }
}

stream.send(2)
stream.send(3)

// → "Received: 1"
// → "Received: 2"
// → "Received: 3"
```

### [AnyDriver](https://github.com/superepicstudios/Async/blob/main/Sources/Async/Async/Streams/AnyDriver.swift)

A type-erased observable stream of elements that never produces failures, and guarantees delivery on the main-actor.

```swift
let driver = Driver<Int>(1)
let erased: AnyDriver<Int> = driver.eraseToAnyDriver()

erased.observeOnMain { e in
    print("Received: \(e)")
}

driver.send(2)
driver.send(3)

// → "Received: 1"
// → "Received: 2"
// → "Received: 3"
```

## 📦 Property Wrappers

> [!NOTE]
> TODO: Property wrapper overview

> [!CAUTION]
> TODO: Explain Swift 6 sendability issues

### @Streamed
### @Stream
### @Relay
### @Drive
### @Passthrough
### @PassthroughRelay
### @Signal
### @SignalRelay
### @Pipe

## 🤝🏻 TaskActor

Swift's introduction of [structured concurrency](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/concurrency) was a little heavy handed, to say the least. Even with the enhancements coming with Swift 6.2 & Xcode 26, there are still some gaps and areas that could use a little love. One of these areas is task isolation. Async adds a new actor, [TaskActor](https://github.com/superepicstudios/Async/blob/main/Sources/Async/Async/TaskActor.swift), that helps isolate & execute tasks from other unrelated contexts.

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

[Combine](https://developer.apple.com/documentation/combine) - despite Apple's neglect - is still a widely used & powerful reactive framework that makes controlling the flow of data simple & declarative. With the introduction of [structured concurrency](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/concurrency), its unclear exactly how this framework fits into Swift's roadmap. That being said, its not deprecated and will likely be sticking around (and used by many) for the forseeable future. Async also adds some quality-of-life additions & extensions around [Combine](https://developer.apple.com/documentation/combine). Just because something isn't the new hotness, doesn't mean it has to be ugly 🙃

### 📚 Subjects

[Combine](https://developer.apple.com/documentation/combine) comes out-of-the-box with `CurrentValueSubject` & `PassthroughSubject` implementations. Additionally, Async adds the following subject types:

#### [SignalSubject](https://github.com/superepicstudios/Async/blob/main/Sources/Async/Combine/Subjects/SignalSubject.swift)

A subject that sends signals to downstream subscribers.

```swift
let subject = SignalSubject()

subject.sink { _ in
    print("Signal")
}

subject.send()

// → "Signal"
```

#### [GuaranteeCurrentValueSubject](https://github.com/superepicstudios/Async/blob/main/Sources/Async/Combine/Guaranteee/GuaranteeCurrentValueSubject.swift)

A [CurrentValueSubject](https://developer.apple.com/documentation/combine/currentvaluesubject) that can never fail.

```swift
let subject = GuaranteeCurrentValueSubject<Int>(0)
```

#### [GuaranteePassthroughSubject](https://github.com/superepicstudios/Async/blob/main/Sources/Async/Combine/Guaranteee/GuaranteePassthroughSubject.swift)

A [PassthroughSubject](https://developer.apple.com/documentation/combine/passthroughsubject) that can never fail.

```swift
let subject = GuaranteePassthroughSubject<Int>()
```

#### [GuaranteeReplaySubject](https://github.com/superepicstudios/Async/blob/main/Sources/Async/Combine/Guaranteee/GuaranteeReplaySubject.swift)

A [ReplaySubject](https://github.com/CombineCommunity/CombineExt/blob/main/Sources/Subjects/ReplaySubject.swift) that can never fail.

```swift
let subject = GuaranteeReplaySubject<Int>(buffering: 1)
```

## 🧵 Thread Safety

Though not directly related to asynchronous work, thread-safety is something that goes hand-in-hand with the concept. Modern Swift concurrency helps protect us from potential unsafe operations when working with async code. However, there are some scenarios where working in an unsafe asynchronous context is unavoidable. Async adds some additional helpers to make these scenarios simple to navigate.

### 🔒 @Mutex

Prior to iOS 18 & macOS 15, thread-safe value locking was a manual process. With the introduction of the [Synchronization](https://developer.apple.com/documentation/os/synchronization) framework, we gained a new foundational [Mutex](https://developer.apple.com/documentation/synchronization/mutex) type that automatically handles locking for us. Despite being easy to use, the framework does not provide any sort of locking macro implementation that a lot of us are accustomed to:

```swift
@Locked var value: Int = 0
```

With the addition of modern Swift concurrency, property-wrappers are considered unsafe due to their implicit mutability (see [here](https://forums.swift.org/t/static-property-wrappers-and-strict-concurrency-in-5-10/70116) for more information). However, we can work around this by directly generating code via a _macro_. Async implements a `@Mutex` macro that behaves exactly like the property-wrappers of old 🙌🏻

```swift
@Mutex var value: Int = 0
```

Under the hood, this macro generates & maintains a mutex for you. All `get` & `set` operations are accessed through this mutex, and thus, protected! The generated code looks something like this:

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
