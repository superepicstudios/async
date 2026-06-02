//
//  ValueStream.swift
//  Async
//
//  Created by Mitch Treece on 6/1/26.
//  Copyright © 2026 Super Epic Studios, LLC.
//

@preconcurrency public import Combine
import Foundation

/// An observable stream that buffers a single element, and broadcasts it to downstream consumers.
///
/// ```swift
/// let stream = ValueStream<Int, Never>(1)
///
/// Task {
///     for try await e in stream {
///         print("Received: \(e)")
///     }
///     print("Finished")
/// }
///
/// stream.send(2)
/// stream.send(3)
/// stream.send(completion: .finished)
///
/// // → "Received: 1"
/// // → "Received: 2"
/// // → "Received: 3"
/// // → "Finished"
/// ```
///
/// - SeeAlso: ``CurrentValueSubject``
public final class ValueStream<Element: Sendable, Failure: Error>: StreamProtocol, StreamElementProviding, StreamErasing {

    public typealias Output = Element
    public typealias Base = ReplayStream<Element, Failure>
    public typealias AsyncIterator = Base.AsyncIterator
    
    public var latest: Element {
        self.base.latest
    }
    
    private let base = Base(1)

    /// Initializes a value stream.
    /// - parameter initial: An initial element.
    public init(_ initial: Element) {
        self.base.send(initial)
    }

    // MARK: AsyncSequence

    public func makeAsyncIterator() -> AsyncIterator {
        self.base.makeAsyncIterator()
    }

    // MARK: Publisher

    public func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
        self.base.receive(subscriber: subscriber)
    }
}

// MARK: Sending

extension ValueStream: StreamElementSending, StreamCompletionSending {
    
    public func send(_ element: Element) {
        self.base.send(element)
    }

    public func send(completion: Subscribers.Completion<Failure>) {
        self.base.send(completion: completion)
    }
}

// MARK: Observing

extension ValueStream: FailableStreamObserving, FailableStreamMainObserving {
    
    @discardableResult
    public func observe(
        priority: TaskPriority,
        receiveElement: @escaping @Sendable (Element) async -> Void,
        receiveError: (@Sendable (Failure) async -> Void)?
    ) -> Task<Void, Never> {
        self.base.observe(
            priority: priority,
            receiveElement: receiveElement,
            receiveError: receiveError
        )
    }
    
    @discardableResult
    public func observeOnMain(
        receiveElement: @escaping @MainActor (Element) async -> Void,
        receiveError: (@MainActor (Failure) async -> Void)?
    ) -> Task<Void, Never> {
        self.base.observeOnMain(
            receiveElement: receiveElement,
            receiveError: receiveError
        )
    }
}
