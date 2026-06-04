////
////  @PassthroughRelay.swift
////  Async
////
////  Created by Mitch Treece on 6/1/26.
////  Copyright © 2026 Super Epic Studios, LLC.
////
//
//import Foundation
//
///// Wraps a ``PassthroughStream``, and exposes an erased read-only ``AnyRelay``.
/////
///// ```swift
///// @PassthroughRelay<Int> var relay
/////
///// $relay.send(1) // Dropped (no consumers)
/////
///// Task {
/////     for await e in relay {
/////         print("Element: \(e)")
/////     }
///// }
/////
///// $relay.send(2)
///// $relay.send(3)
/////
///// // → "Element: 2"
///// // → "Element: 3"
///// ```
/////
///// - Note: This is similar to ``@Passthrough`` except it exposes a non-failable ``AnyRelay`` instead of an ``AnyStream``.
/////
///// - Tip: You can access the wrapped stream using dollar ( $ ) syntax.
/////
///// - Warning: Property wrappers don't play nice with Swift 6 sendability requirements. The backing storage is always generated
/////   as a mutable `var`, regardless if it's actually mutable or not. Until Swift gains immutable property wrapper support, it's
/////   recommended to use streams directly - _or_ - add `@unchecked Sendable` conformance to the enclosing type _if_ you're certain
/////   about its thread-safety semantics.
/////
///// - SeeAlso: ``@Passthrough``
//@propertyWrapper
//public struct PassthroughRelay<Element: Sendable>: Sendable {
//    
//    public var wrappedValue: AnyRelay<Element> {
//        self.projectedValue.eraseToAnyRelay()
//    }
//    
//    public let projectedValue: PassthroughStream<Element, Never>
//    
//    public init() {
//        self.projectedValue = .init()
//    }
//}
