# 🔨 AsyncTesting

Async testing support & helpers.

## 🔀 TestablePublisher

```swift
let subject = GuaranteeCurrentValueSubject<Int>(1)
let sut = subject.testable()

subject.send(2)
subject.send(3)

await sut.expect(1, 2, 3)
```
