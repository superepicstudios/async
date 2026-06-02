//
//  StreamElementProviding.swift
//  Async
//
//  Created by Mitch Treece on 6/1/26.
//  Copyright © 2026 Super Epic Studios, LLC.
//

import Foundation

/// Protocol describing a stream that provides access to its elements.
///
/// ```swift
/// let stream = ValueStream<String, Never>("foo")
/// stream.send("bar")
/// print(stream.latest) → "bar"
/// ```
public protocol StreamElementProviding<Element>: Sendable {
    
    /// The stream's element type.
    associatedtype Element: Sendable
    
    /// The stream's latest element.
    ///
    /// - Warning: Accessing this property assumes the stream has elements in its buffer.
    ///   If it doesn't, this will throw a fatal error.
    ///
    ///   While most concrete stream types only conform to ``StreamElementProviding``
    ///   **if** they can guarantee safe access to their elements (i.e. ``ValueStream``,
    ///   ``Driver``, etc), this is not always the case. For example, ``ReplayStream``
    ///   conforms to ``StreamElementProviding``, but if initialized with a buffer of `0`
    ///   it can't guarantee safe access, because it doesn't buffer any elements.
    var latest: Element { get }
}
