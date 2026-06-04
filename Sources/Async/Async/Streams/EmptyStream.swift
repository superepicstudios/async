//
//  EmptyStream.swift
//  Async
//
//  Created by Mitch Treece on 6/1/26.
//  Copyright © 2026 Super Epic Studios, LLC.
//

import Foundation

/// An empty observable stream that produces no elements.
///
/// ```swift
/// let stream = EmptyStream()
///
/// Task {
///     for await _ in stream {
///         print("Received") // Never called
///     }
/// }
/// ```
public final class EmptyStream: NonFailableStream {
    
    public typealias Element = ()
    
    public var publisher: any Publisher<(), Never> {
        self.base.publisher
    }
    
    private let base: AnyRelay<()>
    
    public init() {
        self.base = PassthroughStream<(), Never>().eraseToAnyRelay()
    }
    
    public func makeAsyncSequence() -> any AsyncSendableSequence<(), Never> {
        self.base.makeAsyncSequence()
    }
}

// MARK: Erasing

extension EmptyStream: NonFailableStreamErasing {}

// MARK: Sequencing

extension EmptyStream: StreamSequencing, StreamMainSequencing {}

// MARK: Observing

extension EmptyStream: NonFailableStreamObserving, NonFailableStreamMainObserving {

    @discardableResult
    public func observe(
        priority: TaskPriority,
        receiveElement: @escaping @Sendable (()) async -> Void
    ) -> Task<Void, Never> {
        self.base.observe(
            priority: priority,
            receiveElement: receiveElement
        )
    }
    
    @discardableResult
    public func observeOnMain(receiveElement: @escaping @MainActor (()) async -> Void) -> Task<Void, Never> {
        self.base.observeOnMain(receiveElement: receiveElement)
    }
}
