//
//  SignalStream.swift
//  Async
//
//  Created by Mitch Treece on 6/1/26.
//  Copyright © 2026 Super Epic Studios, LLC.
//

@preconcurrency public import Combine
import Foundation

/// A stream that sends signals to downstream consumers.
///
/// ```swift
/// let stream = SignalStream<Never>()
///
/// stream.sequence { seq in
///     for try await _ in seq {
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
///
/// - SeeAlso: ``PassthroughStream``, ``SignalSubject``
public final class SignalStream<Failure: Error>: FailableStream {
        
    public typealias Element = ()
    
    private let base = PassthroughStream<(), Failure>()
    
    public init() {}
    
    public func makeAsyncSequence() -> any AsyncSendableSequence<(), Failure> {
        self.base.makeAsyncSequence()
    }
    
    public func makePublisher() -> any Publisher<(), Failure> {
        self.base.makePublisher()
    }
}

// MARK: Sending

extension SignalStream: StreamElementSending, FailableStreamCompletionSending {
    
    public func send(_ element: Void) {
        self.base.send(())
    }
    
    public func send(completion: Subscribers.Completion<Failure>) {
        self.base.send(completion: completion)
    }
}

// MARK: Erasing

extension SignalStream: FailableStreamErasing {}

// MARK: Sequencing

extension SignalStream: StreamSequencing, StreamMainSequencing {}

// MARK: Element

extension SignalStream: FailableStreamElementObserving, FailableStreamElementMainObserving {

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
