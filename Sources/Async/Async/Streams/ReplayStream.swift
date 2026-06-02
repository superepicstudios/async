//
//  ReplayStream.swift
//  Async
//
//  Created by Mitch Treece on 6/1/26.
//  Copyright © 2026 Super Epic Studios, LLC.
//

import AsyncAlgorithms
@preconcurrency public import Combine
@preconcurrency import CombineExt
import Espresso
import Foundation
import Synchronization

/// An observable stream that replays a buffered amount of elements to downstream consumers.
///
/// ```swift
/// let stream = ReplayStream<Int, Never>(2)
///
/// stream.send(1)
/// stream.send(2)
/// stream.send(3)
/// stream.send(completion: .finished)
///
/// Task {
///     for try await e in stream {
///         print("Received: \(e)")
///     }
///     print("Finished")
/// }
///
/// // → "Received: 2"
/// // → "Received: 3"
/// // → "Finished"
/// ```
///
/// - SeeAlso: ``CombineExt/ReplaySubject``
public final class ReplayStream<Element: Sendable, Failure: Error>: StreamProtocol, StreamElementProviding, StreamErasing, @unchecked Sendable {
    
    public typealias Output = Element
    public typealias AsyncIterator = AsyncIteratorImpl<Element, Failure>
    
    /// The stream's latest element.
    ///
    /// - Warning: This assumes the stream has elements in its buffer.
    ///   If it doesn't, accessing this will throw a fatal error.
    public var latest: Element {
        self.latestElement.withLock {
            if let val = $0 { val }
            else if let optional = $0 as? any OptionalRepresentable {
                optional.wrappedValue as! Element
            }
            else {
                fatalError("Attempting to access the latest element of an empty stream. What are you doing developer?")
            }
        }
    }
    
    private let subject: ReplaySubject<Element, Failure>
    private let sequence: any AsyncSequence<Element, any Error> & Sendable
    private let latestElement = Mutex<Element?>(nil)
    
    /// Initializes a replay stream.
    /// - parameter buffer: An amount of elements to buffer.
    public init(_ buffer: UInt) {
        
        let subject = ReplaySubject<Element, Failure>(bufferSize: Int(buffer))
        self.subject = subject
                
        self.sequence = AsyncThrowingStream<Element, any Error> { continuation in
            let subscription = subject.sink { completion in
                switch completion {
                case let .failure(error): continuation.finish(throwing: error)
                case .finished: continuation.finish()
                }
            } receiveValue: { value in
                continuation.yield(value)
            }

            continuation.onTermination = { _ in
                subscription.cancel()
            }
        }
        .share(bufferingPolicy: .unbounded)
    }
    
    // MARK: AsyncSequence
    
    public func makeAsyncIterator() -> AsyncIterator {
        let stream = AsyncThrowingStream<Element, any Error> { continuation in
            let task = Task {
                do {
                    for try await value in self.sequence {
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
        
        return AsyncIteratorImpl(stream.makeAsyncIterator())
    }
    
    // MARK: Publisher
    
    public func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
        self.subject.receive(subscriber: subscriber)
    }
}

// MARK: AsyncIterator

extension ReplayStream {
    
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

// MARK: Sending

extension ReplayStream: StreamElementSending, StreamCompletionSending {
    
    public func send(_ element: Element) {
        self.latestElement.withLock { $0 = element }
        self.subject.send(element)
    }
    
    public func send(completion: Subscribers.Completion<Failure>) {
        self.subject.send(completion: completion)
    }
}

// MARK: Observing

extension ReplayStream: FailableStreamObserving, FailableStreamMainObserving {
    
    @discardableResult
    public func observe(
        priority: TaskPriority,
        receiveElement: @escaping @Sendable (Element) async -> Void,
        receiveError: (@Sendable (Failure) async -> Void)?
    ) -> Task<Void, Never> {
        Task(priority: priority) {
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
