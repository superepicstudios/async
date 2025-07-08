//
//  AnyAsyncSequence.swift
//  Async
//
//  Created by Mitch Treece on 5/18/25.
//  Copyright © 2025 Super Epic Studios, LLC.
//

import Foundation

/// A type-erased async sequence.
public struct AnyAsyncSequence<Element: Sendable>: AsyncSequence, Sendable {

    public typealias AsyncIterator = AnyAsyncIterator<Element>

    private let body: @Sendable () -> AsyncIterator

    /// Initializes a type-erased async sequence.
    /// - parameter sequence: The concrete async sequence to erase.
    public init<Sequence: AsyncSequence>(_ sequence: Sequence) where Sequence.Element == Element, Sequence: Sendable {
        
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

extension AsyncSequence where Self: Sendable, Element: Sendable {
    
    /// Erases the receiver into an ``AnyAsyncSequence``.
    /// - returns: The receiver as a type-erased ``AnyAsyncSequence``.
    public func eraseToAnySequence() -> AnyAsyncSequence<Element> {
        AnyAsyncSequence(self)
    }
    
}
