//
//  @Drive.swift
//  Async
//
//  Created by Mitch Treece on 6/1/26.
//  Copyright © 2026 Super Epic Studios, LLC.
//

import Foundation

/// Wraps a ``Driver``, and exposes an erased read-only ``AnyDriver``.
///
/// ```swift
/// @Drive<Int>(1) var driver
///
/// driver.sequenceOnMain { seq in
///     for await e in seq {
///         print("Received: \(e)")
///     }
///     print("Finished")
/// }
///
/// $driver.send(2)
/// $driver.send(3)
/// $driver.send(completion: .finished)
///
/// // → "Received: 1"
/// // → "Received: 2"
/// // → "Received: 3"
/// // → "Finished"
/// ```
///
/// - Note: This is similar to ``@Stream`` and ``@Relay`` except it exposes a non-failable, main-actor isolated ``AnyDriver``
///   instead of an ``AnyStream`` or ``AnyRelay``.
///
/// - Tip: You can access the wrapped driver using dollar ( $ ) syntax.
///
/// - Warning: Property wrappers don't play nice with Swift 6 sendability requirements. The backing storage is always generated
///   as a mutable `var`, regardless if it's actually mutable or not. Until Swift gains immutable property wrapper support, it's
///   recommended to use streams directly - _or_ - add `@unchecked Sendable` conformance to the enclosing type _if_ you're certain
///   about its thread-safety semantics.
///
/// - SeeAlso: ``@Stream``, ``@Relay``
@propertyWrapper
public struct Drive<Element: Sendable>: Sendable {
    
    public var wrappedValue: AnyDriver<Element> {
        self.projectedValue.eraseToAnyDriver()
    }
    
    public let projectedValue: Driver<Element>
    
    public init(_ initial: Element) {
        self.projectedValue = .init(initial)
    }
}
