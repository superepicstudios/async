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

public final class ValueStream<Element: Sendable, Failure: Error>: FailableStream {
    
    public var publisher: any Publisher<Element, Failure> {
        self.base.publisher
    }
    
    private let base = ReplayStream<Element, Failure>(buffering: 1)
    
    public init(_ initial: Element) {
        self.base.send(initial)
    }
    
    public func makeAsyncSequence() -> any AsyncSendableSequence<Element, Failure> {
        self.base.makeAsyncSequence()
    }
}

// MARK: Sending

extension ValueStream: StreamElementSending, FailableStreamCompletionSending {
    
    public func send(_ element: Element) {
        self.base.send(element)
    }
    
    public func send(completion: Subscribers.Completion<Failure>) {
        self.base.send(completion: completion)
    }
}

// MARK: Erasing

extension ValueStream: FailableStreamErasing {}

// MARK: Sequencing

extension ValueStream: StreamSequencing, StreamMainSequencing {}

// MARK: Observing

extension ValueStream: FailableStreamObserving, FailableStreamMainObserving {
    
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

// MARK: Element Providing

extension ValueStream: StreamElementProviding {
    
    public var latest: Element {
        self.base.latest
    }
}
