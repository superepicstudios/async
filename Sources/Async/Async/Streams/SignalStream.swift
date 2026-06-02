//
//  SignalStream.swift
//  Async
//
//  Created by Mitch Treece on 6/1/26.
//  Copyright © 2026 Super Epic Studios, LLC.
//

@preconcurrency public import Combine
import Foundation

/// An observable stream that broadcasts signals to downstream consumers.
///
/// ```swift
/// let stream = SignalStream<Never>()
///
/// Task {
///     for try await _ in stream {
///         print("Received")
///     }
///     print("Finished")
/// }
///
/// stream.send()
/// stream.send(completion: .finished)
///
/// // → "Received"
/// // → "Finished"
/// ```
public final class SignalStream<Failure: Error>: StreamProtocol, StreamErasing {
    
    public typealias Output = Void
    public typealias Base = PassthroughStream<Void, Failure>
    public typealias AsyncIterator = Base.AsyncIterator

    private let base = Base()

    /// Initializes a signal stream.
    public init() {}
    
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

extension SignalStream: StreamElementSending, StreamCompletionSending {
    
    public func send(_ element: Element) {
        self.base.send(element)
    }

    public func send(completion: Subscribers.Completion<Failure>) {
        self.base.send(completion: completion)
    }
}

// MARK: Observing

extension SignalStream: FailableStreamObserving, FailableStreamMainObserving {
    
    @discardableResult
    public func observe(
        priority: TaskPriority,
        receiveElement: @escaping @Sendable (Void) async -> Void,
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
        receiveElement: @escaping @MainActor (Void) async -> Void,
        receiveError: (@MainActor (Failure) async -> Void)?
    ) -> Task<Void, Never> {
        self.base.observeOnMain(
            receiveElement: receiveElement,
            receiveError: receiveError
        )
    }
}
