////
////  @Stream.swift
////  Async
////
////  Created by Mitch Treece on 6/1/26.
////  Copyright © 2026 Super Epic Studios, LLC.
////
//
//import Foundation
//
///// Wraps a ``ValueStream``, and exposes an erased read-only ``AnyStream``.
/////
///// ```swift
///// @Stream<Int>(1) var stream
/////
///// Task {
/////     for try await e in stream {
/////         print("Element: \(e)")
/////     }
///// }
/////
///// $stream.send(2)
///// $stream.send(3)
/////
///// // → "Element: 1"
///// // → "Element: 2"
///// // → "Element: 3"
///// ```
/////
///// - Tip: You can access the wrapped stream using dollar ( $ ) syntax.
/////
///// - Warning: Property wrappers don't play nice with Swift 6 sendability requirements. The backing storage is always generated
/////   as a mutable `var`, regardless if it's actually mutable or not. Until Swift gains immutable property wrapper support, it's
/////   recommended to use streams directly - _or_ - add `@unchecked Sendable` conformance to the enclosing type _if_ you're certain
/////   about its thread-safety semantics.
/////
///// - SeeAlso: ``@Relay``, ``@Drive``
//@propertyWrapper
//public struct Stream<Element: Sendable>: Sendable {
//    
//    public var wrappedValue: AnyStream<Element, Never> {
//        self.projectedValue.eraseToAnyStream()
//    }
//    
//    public let projectedValue: ValueStream<Element, Never>
//    
//    public init(_ initial: Element) {
//        self.projectedValue = .init(initial)
//    }
//}
