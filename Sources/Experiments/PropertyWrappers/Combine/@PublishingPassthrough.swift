//
//  @PublishingPassthrough.swift
//  Async
//
//  Created by Mitch on 1/12/25.
//  Copyright © 2025 Super Epic Studios, LLC.
//

import Combine

/// A type that wraps a passthrough subject, and exposes a type-erased publisher.
///
/// ```swift
/// @PublisingPassthrough<Int> var passthrough
///
/// $passthrough.send(1) // Dropped (no subscribers)
///
/// passthrough.sink {
///     print("Sink: \($0)")
/// }
///
/// $passthrough.send(1)
/// $passthrough.send(2)
/// $passthrough.send(3)
///
/// // → "Sink: 1"
/// // → "Sink: 2"
/// // → "Sink: 3"
/// ```
///
/// - SeeAlso: ``@Published``, ``@PublishedPipe``, ``@PublishingValue``, ``@PublishingSignal``.
///
/// - Tip: You can access the wrapped subject using dollar ( $ ) syntax.
@propertyWrapper
public struct PublishingPassthrough<Output> {
    
    /// The wrapped subject as a type-erased publisher.
    public var wrappedValue: AnyGuaranteePublisher<Output> {
        return self.projectedValue.eraseToAnyPublisher()
    }
    
    /// The wrapped subject.
    public var projectedValue: GuaranteePassthroughSubject<Output> {
        self.subject
    }
    
    private let subject: GuaranteePassthroughSubject<Output>
    
    /// Initializes a published passthrough.
    public init() {
        self.subject = .init()
    }
    
}

//@propertyWrapper
//public struct PublishingFailablePassthrough<Output, Failure: Error> {
//
//    /// The wrapped subject as a type-erased publisher.
//    public var wrappedValue: AnyPublisher<Output, Failure> {
//        return self.projectedValue.eraseToAnyPublisher()
//    }
//    
//    /// The wrapped subject.
//    public var projectedValue: PassthroughSubject<Output, Failure> {
//        self.subject
//    }
//    
//    private let subject: PassthroughSubject<Output, Failure>
//    
//    /// Initializes a published failable passthrough.
//    public init() {
//        self.subject = .init()
//    }
//    
//}
