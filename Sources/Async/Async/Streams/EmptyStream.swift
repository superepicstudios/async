//
//  EmptyStream.swift
//  Async
//
//  Created by Mitch Treece on 6/1/26.
//  Copyright © 2026 Super Epic Studios, LLC.
//

import Foundation

/// An empty observable stream that produces no elements.
///
/// ```swift
/// let stream = EmptyStream()
///
/// Task {
///     for await _ in stream {
///         print("Received") // Never called
///     }
/// }
/// ```
public final class EmptyStream: StreamProtocol, StreamErasing, Sendable {

    public typealias Element = Void
    public typealias Output = Element
    public typealias Base = AnyRelay<Void>
    public typealias AsyncIterator = Base.AsyncIterator

    private let base: Base

    /// Initializes an empty stream.
    public init() {
        let stream = PassthroughStream<Void, Never>()
        self.base = .init(stream.eraseToAnyRelay())
    }

    // MARK: AsyncSequence

    public func makeAsyncIterator() -> AsyncIterator {
        self.base.makeAsyncIterator()
    }

    // MARK: Publisher

    public func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
        self.base.receive(subscriber: subscriber)
    }
}
