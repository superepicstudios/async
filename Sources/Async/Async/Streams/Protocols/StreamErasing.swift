//
//  StreamErasing.swift
//  Async
//
//  Created by Mitch Treece on 6/1/26.
//  Copyright © 2026 Super Epic Studios, LLC.
//

import Foundation

/// Protocol describing a failable stream that can be type-erased into a generic read-only wrapper.
///
/// ```swift
/// let base = ValueStream<Int, Never>(0)
/// let stream: AnyStream<Int, Never> = base.eraseToAnyStream()
/// let relay: AnyRelay<Int> = base.eraseToAnyRelay()
/// ```
public protocol FailableStreamErasing<Element, Failure>: Sendable {
    
    /// The stream's element type.
    associatedtype Element: Sendable

    /// The stream's failure type.
    associatedtype Failure: Error
}

extension FailableStreamErasing where Self: FailableStream<Element, Failure> {
    
    /// Erases the stream into a read-only wrapper.
    /// - returns: A type-erased stream.
    public func eraseToAnyStream() -> AnyStream<Element, Failure> {
        AnyStream(failable: self)
    }

    /// Erases the stream into a read-only relay.
    /// - returns: A type-erased relay.
    public func eraseToAnyRelay() -> AnyRelay<Element> {
        AnyRelay(failable: self)
    }
}

// Do I even need "NonFailableStreamErasing" ?
// Wouldn't this *only* apply to `Driver` ?
// And because drivers can only be erased to AnyDriver
// (which it defines itself) I think this will be unused

public protocol NonFailableStreamErasing<Element>: Sendable {
    
    /// The stream's element type.
    associatedtype Element: Sendable
}

extension NonFailableStreamErasing where Self: NonFailableStream<Element> {
    
    /// Erases the stream into a read-only wrapper.
    /// - returns: A type-erased stream.
    public func eraseToAnyStream() -> AnyStream<Element, Never> {
        AnyStream(nonFailable: self)
    }

    /// Erases the stream into a read-only relay.
    /// - returns: A type-erased relay.
    public func eraseToAnyRelay() -> AnyRelay<Element> {
        AnyRelay(nonFailable: self)
    }
}
