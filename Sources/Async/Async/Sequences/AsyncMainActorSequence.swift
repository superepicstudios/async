//
//  AsyncMainActorSequence.swift
//  Async
//
//  Created by Mitch Treece on 6/1/26.
//  Copyright © 2026 Super Epic Studios, LLC.
//

import Foundation

/// An async sequence that wraps another sequence, and delivers elements & completions on the main-actor.
public struct AsyncMainActorSequence<Element: Sendable, Failure: Error & Sendable>: AsyncSequence, @unchecked Sendable {

    public typealias AsyncIterator = AsyncIteratorImpl

    private let stream: AsyncThrowingStream<Element, any Error>

    public init(_ wrapped: any AsyncSendableSequence<Element, Failure>) {
        self.stream = AsyncThrowingStream<Element, any Error> { continuation in
            let task = Task {
                do {
                    var iterator = wrapped.makeAsyncIterator()
                    
                    while let element = try await iterator.next() {
                        _ = await MainActor.run {
                            continuation.yield(element)
                        }
                    }

                    await MainActor.run {
                        continuation.finish()
                    }
                } catch {
                    await MainActor.run {
                        continuation.finish(throwing: error)
                    }
                }
            }

            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }

    public func makeAsyncIterator() -> AsyncIterator {
        AsyncIteratorImpl(self.stream.makeAsyncIterator())
    }
}

extension AsyncMainActorSequence {
    
    public struct AsyncIteratorImpl: AsyncIteratorProtocol {

        private var iterator: AsyncThrowingStream<Element, any Error>.Iterator

        init(_ iterator: AsyncThrowingStream<Element, any Error>.Iterator) {
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
