//
//  AnyAsyncIterator.swift
//  Async
//
//  Created by Mitch Treece on 5/18/25.
//  Copyright © 2025 Super Epic Studios, LLC.
//

import Foundation

/// A type-erased async iterator.
public struct AnyAsyncIterator<Element>: AsyncIteratorProtocol {
    
    private let body: () async throws -> Element?
    
    /// Initializes a type-erased async iterator.
    /// - parameter iterator: The concrete async iterator to erase.
    public init<Iterator: AsyncIteratorProtocol>(_ iterator: Iterator) where Iterator.Element == Element {
    
        var mutableIterator = iterator
        
        self.body = {
            try await mutableIterator.next()
        }
        
    }

    public mutating func next() async throws -> Element? {
        try await self.body()
    }
    
}

extension AsyncIteratorProtocol {
    
    /// Erases the receiver into an ``AnyAsyncIterator``.
    /// - returns: The receiver as a type-erased ``AnyAsyncIterator``.
    public func eraseToAnyIterator() -> AnyAsyncIterator<Element> {
        AnyAsyncIterator(self)
    }
    
}
