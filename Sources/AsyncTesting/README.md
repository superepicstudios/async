# 🔨 AsyncTesting

Async testing support & helpers.

## 🔀 [TestablePublisher](https://github.com/superepicstudios/Async/blob/main/Sources/AsyncTesting/Combine/TestablePublisher.swift)

A publisher that wraps another publisher, and exposes testing functions & helpers.

```swift
let subject = CurrentValueSubject<Int, Never>(1)
let sut = subject.testable()

subject.send(2)
subject.send(3)

await sut.expect(1, 2, 3)
```
