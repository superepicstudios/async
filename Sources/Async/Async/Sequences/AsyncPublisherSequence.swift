//
//  AsyncPublisherSequence.swift
//  Async
//
//  Created by Mitch Treece on 6/3/26.
//  Copyright © 2026 Super Epic Studios, LLC.
//

@preconcurrency import Combine
import Foundation

public struct AsyncPublisherSequence<Element: Sendable, Failure: Error>: AsyncSequence, Sendable {
    
    public typealias AsyncIterator = AsyncIteratorImpl
    
    private let stream: AsyncThrowingStream<Element, any Error>
    
    public init(_ publisher: any Publisher<Element, Failure>) {
        self.stream = .init { continuation in
            let subscription = publisher.sink { completion in
                switch completion {
                case let .failure(error):
                    continuation.finish(throwing: error)
                case .finished:
                    continuation.finish()
                }
            } receiveValue: { value in
                continuation.yield(value)
            }
            continuation.onTermination = { _ in
                subscription.cancel()
            }
        }
    }
    
    public func makeAsyncIterator() -> AsyncIteratorImpl {
        return AsyncIteratorImpl(self.stream.makeAsyncIterator())
    }
}

extension AsyncPublisherSequence {
    
    public struct AsyncIteratorImpl: AsyncIteratorProtocol {

        public typealias Iterator = AsyncThrowingStream<Element, any Error>.Iterator
        
        private var iterator: Iterator
        
        init(_ iterator: Iterator) {
            self.iterator = iterator
        }
        
        public mutating func next() async throws(Failure) -> Element? {
            do {
                return try await self.iterator.next()
            } catch let error as Failure {
                throw error
            } catch {
                fatalError("Caught an unexpected error.")
            }
        }
    }
}
