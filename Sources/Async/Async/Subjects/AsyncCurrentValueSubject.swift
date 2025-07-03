//
//  AsyncCurrentValueSubject.swift
//  Async
//
//  Created by Mitch Treece on 5/25/25.
//  Copyright © 2025 Super Epic Studios, LLC.
//

import Foundation

/// An async subject that buffers a single element, and broadcasts it to downstream consumers.
///
/// This is intended to be used as a communication type that broadcasts (a.k.a. share, multicast)
/// elements to any amount of consumers. The latest element is buffered, and will be replayed to
/// new consumers. `send(_ completion:)` induces a terminal state from which no further elements
/// can be sent.
///
/// ```swift
/// let subject = AsyncCurrentValueSubject<Int>(1)
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
/// // → "Received: 1"
/// // → "Received: 2"
/// // → "Received: 3"
/// // → "Finished"
/// ```
///
/// - Tip: Elements **are** shared (multicast), and will be sent to all consumers.
///
/// - SeeAlso: ``CurrentValueSubject``.
public final class AsyncCurrentValueSubject<Element: Sendable>: AsyncSubject, AsyncValueProviding {

    public typealias Element = Element
    public typealias SendingElement = Element
    public typealias Failure = Never
    public typealias AsyncIterator = AsyncReplaySubject<Element>.Iterator
    
    public var value: Element {
        get { self.subject.value }
        set { send(newValue) }
    }

    private let subject: AsyncReplaySubject<Element>

    /// Initializes an async current-value subject.
    /// - parameter initial: The subject's initial value.
    public init(_ initial: Element) {

        self.subject = .init(1)
        self.subject.send(initial)

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
