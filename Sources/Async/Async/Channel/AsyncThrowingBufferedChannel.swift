//
//  AsyncThrowingBufferedChannel.swift
//  Async
//
//  Created by Mitch Treece on 5/17/25.
//  Copyright © 2025 Super Epic Studios, LLC.
//

import DequeModule
import Foundation
import OrderedCollections

/// A channel for sending buffered elements from one task to another.
///
/// This is intended to be used as a communication type between tasks, particularly
/// when one task produces values and another task consumes those values. The values
/// are buffered, awaiting iteration & consumption. `send(_ completion:)` induces a
/// terminal state from which no further elements can be sent.
///
/// ```swift
/// enum ChannelError: Error {
///     case foobar
/// }
///
/// let channel = AsyncThrowingBufferedChannel<Int, ChannelError>()
///
/// Task {
///
///     do {
///         for try await e in channel {
///             print("Element: \(e)")
///         }
///     }
///     catch {
///         print("Error: \(error)")
///     }
///
/// }
///
/// channel.send(1)
/// channel.send(2)
/// channel.send(3)
/// channel.send(.failure(.foobar))
///
/// // → "Element: 1"
/// // → "Element: 2"
/// // → "Element: 3"
/// // → "Error: foobar"
/// ```
///
/// - Tip: Elements are **not** shared (multicast), and will be _spread_ across consumers.
///
/// - Note: This is similar to Apple's `AsyncThrowingChannel`, except that back-pressure
///   is handled with a stack, and sending elements doesn't suspend.
///
/// - Note: This implementation is based on `AsyncThrowingBufferedChannel` from
///   [AsyncExtensions](https://github.com/sideeffect-io/AsyncExtensions).
///
/// - SeeAlso: ``AsyncBufferedChannel``, ``AsyncPassthroughSubject``.
public final class AsyncThrowingBufferedChannel<Element: Sendable, Failure: Error>: AsyncSequence,
                                                                                    AsyncElementBuffering,
                                                                                    AsyncElementSending,
                                                                                    AsyncFailableCompletionSending,
                                                                                    Sendable {
    
    public typealias AsyncIterator = Iterator
    public typealias SendingElement = Element
    public typealias SendingFailure = Failure
    
    public var hasBufferedElements: Bool {
        
        self.storage.withCriticalRegion { store in
            
            return switch store.state {
            case .idle: false
            case .queued(let values) where !values.isEmpty: true
            case .awaiting, .queued: false
            case .finished: true
            }
            
        }
        
    }
    
    private let storage: Critical<Storage>
    
    public init() {
        self.storage = .init(.init())
    }
    
    public func send(_ element: Element) {
        _send(.element(element))
    }
    
    public func send(_ completion: AsyncFailableCompletion<Failure>) {
        _send(.completion(completion))
    }
    
    public func makeAsyncIterator() -> Iterator {
        .init(channel: self)
    }
    
    // MARK: Private
    
    private func _send(_ value: Value) {
        
        let decision = self.storage.withCriticalRegion { store -> SendDecision in
            
            var state = store.state
            var decision: SendDecision
            
            switch (state, value) {
            case (.idle, .element):
                
                // No queued elements, and no awaiting consumers.
                // Queue the new element, and do nothing.
                
                state = .queued([value])
                decision = .nothing
                
            case (.idle, .completion(let completion)):
                
                // No queued elements, and no awaiting consumers.
                // Complete the channel, and do nothing.
                
                state = .finished(completion)
                decision = .nothing

            case (.queued(var values), _):
                
                // Queued elements, and no awaiting consumers.
                // Append the new element, and do nothing.
                
                values.append(value)
                state = .queued(values)
                decision = .nothing

            case (.awaiting(var consumers), .element(let element)):
                
                // Awaiting consumers.
                // Grab the first consumer, and send the new element.
                
                let consumer = consumers.removeFirst()
                state = consumers.isEmpty ? .idle : .awaiting(consumers)
                decision = .resume(consumer, element)
                
            case (.awaiting(let consumers), .completion(.failure(let error))):
                
                // Awaiting consumers.
                // Fail the channel, and notify consumers.
                
                state = .finished(.failure(error))
                decision = .fail(Array(consumers), error)
                
            case (.awaiting(let consumers), .completion(.finished)):
                
                // Awaiting consumers.
                // Complete the channel, and notify consumers.
                
                state = .finished(.finished)
                decision = .finish(Array(consumers))
                
            case (.finished, _):
                
                // Already complete.
                // Do nothing.
                
                decision = .nothing
                
            }
            
            store.state = state
            return decision
            
        }

        switch decision {
        case .nothing: break
        case let .resume(awaiting, element):
            
            awaiting.continuation?.resume(
                returning: element
            )
            
        case .finish(let consumers):
            
            consumers.forEach { consumer in
                consumer.continuation?.resume(
                    returning: nil
                )
            }
            
        case .fail(let consumers, let error):
            
            consumers.forEach { consumer in
                consumer.continuation?.resume(
                    throwing: error
                )
            }
            
        }
        
    }
    
    private func next(onSuspend: (() -> Void)? = nil) async throws -> Element? {
        
        let consumerId = generateConsumerId()
        let cancellation = Critical<Bool>(false)
        
        return try await withTaskCancellationHandler {
            
            try await withUnsafeThrowingContinuation { [storage] (continuation: UnsafeContinuation<Element?, Error>) in
                
                let decision = storage.withCriticalRegion { store -> AwaitingDecision in
        
                    let isCancelled = cancellation.withCriticalRegion { $0 }
                    
                    guard !isCancelled else {
                        return .resume(nil)
                    }
                    
                    var state = store.state
                    var decision: AwaitingDecision

                    switch state {
                    case .idle:
                        
                        state = .awaiting([.init(
                            id: consumerId,
                            continuation: continuation
                        )])
                        
                        decision = .suspend
                        
                    case .queued(var values):
                        
                        let value = values.popFirst()
                        
                        switch value {
                        case .element(let element) where !values.isEmpty:
                            
                            state = .queued(values)
                            decision = .resume(element)
                            
                        case .element(let element):
                            
                            state = .idle
                            decision = .resume(element)
                        
                        case .completion(.finished):
                            
                            state = .finished(.finished)
                            decision = .resume(nil)
                            
                        case .completion(.failure(let error)):
                            
                            state = .finished(.failure(error))
                            decision = .fail(error)
                            
                        default:
                            
                            state = .idle
                            decision = .suspend
                            
                        }
                        
                    case .awaiting(var consumers):
                        
                        consumers.updateOrAppend(.init(
                            id: consumerId,
                            continuation: continuation
                        ))
                        
                        state = .awaiting(consumers)
                        decision = .suspend
                        
                    case .finished(.finished):
                        
                        decision = .resume(nil)
                        
                    case .finished(.failure(let error)):
                        
                        decision = .fail(error)
                        
                    }
                    
                    store.state = state
                    return decision
                    
                }

                switch decision {
                case .resume(let element):
                    
                    continuation.resume(
                        returning: element
                    )
                    
                case .fail(let error):
                    
                    continuation.resume(
                        throwing: error
                    )
                    
                case .suspend:
                    
                    onSuspend?()
                    
                }
                
            }
            
        } onCancel: { [storage] in
            
            let consumer = storage.withCriticalRegion { store -> Consumer? in
                
                cancellation.withCriticalRegion { $0 = true }
                
                var state = store.state
                var consumer: AsyncThrowingBufferedChannel<Element, Failure>.Consumer?
                
                switch state {
                case .awaiting(var consumers):
                    
                    consumer = consumers.remove(.placeholder(id: consumerId))
                    state = consumers.isEmpty ? .idle : .awaiting(consumers)
                    
                default: break
                }
                
                store.state = state
                return consumer
                
            }
            
            consumer?.continuation?.resume(
                returning: nil
            )
            
        }
        
    }
    
    private func generateConsumerId() -> Int {
        
        self.storage.withCriticalRegion { store in
            store.ids += 1
            return store.ids
        }
        
    }

}

