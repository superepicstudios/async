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
public final class PassthroughStream<Element: Sendable, Failure: Error>: FailableStream {
        
    private let base = ReplayStream<Element, Failure>(buffering: 0)
    
    public var publisher: any Publisher<Element, Failure> {
        self.base.publisher
    }
    
    public init() {}
    
    public func makeAsyncSequence() -> any AsyncSendableSequence<Element, Failure> {
        self.base.makeAsyncSequence()
    }
}

// MARK: Sending

extension PassthroughStream: StreamElementSending, FailableStreamCompletionSending {
    
    public func send(_ element: Element) {
        self.base.send(element)
    }
    
    public func send(completion: Subscribers.Completion<Failure>) {
        self.base.send(completion: completion)
    }
}

// MARK: Erasing

extension PassthroughStream: FailableStreamErasing {}

// MARK: Sequencing

extension PassthroughStream: StreamSequencing, StreamMainSequencing {}

// MARK: Observing

extension PassthroughStream: FailableStreamObserving, FailableStreamMainObserving {
    
    @discardableResult
    public func observe(
        priority: TaskPriority,
        receiveElement: @escaping @Sendable (Element) async -> Void,
        receiveFailure: (@Sendable (Failure) async -> Void)?
    ) -> Task<Void, Never> {
        self.base.observe(
            priority: priority,
            receiveElement: receiveElement,
            receiveFailure: receiveFailure
        )
    }
    
    @discardableResult
    public func observeOnMain(
        receiveElement: @escaping @MainActor (Element) async -> Void,
        receiveFailure: (@MainActor (Failure) async -> Void)?
    ) -> Task<Void, Never> {
        self.base.observeOnMain(
            receiveElement: receiveElement,
            receiveFailure: receiveFailure
        )
    }
}
