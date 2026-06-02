//
//  @Streamed.swift
//  Async
//
//  Created by Mitch Treece on 6/1/26.
//  Copyright © 2026 Super Epic Studios, LLC.
//

import Foundation

/// Wraps an element, and exposes an erased read-only ``AnyStream``.
///
/// ```swift
/// @Streamed var value: Int = 1
///
/// Task {
///     for await e in $value {
///         print("Element: \(e)")
///     }
/// }
///
/// value = 2
/// value = 3
///
/// // → "Element: 1"
/// // → "Element: 2"
/// // → "Element: 3"
/// ```
///
/// - Note: This is similar to ``@Published`` except it wraps a ``ValueStream`` instead of a ``CurrentValueSubject``.
///
/// - Tip: You can access the wrapped stream using dollar ( $ ) syntax.
///
/// - Warning: Property wrappers don't play nice with Swift 6 sendability requirements. The backing storage is always generated
///   as a mutable `var`, regardless if it's actually mutable or not. Until Swift gains immutable property wrapper support, it's
///   recommended to use streams directly - _or_ - add `@unchecked Sendable` conformance to the enclosing type _if_ you're certain
///   about its thread-safety semantics.
///
/// - SeeAlso: ``@Published``
@propertyWrapper
public struct Streamed<Element: Sendable>: Sendable {
    
    public var wrappedValue: Element {
        willSet {
            self.stream.send(newValue)
        }
    }
    
    public var projectedValue: AnyStream<Element, Never> {
        self.stream.eraseToAnyStream()
    }
    
    private let stream: ValueStream<Element, Never>
    
    public init(wrappedValue: Element) {
        self.stream = .init(wrappedValue)
        self.wrappedValue = wrappedValue
    }
}
