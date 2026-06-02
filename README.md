![Async](Assets/banner.png)

# ⏳ Async ⋅ ![Version](https://img.shields.io/badge/Version-0.1.0_βeta-fbfaf4.svg?labelColor=313244) ![Swift](https://img.shields.io/badge/Swift-6.3-fbfaf4.svg?logo=swift&logoColor=fbfaf4&labelColor=313244) ![iOS](https://img.shields.io/badge/iOS-18-fbfaf4.svg?logo=apple&logoColor=fbfaf4&labelColor=313244) ![macOS](https://img.shields.io/badge/macOS-15-fbfaf4.svg?logo=apple&logoColor=fbfaf4&labelColor=313244)

Async data-over-time (DoT), flow, & extension library that builds on the amazing work of [AsyncAlgorithms](https://github.com/apple/swift-async-algorithms), [AsyncExtensions](https://github.com/sideeffect-io/AsyncExtensions) and [CombineExt](https://github.com/combineCommunity/CombineExt). `Async` adds additional foundational types & helpers that make working with channels, streams, sequences, subjects, and publishers _much_ simpler - all while bridging the gaps between them.

## 📖 Table of COntents

▶︎ [⬇️ Installation](#-installation)
▶︎ [📁 Structure](#-structure)
<details><summary>🌊 Streams</summary>
  <details><summary href="#-replaystream">ReplayStream</summary></details>
</details>

- [🌊 Streams](#-streams)
  - [ReplayStream](#replaystream)
  - [ValueStream](#valuestream)
  - [Driver](#driver)
  - [PassthroughStream](#passthroughstream)
  - [SignalStream](#signalstream)
  - [JustStream](#juststream)
  - [EmptyStream](#emptystream)
- [📡 Relays](#-relays)
- [😶‍🌫️ Erasure](#-erasure)
  - [AnyStream](#anystream)
  - [AnyRelay](#anyrelay)
  - [AnyDriver](#anydriver)
- [📦 Property Wrappers](#property-wrappers)
  - [@Streamed](#@streamed)
  - [@Stream](#@stream)
  - [@Relay](#@relay)
  - [@Drive](#@drive)
  - [@Passthrough](#@passthrough)
  - [@PassthroughRelay](#@passthroughrelay)
  - [@Signal](#@signal)
  - [@SignalRelay](#@signalrelay)
  - [@Pipe](#@pipe)
- [🤝🏻 TaskActor](#-taskactor)
- [🔀 Combine](#-combine)
- [🧵 Thread Safety](#-thread-safety)
  - [🔒 @Mutex](#-@mutex)
- [👨🏻‍💻 Contributing](#-contributing)

## ⬇️ Installation

### SPM

The easiest way to get started, is installing via Xcode. All you have to do is add a package dependency with the following url: `https://github.com/superepicstudios/Async`
Developing your own package and want to depend on `Async`? Just add a package entry to your `Package.swift`:

```swift
.package(
    url: "https://github.com/superepicstudios/Async",
    from: "0.0.1"
)
```

## 📁 Structure

This package is split into three distinct modules:

- `Async`: Core module containing stable types & features.
- [AsyncTesting](./Sources/AsyncTesting/README.md): Module containing async testing support & helpers.
- [AsyncExperiments](./Sources/AsyncExperiments/README.md): Module containing experimental/unstable types & features.
  Code in this module is subject to change, and may not ever be released.

## 🌊 Streams

> [!NOTE]
> TODO: Stream overview

### ReplayStream
### ValueStream
### Driver
### PassthroughStream
### SignalStream
### JustStream
### EmptyStream

## 📡 Relays

> [!NOTE]
> TODO: Relay overview + explain how they're not a concrete type, and lead into next erasure section

## 😶‍🌫️ Erasure

### AnyStream
### AnyRelay
### AnyDriver

## 📦 Property Wrappers

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

### 📚 Subjects

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

    get { _value.withLock { $0 }}
    set { _value.withLock { $0 = newValue }}
}
```

## 👨🏻‍💻 Contributing

Pull-requests are more than welcome. Bug fix? Feature? Open a PR and we'll get it merged in! 🎉
