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
    
    public var publisher: any Publisher<(), Failure> {
        self.base.publisher
    }
    
    public init() {}
    
    public func makeAsyncSequence() -> any AsyncSendableSequence<(), Failure> {
        self.base.makeAsyncSequence()
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
        receiveElement: @escaping @Sendable (()) async -> Void,
        receiveFailure: (@Sendable (Failure) async -> Void)?
    ) -> Task<(), Never> {
        self.base.observe(
            priority: priority,
            receiveElement: receiveElement,
            receiveFailure: receiveFailure
        )
    }
    
    @discardableResult
    public func observeOnMain(
        receiveElement: @escaping @MainActor (()) async -> Void,
        receiveFailure: (@MainActor (Failure) async -> Void)?
    ) -> Task<Void, Never> {
        self.base.observeOnMain(
            receiveElement: receiveElement,
            receiveFailure: receiveFailure
        )
    }
}
