//
//  AsyncNeverWrappedSequence.swift
//  Async
//
//  Created by Mitch Treece on 6/1/26.
//  Copyright © 2026 Super Epic Studios, LLC.
//

import Foundation

/// An async sequence that wraps another failable sequence, and makes it look non-failable.
public struct AsyncNeverWrappedSequence<Element: Sendable, WrappedFailure: Error>: AsyncSequence, @unchecked Sendable {

    public typealias Failure = Never
    public typealias AsyncIterator = AsyncIteratorImpl

    private let wrapped: any AsyncSequence<Element, WrappedFailure>

    public init(_ wrapped: any AsyncSequence<Element, WrappedFailure>) {
        self.wrapped = wrapped
    }

    public func makeAsyncIterator() -> AsyncIterator {
        AsyncIteratorImpl(self.wrapped.makeAsyncIterator())
    }
}

extension AsyncNeverWrappedSequence {

    public struct AsyncIteratorImpl: AsyncIteratorProtocol {
        
        public typealias Failure = Never

        private var getNext: () async -> Element?

        init<I>(_ iterator: I) where I: AsyncIteratorProtocol, I.Element == Element, I.Failure == WrappedFailure {
            var iterator = iterator
            var isFinished = false
            
            self.getNext = {
                guard !isFinished else {
                    return nil
                }
                
                do {
                    guard let element = try await iterator.next() else {
                        isFinished = true
                        return nil
                    }
                    return element
                } catch {
                    isFinished = true
                    return nil
                }
            }
        }

        public mutating func next() async -> Element? {
            await self.getNext()
        }
    }
}
