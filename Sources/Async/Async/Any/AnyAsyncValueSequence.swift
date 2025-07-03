//
//  AnyAsyncSubject.swift
//  Async
//
//  Created by Mitch Treece on 6/24/25.
//

import Foundation

/// A type-erased async value sequence.
///
/// This is similar to ``AnyAsyncSequence``, but also provides access to the sequence's latest element.
public struct AnyAsyncValueSequence<Element: Sendable>: AsyncSequence, AsyncValueProviding, Sendable {
    
    public typealias AsyncIterator = AnyAsyncIterator<Element>
    
    /// The sequence's latest element.
    public var value: Element {
        self.provider.value
    }

    private let provider: any AsyncValueProviding<Element>
    private let body: @Sendable () -> AsyncIterator

    /// Initializes a type-erased async value sequence.
    /// - parameter sequence: The concrete async sequence to erase.
    public init<Sequence: AsyncSequence & AsyncValueProviding & Sendable>(
        _ sequence: Sequence
    ) where Sequence.Element == Element {
        
        self.provider = sequence
        
        self.body = {
            
            sequence
                .makeAsyncIterator()
                .eraseToAnyIterator()
            
        }
        
    }

    public func makeAsyncIterator() -> AsyncIterator {
        self.body()
    }
    
}

extension AsyncSequence where Self: AsyncValueProviding, Self: Sendable {
    
    /// Erases the receiver into an ``AnyAsyncValueSequence``.
    /// - returns: The receiver as a type-erased ``AnyAsyncValueSequence``.
    public func eraseToAnyValueSequence() -> AnyAsyncValueSequence<Element> {
        AnyAsyncValueSequence(self)
    }
    
}
