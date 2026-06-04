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
public struct AnyDriver<Element: Sendable>: NonFailableStream {
    
    public var publisher: any Publisher<Element, Never> {
        self.wrapped.publisher
    }
    
    private let wrapped: Driver<Element>
    
    public init(_ wrapped: Driver<Element>) {
        self.wrapped = wrapped
    }
    
    public func makeAsyncSequence() -> any AsyncSendableSequence<Element, Never> {
        self.wrapped.makeAsyncSequence()
    }
}

// MARK: Sequencing

extension AnyDriver: StreamMainSequencing {}

// MARK: Observing

extension AnyDriver: NonFailableStreamMainObserving {
    
    public func observeOnMain(receiveElement: @escaping @MainActor (Element) async -> Void) -> Task<Void, Never> {
        self.wrapped.observeOnMain(receiveElement: receiveElement)
    }
}

// MARK: Element Providing

extension AnyDriver: StreamElementProviding {
    
    // @MainActor
    public var latest: Element {
        self.wrapped.latest
    }
}
