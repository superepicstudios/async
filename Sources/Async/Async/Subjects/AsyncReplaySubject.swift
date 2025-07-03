//
//  AsyncReplaySubject.swift
//  Async
//
//  Created by Mitch Treece on 5/25/25.
//  Copyright © 2025 Super Epic Studios, LLC.
//

import Foundation

/// An async subject that replays a buffered amount of elements to downstream consumers.
///
/// This is intended to be used as a communication type that broadcasts (a.k.a. share, multicast)
/// elements to any amount of consumers. The elements are buffered up to a specified amount, and
/// replayed to new consumers. `send(completion:)` induces a terminal state from which no further
/// elements can be sent.
///
/// ```swift
/// let subject = AsyncReplaySubject<Int>(2)
///
/// subject.send(1)
/// subject.send(2)
/// subject.send(3)
/// subject.send(.finished)
///
/// Task {
///
///     for await e in subject {
///         print("Received: \(e)")
///     }
///
///     print("Finished")
///
/// }
///
/// // → "Received: 2"
/// // → "Received: 3"
/// // → "Finished"
/// ```
///
/// - Tip: Elements **are** shared (multicast), and will be sent to all consumers.
public final class AsyncReplaySubject<Element: Sendable>: AsyncSubject, AsyncValueProviding {
    
    public typealias Element = Element
    public typealias SendingElement = Element
    public typealias Failure = Never
    public typealias AsyncIterator = Iterator
    
    /// The latest value.
    ///
    /// - Warning: This assumes the subject has values in its buffer. If it doesn't,
    ///   accessing this will result in a fatal error.
    public var value: Element {
        get { self.storage.withCriticalRegion { $0.buffer.last! }}
        set { send(newValue) }
    }
    
    let storage: Critical<Storage>
    
    /// Initializes an async replay subject.
    /// - parameter count: The number of elements to replay to new consumers.
    public init(_ count: UInt) {
        
        self.storage = .init(.init(
            bufferSize: count
        ))
        
    }
    
    /// Gets an async iterator over this subject.
    public func makeAsyncIterator() -> Iterator {
        .init(subject: self)
    }
    
    public func send(_ element: Element) {
        
        self.storage.withCriticalRegion { store in
            
            if store.buffer.count > store.bufferSize, !store.buffer.isEmpty {
                store.buffer.removeFirst()
            }
            
            store.buffer.append(element)
            
            for channel in store.channels.values {
                channel.send(element)
            }
            
        }
        
    }
    
    public func send(_ completion: AsyncCompletion) {
        
        self.storage.withCriticalRegion { store in
            
            let channels = Array(store.channels.values)
            
            store.completion = completion
            store.channels.removeAll()
            store.buffer.removeAll()
            store.bufferSize = 0
            
            for channel in channels {
                channel.send(completion)
            }
            
        }
        
    }
    
    // MARK: Private
    
    private func addConsumer() -> (iterator: AsyncBufferedChannel<Element>.Iterator, remove: @Sendable () -> Void) {
        
        let channel = AsyncBufferedChannel<Element>()
        let (elements, completion) = self.storage.withCriticalRegion { ($0.buffer, $0.completion) }
        
        if let completion {
            
            channel.send(completion)
            return (channel.makeAsyncIterator(), {})
            
        }
        
        for element in elements {
            channel.send(element)
        }
        
        let consumerId = self.storage.withCriticalRegion { store -> Int in
            
            store.ids += 1
            store.channels[store.ids] = channel
            return store.ids
            
        }
        
        let remove = { @Sendable [storage] in
            
            storage.withCriticalRegion { store in
                store.channels[consumerId] = nil
            }
            
        }
        
        return (channel.makeAsyncIterator(), remove)
        
    }
    
}

// MARK: Types

extension AsyncReplaySubject {
    
    /// An ``AsyncReplaySubject`` iterator.
    public struct Iterator: AsyncSubjectIterator {

        private let iterator: AsyncBufferedChannel<Element>.Iterator
        private let remove: @Sendable () -> Void

        public var hasBufferedElements: Bool {
            self.iterator.hasBufferedElements
        }
        
        /// Initializes an ``AsyncReplaySubject`` iterator.
        /// - parameter subject: The wrapped async replay subject.
        public init(subject: AsyncReplaySubject) {
            (self.iterator, self.remove) = subject.addConsumer()
        }

        /// Gets the next element in the sequence.
        public mutating func next() async -> Element? {
            
            await withTaskCancellationHandler {
                await self.iterator.next()
            } onCancel: { [remove] in
                remove()
            }
            
        }
        
    }
    
    struct Storage {
        
        var ids: Int = 0
        var channels = [Int: AsyncBufferedChannel<Element>]()
        var bufferSize: UInt
        var buffer = [Element]()
        var completion: AsyncCompletion?
        
        init(bufferSize: UInt) {
            self.bufferSize = bufferSize
        }
        
    }
    
}
