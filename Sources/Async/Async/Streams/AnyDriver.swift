//
//  AnyDriver.swift
//  Async
//
//  Created by Mitch Treece on 6/1/26.
//  Copyright © 2026 Super Epic Studios, LLC.
//

@preconcurrency public import Combine
import Foundation

/// A type-erased stream of elements that never produces failures, and guarantees delivery on the main-actor.
///
/// ```swift
/// let driver = Driver<Int>(1)
/// let erased: AnyDriver<Int> = driver.eraseToAnyDriver()
///
/// erased.sequenceOnMain { seq in
///     for await e in seq {
///         print("Received: \(e)")
///     }
///     print("Finished")
/// }
///
/// driver.send(2)
/// driver.send(3)
/// driver.send(completion: .finished)
///
/// // → "Received: 1"
/// // → "Received: 2"
/// // → "Received: 3"
/// // → "Finished"
/// ```
///
/// - SeeAlso: ``Driver``, ``AnyStream``, ``AnyRelay``
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

// MARK: Element

extension AnyDriver: StreamElementMainProviding, NonFailableStreamElementMainObserving {

    @MainActor
    public var latest: Element {
        self.wrapped.latest
    }

    public func observeOnMain(receiveElement: @escaping @MainActor (Element) async -> Void) -> Task<Void, Never> {
        self.wrapped.observeOnMain(receiveElement: receiveElement)
    }
}
