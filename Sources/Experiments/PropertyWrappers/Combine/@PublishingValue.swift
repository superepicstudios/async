//
//  @PublishingValue.swift
//  Async
//
//  Created by Mitch Treece on 6/25/25.
//

//import Combine
//
///// A type that wraps a value in a current-value subject, and exposes a type-erased publisher.
/////
///// ```swift
///// @PublishingValue<Int>(0) var value
/////
///// value.sink {
/////     print("Sink: \($0)")
///// }
/////
///// $value.send(1)
///// $value.send(2)
///// $value.send(3)
/////
///// // → "Sink: 0"
///// // → "Sink: 1"
///// // → "Sink: 2"
///// // → "Sink: 3"
///// ```
/////
///// - Note: This is similar to ``@Published`` but instead of _directly_ wrapping a value,
/////   it wraps & exposes the value via a ``Publisher``.
/////
///// - SeeAlso: ``@Published``, ``@PublishedPipe``, ``@PublishedPassthrough``, ``@PublishedSignal``.
/////
///// - Tip: You can access the wrapped subject using dollar ( $ ) syntax.
@propertyWrapper
public struct PublishingValue<Output> {
    
    /// The wrapped subject as a type-erased publisher.
    public var wrappedValue: AnyGuaranteePublisher<Output> {
        return self.projectedValue.eraseToAnyPublisher()
    }
    
    /// The wrapped subject.
    public var projectedValue: GuaranteeCurrentValueSubject<Output> {
        self.subject
    }
    
    private let subject: GuaranteeCurrentValueSubject<Output>
    
    /// Initializes a published value.
    /// - parameter initial: The initial value to give the underlying subject.
    public init(_ initial: Output) {
        self.subject = .init(initial)
    }
    
}

////@propertyWrapper
////public struct PublishedFailableValue<Output, Failure: Error> {
////    
////    /// The wrapped subject as a type-erased publisher.
////    public var wrappedValue: AnyPublisher<Output, Failure> {
////        return self.projectedValue.eraseToAnyPublisher()
////    }
////    
////    /// The wrapped subject.
////    public var projectedValue: CurrentValueSubject<Output, Failure> {
////        self.subject
////    }
////    
////    private let subject: CurrentValueSubject<Output, Failure>
////    
////    /// Initializes a published failable value.
////    /// - parameter initial: The initial value to give the underlying subject.
////    public init(_ initial: Output) {
////        self.subject = .init(initial)
////    }
////    
////}
