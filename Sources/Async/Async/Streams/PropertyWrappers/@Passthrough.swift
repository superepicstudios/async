//
//  @Passthrough.swift
//  Async
//
//  Created by Mitch Treece on 6/1/26.
//  Copyright © 2026 Super Epic Studios, LLC.
//

import Foundation

/// Wraps a ``PassthroughStream``, and exposes an erased read-only ``AnyStream``.
///
/// ```swift
/// @Passthrough<Int, Never> var stream
///
/// $stream.send(0) // dropped (no consumers)
///
/// stream.sequence { seq in
///     for try await e in seq {
///         print("Received: \(e)")
///     }
///     print("Finished")
/// }
///
/// $stream.send(1)
/// $stream.send(2)
/// $stream.send(3)
/// $stream.send(completion: .finished)
///
/// // → "Received: 1"
/// // → "Received: 2"
/// // → "Received: 3"
/// // → "Finished"
/// ```
///
/// - Tip: You can access the wrapped stream using dollar ( $ ) syntax.
///
/// - Warning: Property wrappers don't play nice with Swift 6 sendability requirements. The backing storage is always generated
///   as a mutable `var`, regardless if it's actually mutable or not. Until Swift gains immutable property wrapper support, it's
///   recommended to use streams directly - _or_ - add `@unchecked Sendable` conformance to the enclosing type _if_ you're certain
///   about its thread-safety semantics.
///
/// - SeeAlso: ``@PassthroughRelay``
@propertyWrapper
public struct Passthrough<Element: Sendable, Failure: Error>: Sendable {

    public var wrappedValue: AnyStream<Element, Failure> {
        self.projectedValue.eraseToAnyStream()
    }
    
    public let projectedValue: PassthroughStream<Element, Failure>

    public init() {
        self.projectedValue = .init()
    }
}
