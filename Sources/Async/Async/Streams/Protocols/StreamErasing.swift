//
//  StreamErasing.swift
//  Async
//
//  Created by Mitch Treece on 6/1/26.
//  Copyright © 2026 Super Epic Studios, LLC.
//

import Foundation

/// Protocol describing a stream that can be type-erased into a generic read-only wrapper.
///
/// ```swift
/// let base = ValueStream<Int, Never>(0)
/// let stream: AnyStream<Int, Never> = base.eraseToAnyStream()
/// let relay: AnyRelay<Int> = base.eraseToAnyRelay()
/// ```
public protocol StreamErasing<Element, Failure>: Sendable {
    
    /// The stream's element type.
    associatedtype Element: Sendable
    
    /// The stream's failure type.
    associatedtype Failure: Error
}

extension StreamErasing where Self: StreamProtocol {
    
    /// Erases the stream into a read-only wrapper.
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
