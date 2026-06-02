//
//  Driver.swift
//  Async
//
//  Created by Mitch Treece on 6/1/26.
//  Copyright © 2026 Super Epic Studios, LLC.
//

@preconcurrency public import Combine
import Foundation

/// A specialized observable stream that buffers a single element, broacasts it to downstream consumers,
/// never produces failures, and guarantees delivery on the main-actor.
///
/// This is similar to ``AnyRelay``, except that element delivery is always isolated to the main-actor.
///
/// ```swift
/// let driver = Driver<Int>(1)
///
/// driver.observeOnMain { e in
///     print("Received: \(e)")
/// }
///
/// driver.send(2)
/// driver.send(3)
///
/// // → "Received: 1"
/// // → "Received: 2"
/// // → "Received: 3"
/// ```
///
/// - Warning: While element **delivery** is guaranteed to be main-actor isolated,
///   that same isolation cannot be enforced for ``AsyncSequence`` **observation**.
///   It's recommended to use ``observeOnMain(receiveElement:)`` or ``sink(receiveValue:)``
///   as these guarantee main-actor isolation for delivery **and** observation.
///
/// - SeeAlso: ``ValueStream``, ``AnyRelay``
public final class Driver<Element: Sendable>: AsyncSequence, Publisher, StreamElementProviding, Sendable {
    
    public typealias Output = Element
    public typealias Failure = Never
    public typealias AsyncIterator = AsyncStream<Element>.AsyncIterator
    
//    @MainActor
    public var latest: Element {
        self.stream.latest
    }
    
    private let stream: ValueStream<Element, Never>
    
    /// Initializes a driver stream.
    /// - parameter initial: An initial element.
    public init(_ initial: Element) {
        self.stream = ValueStream<Element, Never>(initial)
    }
    
    // MARK: AsyncSequence
    
    public func makeAsyncIterator() -> AsyncStream<Element>.AsyncIterator {
        AsyncStream<Element> { continuation in
            let task = Task {
                for await element in self.stream {
                    _ = await MainActor.run {
                        continuation.yield(element)
                    }
                }
                await MainActor.run {
                    continuation.finish()
                }
            }
            continuation.onTermination = { _ in
                task.cancel()
            }
        }
        .makeAsyncIterator()
    }
    
    // MARK: Publisher
    
    public func receive<S>(subscriber: S) where S : Subscriber, Never == S.Failure, Element == S.Input {
        self.stream
//            .catch { _ in Empty<Element, Never>() }
            .receive(on: DispatchQueue.main)
            .receive(subscriber: subscriber)
    }
}

// MARK: Sending

extension Driver: StreamElementSending {
    public func send(_ element: Element) {
        self.stream.send(element)
    }
}

// MARK: Observing

extension Driver: NonFailableStreamMainObserving {
    
    @discardableResult
    public func observeOnMain(receiveElement: @escaping @MainActor (Element) async -> Void) -> Task<Void, Never> {
        self.stream.observeOnMain(receiveElement: receiveElement)
    }
}

// MARK: Erasing

extension Driver {
    
    public func eraseToAnyDriver() -> AnyDriver<Element> {
        AnyDriver(self)
    }
}
