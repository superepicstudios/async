//
//  EmptyStream.swift
//  Async
//
//  Created by Mitch Treece on 6/1/26.
//  Copyright © 2026 Super Epic Studios, LLC.
//

import Foundation

/// A stream that produces no elements or failures, and finishes immediately.
///
/// ```swift
/// let stream = EmptyStream()
///
/// stream.sequence { seq in
///     for await _ in seq {
///         print("Received") // Never called
///     }
///     print("Finished")
/// }
///
/// // → "Finished"
/// ```
///
/// - SeeAlso: ``JustStream``
public final class EmptyStream: NonFailableStream {
    
    public typealias Element = ()
    
    private let base: PassthroughStream<(), Never>

    public init() {
        self.base = PassthroughStream<(), Never>()
        self.base.send(completion: .finished)
    }
    
    public func makeAsyncSequence() -> any AsyncSendableSequence<(), Never> {
        self.base.makeAsyncSequence()
    }
    
    public func makePublisher() -> any Publisher<(), Never> {
        self.base.makePublisher()
    }
}

// MARK: Erasing

extension EmptyStream: NonFailableStreamErasing {}

// MARK: Sequencing

extension EmptyStream: StreamSequencing, StreamMainSequencing {}

// MARK: Element

extension EmptyStream: NonFailableStreamElementObserving, NonFailableStreamElementMainObserving {

    @discardableResult
    public func observe(
        priority: TaskPriority,
        onElement: @escaping @Sendable (Element) async -> Void,
        onFinished: (@Sendable () async -> Void)?
    ) -> Task<Void, Never> {
        self.base.observe(
            priority: priority,
            onElement: onElement,
            onFinished: onFinished
        )
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
