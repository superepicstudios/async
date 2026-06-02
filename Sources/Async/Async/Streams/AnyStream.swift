//
//  AnyStream.swift
//  Async
//
//  Created by Mitch Treece on 6/1/26.
//  Copyright © 2026 Super Epic Studios, LLC.
//

@preconcurrency public import Combine
import Foundation

/// A type-erased observable stream of elements.
///
/// ```swift
/// class Model {
///
///     private let _count = ValueStream<Int, Never>(0)
///     var count: AnyStream<Int, Never> {
///         self._count.eraseToAnyStream()
///     }
///
///     func increment() {
///         let newCount = self._count.latest + 1
///         self._count.send(newCount)
///     }
/// }
///
/// class Counter {
///
///     private let model = Model()
///
///     init() {
///
///         self.model.count.observe { c in
///             print("Count: \(c)")
///         } receiveError: { e in
///             print("Error: \(e)")
///         }
///
///         Task {
///             while !Task.isCancelled {
///                 try await Task.sleep(for: .seconds(1))
///                 self.model.increment()
///             }
///         }
///     }
/// }
/// ```
///
/// - SeeAlso: ``AnyRelay``
public struct AnyStream<Element: Sendable, Failure: Error>: StreamProtocol, StreamElementProviding {
    
    public typealias Output = Element
    public typealias Base = AsyncSequence<Element, Failure> & Publisher<Element, Failure> & Sendable
    public typealias AsyncIterator = AsyncIteratorImpl<Element, Failure>
    
    /// The stream's latest element.
    ///
    /// - Warning: This assumes the stream has elements in its buffer.
    ///   If it doesn't, accessing this will throw a fatal error.
    public var latest: Element {
        if let provider = self.wrapped as? any StreamElementProviding,
           let value = provider.latest as? Element
        {
            return value
        }
        else {
            fatalError("Attempting to access the latest element of an unbuffered stream. What are you doing developer?")
        }
    }
    
    private let wrapped: any Base
    
    /// Initializes a type-erased stream.
    /// - parameter wrapped: A stream to wrap.
    public init<T>(_ wrapped: T) where T: Base {
        self.wrapped = wrapped
    }
    
    // MARK: AsyncSequence
    
    public func makeAsyncIterator() -> AsyncIterator {
        let stream = AsyncThrowingStream<Element, any Error> { continuation in
            let task = Task {
                do {
                    for try await value in self.wrapped {
                        continuation.yield(value)
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }

            continuation.onTermination = { _ in
                task.cancel()
            }
        }
        
        return AsyncIterator(stream.makeAsyncIterator())
    }
    
    // MARK: Publisher
    
    public func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Element == S.Input {
        self.wrapped.receive(subscriber: subscriber)
    }
}

// MARK: AsyncIterator

extension AnyStream {
    
    public struct AsyncIteratorImpl<E: Sendable, F: Error>: AsyncIteratorProtocol {
        
        public typealias Element = E
        public typealias Failure = F
        
        private var iterator: AsyncThrowingStream<E, any Error>.Iterator
        
        fileprivate init(_ iterator: AsyncThrowingStream<E, any Error>.Iterator) {
            self.iterator = iterator
        }
        
        public mutating func next() async throws(F) -> E? {
            do {
                return try await self.iterator.next()
            } catch let error as F {
                throw error
            } catch {
                fatalError("Attempting to iterate over an unexpected error. This shouldn't happen.")
            }
        }
    }
}

// MARK: Observing

extension AnyStream: FailableStreamObserving, FailableStreamMainObserving {
    
    @discardableResult
    public func observe(
        priority: TaskPriority,
        receiveElement: @escaping @Sendable (Element) async -> Void,
        receiveError: (@Sendable (Failure) async -> Void)?
    ) -> Task<Void, Never> {
        Task(priority: priority) {
            do {
                for try await element in self.wrapped {
                    await receiveElement(element)
                }
            } catch let error as Failure {
                await receiveError?(error)
            } catch {
                fatalError("Attempting to iterate over an unexpected error. This shouldn't happen.")
            }
        }
    }
    
    @discardableResult
    public func observeOnMain(
        receiveElement: @escaping @MainActor (Element) async -> Void,
        receiveError: (@MainActor (Failure) async -> Void)?
    ) -> Task<Void, Never> {
        Task(priority: .high) {
            do {
                for try await element in self {
                    await receiveElement(element)
                }
            } catch let error as Failure {
                await receiveError?(error)
            } catch {
                fatalError("Attempting to iterate over an unexpected error. This shouldn't happen.")
            }
        }
    }
}
