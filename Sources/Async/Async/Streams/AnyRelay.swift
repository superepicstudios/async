//
//  AnyRelay.swift
//  Async
//
//  Created by Mitch Treece on 6/1/26.
//  Copyright © 2026 Super Epic Studios, LLC.
//

@preconcurrency public import Combine
import Foundation

/// A type-erased observable stream of elements that never produces failures.
///
/// ```swift
/// class Model {
///
///     private let _count = ValueStream<Int, Never>(0)
///     var count: AnyRelay<Int> {
///         self._count.eraseToAnyRelay()
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
/// - SeeAlso: ``AnyStream``
public struct AnyRelay<Element: Sendable>: StreamProtocol, StreamElementProviding {
    
    public typealias Output = Element
    public typealias Failure = Never
    public typealias AsyncIterator = AsyncStream<Element>.AsyncIterator
    
    /// The stream's latest element.
    ///
    /// - Warning: This assumes the stream has elements in its buffer.
    ///   If it doesn't, accessing this will throw a fatal error.
    public var latest: Element {
        if let provider = self.elementProvider,
           let value = provider.latest as? Element
        {
            return value
        }
        else {
            fatalError("Attempting to access the latest element of an unbuffered stream. What are you doing developer?")
        }
    }
    
    private let stream: AsyncStream<Element>
    private let receiver: @Sendable (AnySubscriber<Element, Never>) -> Void
    private let elementProvider: (any StreamElementProviding)?
    
    /// Initializes a type-erased relay.
    /// - parameter wrapped: A stream to wrap.
    public init<S>(_ wrapped: S) where S: AsyncSequence & Publisher & Sendable, S.Element == Element, S.Output == Element {
        self.stream = AsyncStream<Element> { continuation in
            let task = Task {
                do {
                    for try await element in wrapped {
                        continuation.yield(element)
                    }
                    continuation.finish()
                } catch {
                    // Swallow errors
                }
            }
            continuation.onTermination = { _ in
                task.cancel()
            }
        }
        
        self.receiver = { subscriber in
            wrapped
                .catch { _ in Empty<Element, Never>() }
                .receive(subscriber: subscriber)
        }
        
        self.elementProvider = wrapped as? any StreamElementProviding
    }
    
    // MARK: AsyncSequence
    
    public func makeAsyncIterator() -> AsyncStream<Element>.AsyncIterator {
        self.stream.makeAsyncIterator()
    }
    
    // MARK: Publisher
    
    public func receive<S>(subscriber: S) where S : Subscriber, Never == S.Failure, Element == S.Input {
        self.receiver(AnySubscriber(subscriber))
    }
}

// MARK: Observing

extension AnyRelay: NonFailableStreamObserving, NonFailableStreamMainObserving {
    
    @discardableResult
    public func observe(
        priority: TaskPriority,
        receiveElement: @escaping @Sendable (Element) async -> Void,
    ) -> Task<Void, Never> {
        Task(priority: priority) {
            for await element in self.stream {
                await receiveElement(element)
            }
        }
    }
    
    @discardableResult
    public func observeOnMain(receiveElement: @escaping @MainActor (Element) async -> Void) -> Task<Void, Never> {
        Task(priority: .high) {
            for await element in self.stream {
                await receiveElement(element)
            }
        }
    }
}
