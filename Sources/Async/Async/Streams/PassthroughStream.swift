//
//  PassthroughStream.swift
//  Async
//
//  Created by Mitch Treece on 6/1/26.
//  Copyright © 2026 Super Epic Studios, LLC.
//

@preconcurrency public import Combine
import Foundation

/// A stream that doesn't buffer any elements, and sends new ones to downstream consumers.
///
/// ```swift
/// let stream = PassthroughStream<Int, Never>()
///
/// stream.send(0) // Dropped (no consumers)
///
/// stream.sequence { seq in
///     for try await e in seq {
///         print("Received: \(e)")
///     }
///     print("Finished")
/// }
///
/// stream.send(1)
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
/// - SeeAlso: ``ReplayStream``, ``PassthroughSubject``
public final class PassthroughStream<Element: Sendable, Failure: Error>: FailableStream {
        
    private let base = ReplayStream<Element, Failure>(buffering: 0)
    
    public init() {}
    
    public func makeAsyncSequence() -> any AsyncSendableSequence<Element, Failure> {
        self.base.makeAsyncSequence()
    }
    
    public func makePublisher() -> any Publisher<Element, Failure> {
        self.base.makePublisher()
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

// MARK: Element

extension PassthroughStream: FailableStreamElementObserving, FailableStreamElementMainObserving {

    @discardableResult
    public func observe(
        priority: TaskPriority,
        onElement: @escaping @Sendable (Element) async -> Void,
        onFailure: (@Sendable (Failure) async -> Void)?,
        onFinished: (@Sendable () async -> Void)?
    ) -> Task<Void, Never> {
        self.base.observe(
            priority: priority,
            onElement: onElement,
            onFailure: onFailure,
            onFinished: onFinished
        )
    }
    
    @discardableResult
    public func observeOnMain(
        onElement: @escaping @MainActor (Element) async -> Void,
        onFailure: (@MainActor (Failure) async -> Void)?,
        onFinished: (@MainActor () async -> Void)?
    ) -> Task<Void, Never> {
        self.base.observeOnMain(
            onElement: onElement,
            onFailure: onFailure,
            onFinished: onFinished
        )
    }
}
