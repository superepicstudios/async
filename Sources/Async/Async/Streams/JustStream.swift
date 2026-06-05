//
//  JustStream.swift
//  Async
//
//  Created by Mitch Treece on 6/1/26.
//  Copyright © 2026 Super Epic Studios, LLC.
//

import Foundation

/// A stream that buffers a single constant element, sends it to downstream consumers,
/// never produces failures, and finishes immediately.
///
/// ```swift
/// let stream = JustStream<Int>(1)
///
/// stream.sequence { seq in
///     for await e in seq {
///         print("Received: \(e)")
///     }
///     print("Finished")
/// }
///
/// // → "Received: 1"
/// // → "Finished"
/// ```
///
/// - SeeAlso: ``ValueStream``, ``Combine/Publisher.Just``
public final class JustStream<Element: Sendable>: NonFailableStream {
    
    public var publisher: any Publisher<Element, Never> {
        self.base.publisher
    }
    
    private let base: ValueStream<Element, Never>
    
    public init(_ element: Element) {
        self.base = .init(element)
        self.base.send(completion: .finished)
    }
    
    public func makeAsyncSequence() -> any AsyncSendableSequence<Element, Never> {
        self.base.makeAsyncSequence()
    }
}

// MARK: Erasing

extension JustStream: NonFailableStreamErasing {}

// MARK: Sequencing

extension JustStream: StreamSequencing, StreamMainSequencing {}

// MARK: Element

extension JustStream: StreamElementProviding, NonFailableStreamElementObserving, NonFailableStreamElementMainObserving {

    public var latest: Element {
        self.base.latest
    }

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
