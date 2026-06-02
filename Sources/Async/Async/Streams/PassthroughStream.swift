//
//  PassthroughStream.swift
//  Async
//
//  Created by Mitch Treece on 6/1/26.
//  Copyright © 2026 Super Epic Studios, LLC.
//

@preconcurrency public import Combine
import Foundation

/// An observable stream that doesn't buffer elements, and broadcasts new ones to downstream consumers.
///
/// ```swift
/// let stream = PassthroughStream<Int, Never>()
///
/// stream.send(1) // Dropped (no consumers)
///
/// Task {
///     for try await e in stream {
///         print("Received: \(e))
///     }
///     print("Finished")
/// }
///
/// stream.send(2)
/// stream.send(3)
/// stream.send(completion: .finished)
///
/// // → "Received: 2"
/// // → "Received: 3"
/// // → "Finished"
/// ```
///
/// - SeeAlso: ``PassthroughSubject``
public final class PassthroughStream<Element: Sendable, Failure: Error>: StreamProtocol, StreamErasing {
    
    public typealias Output = Element
    public typealias Base = ReplayStream<Element, Failure>
    public typealias AsyncIterator = Base.AsyncIterator
    
    private let base = Base(0)
    
    /// Initializes a passthrough stream.
    public init() {}
    
    // MARK: AsyncSequence
    
    public func makeAsyncIterator() -> AsyncIterator {
        self.base.makeAsyncIterator()
    }
    
    // MARK: Publisher
    
    public func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Element == S.Input {
        self.base.receive(subscriber: subscriber)
    }
}

// MARK: Sending

extension PassthroughStream: StreamElementSending, StreamCompletionSending {
    
    public func send(_ element: Element) {
        self.base.send(element)
    }
    
    public func send(completion: Subscribers.Completion<Failure>) {
        self.base.send(completion: completion)
    }
}

// MARK: Observing

extension PassthroughStream: FailableStreamObserving, FailableStreamMainObserving {
    
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
