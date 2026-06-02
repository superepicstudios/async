//
//  AnyDriver.swift
//  Async
//
//  Created by Mitch Treece on 6/1/26.
//  Copyright © 2026 Super Epic Studios, LLC.
//

@preconcurrency public import Combine
import Foundation

/// A type-erased observable stream of elements that never produces failures, and guarantees delivery on the main-actor.
///
/// ```swift
/// @MainActor
/// final class Model {
///
///     private let _count = Driver<Int>(0)
///     var count: AnyDriver<Int> {
///         self._count.eraseToAnyDriver()
///     }
///
///     func increment() {
///         let newCount = self._count.latest + 1
///         self._count.send(newCount)
///     }
/// }
///
/// @MainActor
/// final class Counter {
///
///     private let model = Model()
///
///     init() {
///
///         self.model.count.observeOnMain { c in
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
/// - SeeAlso: ``Driver``
public struct AnyDriver<Element: Sendable>: StreamProtocol, StreamElementProviding, Sendable {

    public typealias Output = Element
    public typealias Failure = Never
    public typealias Base = Driver<Element>
    public typealias AsyncIterator = Base.AsyncIterator

//    @MainActor
    public var latest: Element {
        self.wrapped.latest
    }

    private let wrapped: Base

    /// Initializes a type-erased driver.
    /// - parameter wrapped: A driver to wrap.
    public init(_ wrapped: Base) {
        self.wrapped = wrapped
    }

    // MARK: AsyncSeqauence

    public func makeAsyncIterator() -> AsyncIterator {
        self.wrapped.makeAsyncIterator()
    }

    // MARK: Publisher

    public func receive<S>(subscriber: S) where S : Subscriber, Never == S.Failure, Element == S.Input {
        self.wrapped.receive(subscriber: subscriber)
    }
}

// MARK: Sending

extension AnyDriver: StreamElementSending {

    public func send(_ element: Element) {
        self.wrapped.send(element)
    }
}

// MARK: Observing

extension AnyDriver: NonFailableStreamMainObserving {

    @discardableResult
    public func observeOnMain(receiveElement: @escaping @MainActor (Element) async -> Void) -> Task<Void, Never> {
        Task(priority: .high) {
            for await element in self.wrapped {
                await receiveElement(element)
            }
        }
    }
}
