//
//  Driver.swift
//  Async
//
//  Created by Mitch Treece on 6/1/26.
//  Copyright © 2026 Super Epic Studios, LLC.
//

@preconcurrency public import Combine
import Foundation

/// A specialized stream that buffers a single element, sends it to downstream consumers,
/// never produces failures, and guarantees delivery on the main-actor.
///
/// This is similar to ``AnyRelay``, except that element delivery is always isolated to the main-actor.
///
/// ```swift
/// let driver = Driver<Int>(1)
///
/// driver.observeOnMain { e in
///     print("Received: \(e)")
/// }
///
/// driver.send(2)
/// driver.send(3)
///
/// // → "Received: 1"
/// // → "Received: 2"
/// // → "Received: 3"
/// ```
///
/// - Warning: While element **delivery** is guaranteed to be main-actor isolated,
///   that same isolation cannot be enforced for ``AsyncSequence`` **observation**.
///   It's recommended to use ``observeOnMain(receiveElement:)`` as this guarantees
///   main-actor isolation for delivery **and** observation.
///
/// - SeeAlso: ``ValueStream``, ``AnyRelay``
public final class Driver<Element: Sendable>: NonFailableStream {
    
    public var publisher: any Publisher<Element, Never> {
        MainQueuePublisher<Element, Never>(self.base.publisher)
    }
    
    private let base: ValueStream<Element, Never>
    
    public init(_ initial: Element) {
        self.base = .init(initial)
    }
    
    public func makeAsyncSequence() -> any AsyncSendableSequence<Element, Never> {
        AsyncMainActorSequence<Element, Never>(self.base.makeAsyncSequence())
    }
}

// MARK: Sending

extension Driver: StreamElementSending, NonFailableStreamCompletionSending {
    
    public func send(_ element: Element) {
        self.base.send(element)
    }
    
    public func send(completion: Subscribers.Completion<Never>) {
        self.base.send(completion: completion)
    }
}

// MARK: Erasing

extension Driver {
    
    func eraseToAnyDriver() -> AnyDriver<Element> {
        AnyDriver(self)
    }
}

// MARK: Sequencing

extension Driver: StreamMainSequencing {}

// MARK: Observing

extension Driver: NonFailableStreamMainObserving {
    
    public func observeOnMain(receiveElement: @escaping @MainActor (Element) async -> Void) -> Task<Void, Never> {
        self.base.observeOnMain(
            receiveElement: receiveElement,
            receiveFailure: nil
        )
    }
}

// MARK: Element Providing

extension Driver: StreamElementProviding {
    
    // @MainActor
    public var latest: Element {
        self.base.latest
    }
}
