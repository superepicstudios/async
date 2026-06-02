//
//  JustStream.swift
//  Async
//
//  Created by Mitch Treece on 6/1/26.
//  Copyright © 2026 Super Epic Studios, LLC.
//

import Foundation

/// An observable stream that buffers a single constant element, and broadcasts it to downstream consumers.
public final class JustStream<Element: Sendable>: StreamProtocol, StreamElementProviding, StreamErasing, Sendable {
    
    public typealias Output = Element
    public typealias Base = AnyRelay<Element>
    public typealias AsyncIterator = Base.AsyncIterator
    
    public var latest: Element {
        self.base.latest
    }
    
    private let base: Base
    
    /// Initializes a just stream.
    /// - parameter element: A constant element.
    public init(_ element: Element) {
        let stream = ValueStream<Element, Never>(element)
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
