//
//  AsyncPassthroughSubject.swift
//  Async
//
//  Created by Mitch Treece on 5/25/25.
//  Copyright © 2025 Super Epic Studios, LLC.
//

import Foundation

/// An async subject that doesn't buffer elements, and only broadcasts new ones to downstream consumers.
///
/// This is intended to be used as a communication type that broadcasts (a.k.a. share, multicast)
/// elements to any amount of consumers. The elements are not buffered, and will be dropped if there
/// are no consumers. `send(_ completion:)` induces a terminal state from which no further elements
/// can be sent.
///
/// ```swift
/// let subject = AsyncPassthroughSubject<Int>()
///
/// subject.send(1) // Dropped (no consumers)
///
/// Task {
///
///     for await e in subject {
///         print("Received: \(e)")
///     }
///
///     print("Finished")
///
/// }
///
/// subject.send(2)
/// subject.send(3)
/// subject.send(.finished)
///
/// // → "Received: 2"
/// // → "Received: 3"
/// // → "Finished"
/// ```
///
/// - Tip: Elements **are** shared (multicast), and will be sent to all consumers.
///
/// - SeeAlso: ``PassthroughSubject``.
public final class AsyncPassthroughSubject<Element: Sendable>: AsyncSubject {

    public typealias Element = Element
    public typealias SendingElement = Element
    public typealias Failure = Never
    public typealias AsyncIterator = AsyncReplaySubject<Element>.Iterator

    private let subject: AsyncReplaySubject<Element>

    /// Initializes an async passthrough subject.
    public init() {
        self.subject = .init(0)
    }
    
    /// Gets an async iterator over this subject.
    public func makeAsyncIterator() -> AsyncIterator {
        .init(subject: self.subject)
    }

    public func send(_ element: Element) {
        self.subject.send(element)
    }

    public func send(_ completion: AsyncCompletion) {
        self.subject.send(completion)
    }

}
