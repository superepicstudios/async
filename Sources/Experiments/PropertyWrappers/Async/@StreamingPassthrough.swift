//
//  @StreamingPassthrough.swift
//  Async
//
//  Created by Mitch Treece on 7/3/25.
//  Copyright © 2025 Super Epic Studios, LLC.
//

import Foundation

/// A type that wraps an async subject, and streams its elements using an async sequence.
///
/// ```swift
/// @StreamingPassthrough<Int>(0) var valueStream
///
/// $valueStream.send(0) // Dropped (no consumers)
///
/// Task {
///
///     for await e in valueStream  {
///         print("Passthrough: \(e)")
///     }
///
/// }
///
/// $valueStream.send(1)
/// $valueStream.send(2)
/// $valueStream.send(3)
///
/// // → "Passthrough: 1"
/// // → "Passthrough: 2"
/// // → "Passthrough: 3"
/// ```
///
/// - Note: This is similar to ``@Publishing`` but instead of wrapping a
///   [Combine](https://developer.apple.com/documentation/combine) subject,
///   it wraps an async subject & streams elements using an async sequence.
///
/// - Tip: You can access the async subject using dollar ( $ ) syntax.
@propertyWrapper
public final class StreamingPassthrough<Element: Sendable> {
    
    /// The wrapped subject as a type-erased async sequence.
    public var wrappedValue: AnyAsyncSequence<Element> {
        self.projectedValue.eraseToAnySequence()
    }
    
    /// The wrapped async subject.
    public var projectedValue: AsyncSubject<Element> {
        self.subject
    }
    
    private let subject: AsyncPassthroughSubject<Element>
    
    /// Initializes a streaming passthrough.
    public init() {
        self.subject = .init()
    }
    
}