// MARK: Types

extension AsyncThrowingBufferedChannel {
    
    /// An ``AsyncThrowingBufferedChannel`` iterator.
    public struct Iterator: AsyncIteratorProtocol, AsyncElementBuffering, Sendable {
        
        private let channel: AsyncThrowingBufferedChannel
        
        public var hasBufferedElements: Bool {
            self.channel.hasBufferedElements
        }
        
        /// Initializes an ``AsyncThrowingBufferedChannel`` iterator.
        /// - parameter channel: The wrapped async throwing buffered channel.
        public init(channel: AsyncThrowingBufferedChannel) {
            self.channel = channel
        }

        public func next() async throws -> Element? {
            try await self.channel.next()
        }
        
    }
    
    private struct Consumer: Hashable {
        
        static func == (lhs: Consumer, rhs: Consumer) -> Bool {
            lhs.id == rhs.id
        }
        
        let id: Int
        let continuation: UnsafeContinuation<Element?, any Error>?

        static func placeholder(id: Int) -> Consumer {
            .init(id: id, continuation: nil)
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(self.id)
        }

    }
    
    private enum Value {
        
        case element(Element)
        case completion(AsyncFailableCompletion<Failure>)
        
    }
    
    private enum State: @unchecked Sendable {
        
        case idle
        case queued(Deque<Value>)
        case awaiting(OrderedSet<Consumer>)
        case finished(AsyncFailableCompletion<Failure>)
    }
    
    private struct Storage {
        
        var ids: Int = 0
        var state: State = .idle
        
    }

    private enum SendDecision {
        
        case nothing
        case resume(Consumer, Element)
        case finish([Consumer])
        case fail([Consumer], Failure)
        
    }

    private enum AwaitingDecision {
        
        case resume(Element?)
        case fail(Failure)
        case suspend
        
    }
    
}
