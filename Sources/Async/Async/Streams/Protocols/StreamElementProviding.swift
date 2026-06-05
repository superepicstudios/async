//
//  StreamElementProviding.swift
//  Async
//
//  Created by Mitch Treece on 6/1/26.
//  Copyright © 2026 Super Epic Studios, LLC.
//

import Foundation

// MARK: StreamElementProviding

/// Protocol describing a stream that provides access to its elements.
public protocol StreamElementProviding<Element>: Sendable {
    
    /// The stream's element type.
    associatedtype Element: Sendable
    
    /// The stream's latest element.
    ///
    /// - Warning: Accessing this property assumes the stream is non-empty, and has elements in its buffer.
    ///   If it doesn't, this will throw a fatal error.
    ///
    /// While most concrete stream types only conform to ``StreamElementProviding`` _if_ they can guarantee
    /// safe access to their elements (i.e. ``ValueStream``, ``Driver``), there are exceptions. For example,
    /// ``ReplayStream`` conforms to ``StreamElementProviding`` but if initialized with a buffer of `0` it
    /// can't guarantee safe access because it doesn't hold onto any elements.
    var latest: Element { get }
}

// MARK: StreamElementMainProviding

/// Protocol describing a stream that provides access to its elements on the main-actor.
public protocol StreamElementMainProviding<Element>: Sendable {

    /// The stream's element type.
    associatedtype Element: Sendable

    /// The stream's latest element.
    ///
    /// - Warning: Accessing this property assumes the stream is non-empty, and has elements in its buffer.
    ///   If it doesn't, this will throw a fatal error.
    ///
    /// While most concrete stream types only conform to ``StreamElementMainProviding`` _if_ they can guarantee
    /// safe access to their elements (i.e. ``ValueStream``, ``Driver``), there are exceptions. For example,
    /// ``ReplayStream`` conforms to ``StreamElementProviding`` but if initialized with a buffer of `0` it
    /// can't guarantee safe access because it doesn't hold onto any elements.
    @MainActor
    var latest: Element { get }
}
