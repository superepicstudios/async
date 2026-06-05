//
//  Driver.swift
//  Async
//
//  Created by Mitch Treece on 6/1/26.
//  Copyright © 2026 Super Epic Studios, LLC.
//

@preconcurrency public import Combine
import Foundation

/// A specialized stream that buffers a single element, sends it to downstream consumers,
/// never produces failures, and guarantees delivery on the main-actor.
///
/// This is similar to ``AnyRelay``, except that element delivery is always main-actor isolated.
///
/// ```swift
/// let driver = Driver<Int>(1)
///
/// driver.sequenceOnMain { seq in
///     for await e in seq {
///         print("Received: \(e)")
///     }
///     print("Finished")
/// }
///
/// driver.send(2)
/// driver.send(3)
/// driver.send(completion: .finished)
///
/// // → "Received: 1"
/// // → "Received: 2"
/// // → "Received: 3"
/// // → "Finished"
/// ```
///
/// - Warning: While element _delivery_ is guaranteed to be main-actor isolated,
///   that same isolation cannot be enforced for direct ``AsyncSequence`` _observation_
///   via ``makeAsyncSequence()``. It's recommended to use ``sequenceOnMain(body:)`` or
///   ``observeOnMain(onElement:onFinished:)`` as these enforce main-actor isolation for
///   delivery _and_ observation.
///
/// - SeeAlso: ``ValueStream``, ``AnyRelay``
public final class Driver<Element: Sendable>: NonFailableStream {
    
    private let base: ValueStream<Element, Never>
    
    public init(_ initial: Element) {
        self.base = .init(initial)
    }
    
    public func makeAsyncSequence() -> any AsyncSendableSequence<Element, Never> {
        AsyncMainActorSequence<Element, Never>(self.base.makeAsyncSequence())
    }
    
    public func makePublisher() -> any Publisher<Element, Never> {
        MainQueuePublisher<Element, Never>(self.base.makePublisher())
    }
}

// MARK: Sending

extension Driver: StreamElementSending, NonFailableStreamCompletionSending {
    
    public func send(_ element: Element) {
        self.base.send(element)
    }
    
    public func send(completion: Subscribers.Completion<Never>) {
        self.base.send(completion: completion)
    }
}

// MARK: Erasing

extension Driver: NonFailableStreamErasing {

    /// Erases the stream into a read-only driver.
    /// - returns: A type-erased driver.
    public func eraseToAnyDriver() -> AnyDriver<Element> {
        AnyDriver(self)
    }
}

// MARK: Sequencing

extension Driver: StreamMainSequencing {}

// MARK: Element

extension Driver: StreamElementMainProviding, NonFailableStreamElementMainObserving {

    @MainActor
    public var latest: Element {
        self.base.latest
    }

    @discardableResult
    public func observeOnMain(
        onElement: @escaping @MainActor (Element) async -> Void,
        onFinished: (@MainActor () async -> Void)?
    ) -> Task<Void, Never> {
        self.base.observeOnMain(
            onElement: onElement,
            onFinished: onFinished
        )
    }
}
