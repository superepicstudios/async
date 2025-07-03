//
//  AsyncJust.swift
//  Async
//
//  Created by Mitch Treece on 6/24/25.
//

import Foundation

/// An async sequence that buffers a single constant element.
public struct AsyncJust<Element: Sendable>: AsyncSequence, AsyncValueProviding, Sendable {
    
    public typealias Subject = AsyncCurrentValueSubject<Element>
    public typealias AsyncIterator = Subject.AsyncIterator
    
    /// The sequence's constant value.
    public var value: Element {
        self.subject.value
    }
    
    private let subject: Subject
    
    /// Inititalizes an async just sequence.
    /// - parameter value: The sequence's constant value.
    public init(_ value: Element) {
        self.subject = .init(value)
    }
    
    public func makeAsyncIterator() -> AsyncIterator {
        self.subject.makeAsyncIterator()
    }
    
}

extension AsyncSequence where Self: Sendable, Self.Element: Sendable {
    
    /// Creates an ``AsyncJust`` sequence.
    /// - parameter value: The sequence's constant value.
    /// - returns: An ``AsyncJust`` sequence.
    public static func just(_ value: Element) -> AsyncJust<Element> {
        AsyncJust(value)
    }
    
}
