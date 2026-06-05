//
//  AsyncFailureWrappedSequence.swift
//  Async
//
//  Created by Mitch Treece on 6/1/26.
//  Copyright © 2026 Super Epic Studios, LLC.
//

import Foundation

/// An async sequence that wraps another non-failable sequence, and makes it look failable.
public struct AsyncFailureWrappedSequence<Element: Sendable, Failure: Error>: AsyncSequence, @unchecked Sendable {

    public typealias AsyncIterator = AsyncIteratorImpl
    
    private let wrapped: any AsyncSequence<Element, Never>

    public init(_ wrapped: any AsyncSequence<Element, Never>) {
        self.wrapped = wrapped
    }

    public func makeAsyncIterator() -> AsyncIterator {
        AsyncIteratorImpl(self.wrapped.makeAsyncIterator())
    }
}

extension AsyncFailureWrappedSequence {

    public struct AsyncIteratorImpl: AsyncIteratorProtocol {
        
        private var getNext: () async -> Element?

        init<I>(_ iterator: I) where I: AsyncIteratorProtocol, I.Element == Element, I.Failure == Never {
            var iterator = iterator
            // Safe because: I.Failure == Never, and is guaranteed to never throw
            self.getNext = { try! await iterator.next() }
        }
        
        public mutating func next() async throws(Failure) -> Element? {
            await self.getNext()
        }
    }
}
