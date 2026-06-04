////
////  @SignalRelay.swift
////  Async
////
////  Created by Mitch Treece on 6/1/26.
////  Copyright © 2026 Super Epic Studios, LLC.
////
//
//import Foundation
//
///// Wraps a ``SignalStream``, and exposes an erased read-only ``AnyRelay``.
/////
///// ```swift
///// @SignalRelay var relay
/////
///// Task {
/////     for await _ in relay {
/////         print("Signal")
/////     }
///// }
/////
///// $relay.send()
/////
///// // → "Signal"
///// ```
/////
///// - Note: This is similar to ``@Signal`` except it exposes a non-failable ``AnyRelay`` instead of an ``AnyStream``.
/////
///// - Tip: You can access the wrapped stream using dollar ( $ ) syntax.
/////
///// - Warning: Property wrappers don't play nice with Swift 6 sendability requirements. The backing storage is always generated
/////   as a mutable `var`, regardless if it's actually mutable or not. Until Swift gains immutable property wrapper support, it's
/////   recommended to use streams directly - _or_ - add `@unchecked Sendable` conformance to the enclosing type _if_ you're certain
/////   about its thread-safety semantics.
/////
///// - SeeAlso: ``@Signal``
//@propertyWrapper
//public struct SignalRelay: Sendable {
//    
//    public var wrappedValue: AnyRelay<Void> {
//        self.projectedValue.eraseToAnyRelay()
//    }
//    
//    public let projectedValue: SignalStream<Never>
//    
//    public init() {
//        self.projectedValue = .init()
//    }
//}
