//
//  @PublishingSignal.swift
//  Async
//
//  Created by Mitch on 1/12/25.
//  Copyright © 2025 Super Epic Studios, LLC.
//

import Combine

/// A type that wraps a signal subject, and exposes a type-erased publisher.
///
/// ```swift
/// @PublishingSignal var signal
///
/// signal.sink { _ in
///     print("Signal")
/// }
///
/// $signal.send()
///
/// // → "Signal"
/// ```
///
/// - SeeAlso: ``@Published``, ``@PublishedPipe``, ``@PublishingValue``, ``@PublishingPassthrough``.
///
/// - Tip: You can access the wrapped subject using dollar ( $ ) syntax.
@propertyWrapper
public struct PublishingSignal {
    
    /// The wrapped subject as a type-erased publisher.
    public var wrappedValue: AnyGuaranteePublisher<Void> {
        return self.subject.eraseToAnyPublisher()
    }
    
    /// The wrapped subject.
    public var projectedValue: SignalSubject {
        self.subject
    }
    
    private let subject = SignalSubject()

    /// Initializes a signal subject.
    public init() {}
    
}
