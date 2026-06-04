////
////  @Signal.swift
////  Async
////
////  Created by Mitch Treece on 6/1/26.
////  Copyright © 2026 Super Epic Studios, LLC.
////
//
//import Foundation
//
///// Wraps a ``SignalStream``, and exposes an erased read-only ``AnyStream``.
/////
///// ```swift
///// @Signal var stream
/////
///// Task {
/////     for try await _ in stream {
/////         print("Signal")
/////     }
///// }
/////
///// $stream.send()
/////
///// // → "Signal"
///// ```
/////
///// - Tip: You can access the wrapped stream using dollar ( $ ) syntax.
/////
///// - Warning: Property wrappers don't play nice with Swift 6 sendability requirements. The backing storage is always generated
/////   as a mutable `var`, regardless if it's actually mutable or not. Until Swift gains immutable property wrapper support, it's
/////   recommended to use streams directly - _or_ - add `@unchecked Sendable` conformance to the enclosing type _if_ you're certain
/////   about its thread-safety semantics.
/////
///// - SeeAlso: ``@SignalRelay``
//@propertyWrapper
//public struct Signal: Sendable {
//    
//    public var wrappedValue: AnyStream<Void, Never> {
//        self.projectedValue.eraseToAnyStream()
//    }
//    
//    public let projectedValue: SignalStream<Never>
//    
//    public init() {
//        self.projectedValue = .init()
//    }
//}
