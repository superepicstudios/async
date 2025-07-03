//
//  @StreamingValue.swift
//  Async
//
//  Created by Mitch Treece on 6/11/25.
//  Copyright © 2025 Super Epic Studios, LLC.
//

import Foundation

/// A type that wraps an async subject, and streams its elements using an async sequence.
///
/// ```swift
/// @StreamingValue<Int>(0) var valueStream
///
/// Task {
///     for await e in valueStream  {
///         print("Value: \(e)")
///     }
/// }
///
/// $valueStream.send(1)
/// $valueStream.send(2)
/// $valueStream.send(3)
///
/// // → "Value: 0"
/// // → "Value: 1"
/// // → "Value: 2"
/// // → "Value: 3"
/// ```
///
/// - Note: This is similar to ``@Publishing`` but instead of wrapping a
///   [Combine](https://developer.apple.com/documentation/combine) subject,
///   it wraps an async subject & streams elements using an async sequence.
///
/// - Tip: You can access the async subject using dollar ( $ ) syntax.
@propertyWrapper
public final class StreamingValue<Element: Sendable> {
    
    /// The wrapped subject as a type-erased async sequence.
    public var wrappedValue: AnyAsyncSequence<Element> {
        self.projectedValue.eraseToAnySequence()
    }
    
    /// The wrapped async subject.
    public var projectedValue: AsyncSubject<Element> {
        self.subject
    }
    
    private let subject: AsyncCurrentValueSubject<Element>
    
    /// Initializes a streaming value.
    /// - parameter initial: The initial value to give the underlying async subject.
    public init(_ initial: Element) {
        self.subject = .init(initial)
    }
    
}
