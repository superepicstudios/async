//
//  StreamErasing.swift
//  Async
//
//  Created by Mitch Treece on 6/1/26.
//  Copyright © 2026 Super Epic Studios, LLC.
//

import Foundation

// MARK: FailableStreamErasing

/// Protocol describing a failable stream that can perform type-erasure.
public protocol FailableStreamErasing<Element, Failure>: Sendable {
    
    /// The stream's element type.
    associatedtype Element: Sendable

    /// The stream's failure type.
    associatedtype Failure: Error
}

extension FailableStreamErasing where Self: FailableStream<Element, Failure> {
    
    /// Erases the stream into a read-only stream.
    /// - returns: A type-erased stream.
    public func eraseToAnyStream() -> AnyStream<Element, Failure> {
        AnyStream(self)
    }

    /// Erases the stream into a read-only relay.
    /// - returns: A type-erased relay.
    public func eraseToAnyRelay() -> AnyRelay<Element> {
        AnyRelay(self)
    }
}

// MARK: NonFailableStreamErasing

/// Protocol describing a non-failable stream that can perform type-erasure.
public protocol NonFailableStreamErasing<Element>: Sendable {
    
    /// The stream's element type.
    associatedtype Element: Sendable
}

extension NonFailableStreamErasing where Self: NonFailableStream<Element> {
    
    /// Erases the stream into a read-only stream.
    /// - returns: A type-erased stream.
    public func eraseToAnyStream() -> AnyStream<Element, Never> {
        AnyStream(self)
    }

    /// Erases the stream into a read-only relay.
    /// - returns: A type-erased relay.
    public func eraseToAnyRelay() -> AnyRelay<Element> {
        AnyRelay(self)
    }
}
