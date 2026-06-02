//
//  @Relay.swift
//  Async
//
//  Created by Mitch Treece on 6/1/26.
//  Copyright © 2026 Super Epic Studios, LLC.
//

import Foundation

/// Wraps a ``ValueStream``, and exposes an erased read-only ``AnyRelay``.
///
/// ```swift
/// @Relay<Int>(1) var relay
///
/// Task {
///     for await e in relay {
///         print("Element: \(e)")
///     }
/// }
///
/// $relay.send(2)
/// $relay.send(3)
///
/// // → "Element: 1"
/// // → "Element: 2"
/// // → "Element: 3"
/// ```
///
/// - Note: This is similar to ``@Stream`` except it exposes a non-failable ``AnyRelay`` instead of an ``AnyStream``.
///
/// - Tip: You can access the wrapped stream using dollar ( $ ) syntax.
///
/// - Warning: Property wrappers don't play nice with Swift 6 sendability requirements. The backing storage is always generated
///   as a mutable `var`, regardless if it's actually mutable or not. Until Swift gains immutable property wrapper support, it's
///   recommended to use streams directly - _or_ - add `@unchecked Sendable` conformance to the enclosing type _if_ you're certain
///   about its thread-safety semantics.
///
/// - SeeAlso: ``@Stream``, ``@Drive``
@propertyWrapper
public struct Relay<Element: Sendable>: Sendable {
    
    public var wrappedValue: AnyRelay<Element> {
        self.projectedValue.eraseToAnyRelay()
    }
    
    public let projectedValue: ValueStream<Element, Never>
    
    public init(_ initial: Element) {
        self.projectedValue = .init(initial)
    }
}
