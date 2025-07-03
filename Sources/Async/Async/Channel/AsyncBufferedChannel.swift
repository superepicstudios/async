//
//  AsyncBufferedChannel.swift
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
/// let channel = AsyncBufferedChannel<Int>()
///
/// Task {
///
///     for await e in channel {
///         print("Element: \(e)")
///     }
///
///     print("Finished")
///
/// }
///
/// channel.send(1)
/// channel.send(2)
/// channel.send(3)
/// channel.send(.finished)
///
/// // → "Element: 1"
/// // → "Element: 2"
/// // → "Element: 3"
/// // → "Finished"
/// ```
///
/// - Tip: Elements are **not** shared (multicast), and will be _spread_ across consumers.
///
/// - Note: This is similar to Apple's `AsyncChannel`, except that back-pressure is handled
///   with a stack, and sending elements doesn't suspend.
///
/// - Note: This implementation is based on `AsyncBufferedChannel` from
///   [AsyncExtensions](https://github.com/sideeffect-io/AsyncExtensions).
///
/// - SeeAlso: ``AsyncThrowingBufferedChannel``.
public final class AsyncBufferedChannel<Element: Sendable>: AsyncSequence,
                                                            AsyncElementBuffering,
                                                            AsyncElementSending,
                                                            AsyncCompletionSending,
                                                            Sendable {
    
    public typealias AsyncIterator = Iterator
    public typealias SendingElement = Element

    public var hasBufferedElements: Bool {
        
        self.storage.withCriticalRegion { store in

            switch store.state {
            case .idle: false
            case .queued(let values) where !values.isEmpty: true
            case .awaiting, .queued: false
            case .finished: true
            }
            
        }
        
    }
    
    private let storage: Critical<Storage>
    
    /// Initializes an async buffered channel.
    public init() {
        self.storage = .init(.init())
    }
    
    public func send(_ element: Element) {
        _send(.element(element))
    }
    
    public func send(_ completion: AsyncCompletion) {
        
        switch completion {
        case .finished: _send(.completion)
        @unknown default: fatalError("Unknown completion state. What are you doing developer? 🤔")
        }
        
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
                
            case (.idle, .completion):
                
                // No queued elements, and no awaiting consumers.
                // Complete the channel, and do nothing.
                
                state = .finished
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
                
            case (.awaiting(let consumers), .completion):
                
                // Awaiting consumers.
                // Complete the channel, and notify consumers.
                
                state = .finished
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
        case let .resume(consumer, element):
            
            consumer.continuation?.resume(
                returning: element
            )
            
        case .finish(let consumers):
            
            consumers.forEach { consumer in
                consumer.continuation?.resume(
                    returning: nil
                )
            }
            
        }
        
    }
    
    private func next(onSuspend: (() -> Void)? = nil) async -> Element? {
        
        let consumerId = generateConsumerId()
        let cancellation = Critical<Bool>(false)
        
        return await withTaskCancellationHandler {
            
            await withUnsafeContinuation { [storage] (continuation: UnsafeContinuation<Element?, Never>) in
             
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
                            
                        case .completion:
                            
                            state = .finished
                            decision = .resume(nil)
                            
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
                        
                    case .finished:
                        
                        decision = .resume(nil)
                        
                    }
                    
                    store.state = state
                    return decision
                    
                }
                                
                switch decision {
                case .resume(let element):
                    
                    continuation.resume(
                        returning: element
                    )
                    
                case .suspend:
                    
                    onSuspend?()
                    
                }
                
            }
            
        } onCancel: { [storage] in
            
            let consumer = storage.withCriticalRegion { store -> Consumer? in
                
                cancellation.withCriticalRegion { $0 = true }
                
                var state = store.state
                var consumer: AsyncBufferedChannel<Element>.Consumer?
                
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

extension AsyncBufferedChannel {
    
    /// An ``AsyncBufferedChannel`` iterator.
    public struct Iterator: AsyncIteratorProtocol, AsyncElementBuffering, Sendable {
        
        private let channel: AsyncBufferedChannel
        
        public var hasBufferedElements: Bool {
            self.channel.hasBufferedElements
        }
        
        /// Initializes an ``AsyncBufferedChannel`` iterator.
        /// - parameter channel: The wrapped async buffered channel.
        public init(channel: AsyncBufferedChannel) {
            self.channel = channel
        }
        
        public func next() async -> Element? {
            await self.channel.next()
        }
        
    }
    
    private struct Consumer: Hashable {
        
        static func == (lhs: Consumer, rhs: Consumer) -> Bool {
            lhs.id == rhs.id
        }
        
        let id: Int
        let continuation: UnsafeContinuation<Element?, Never>?

        static func placeholder(id: Int) -> Consumer {
            .init(id: id, continuation: nil)
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(self.id)
        }
        
    }
    
    private enum Value {
        
        case element(Element)
        case completion
        
    }
    
    private enum State: @unchecked Sendable {
        
        case idle
        case queued(Deque<Value>)
        case awaiting(OrderedSet<Consumer>)
        case finished
        
    }
    
    private struct Storage {
        
        var ids: Int = 0
        var state: State = .idle
        
    }
    
    private enum SendDecision {
        
        case nothing
        case resume(Consumer, Element)
        case finish([Consumer])
        
    }
    
    private enum AwaitingDecision {
        
        case resume(Element?)
        case suspend
        
    }
    
}
