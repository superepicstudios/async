//
//  JustStream.swift
//  Async
//
//  Created by Mitch Treece on 6/1/26.
//  Copyright © 2026 Super Epic Studios, LLC.
//

import Foundation

/// An observable stream that buffers a single constant element, and broadcasts it to downstream consumers.
///
/// ```swift
/// let stream = JustStream<Int>(0)
///
/// Task {
///     for await e in stream {
///         print("Received: \(e)")
///     }
/// }
///
/// // → "Received: 0"
/// ```
public final class JustStream<Element: Sendable>: NonFailableStream {
    
    public var publisher: any Publisher<Element, Never> {
        self.base.publisher
    }
    
    private let base: ValueStream<Element, Never>
    
    public init(_ element: Element) {
        self.base = .init(element)
    }
    
    public func makeAsyncSequence() -> any AsyncSendableSequence<Element, Never> {
        self.base.makeAsyncSequence()
    }
}

// MARK: Erasing

extension JustStream: NonFailableStreamErasing {}

// MARK: Sequencing

extension JustStream: StreamSequencing, StreamMainSequencing {}

// MARK: Observing

extension JustStream: NonFailableStreamObserving, NonFailableStreamMainObserving {

    @discardableResult
    public func observe(
        priority: TaskPriority,
        receiveElement: @escaping @Sendable (Element) async -> Void
    ) -> Task<Void, Never> {
        self.base.observe(
            priority: priority,
            receiveElement: receiveElement,
            receiveFailure: nil
        )
    }
    
    @discardableResult
    public func observeOnMain(receiveElement: @escaping @MainActor (Element) async -> Void) -> Task<Void, Never> {
        self.base.observeOnMain(
            receiveElement: receiveElement,
            receiveFailure: nil
        )
    }
}
