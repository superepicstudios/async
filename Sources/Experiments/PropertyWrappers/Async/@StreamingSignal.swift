//
//  @StreamingSignal.swift
//  Async
//
//  Created by Mitch Treece on 6/13/25.
//  Copyright © 2025 Super Epic Studios, LLC.
//

import Foundation

/// A type that wraps an async signal subject, and streams its events using an async sequence.
///
/// ```swift
/// @StreamingSignal var signalStream
///
/// Task {
///     for await _ in signalStream {
///         print("Signal")
///     }
/// }
///
/// $signalStream.send()
///
/// // → "Signal"
/// ```
///
/// - Tip: You can access the wrapped async subject using dollar ( $ ) syntax.
@propertyWrapper
public final class StreamingSignal {
    
    /// The wrapped async subject as an async sequence.
    public var wrappedValue: AnyAsyncSequence<Void> {
        self.subject.eraseToAnySequence()
    }
    
    /// The wrapped async subject.
    public var projectedValue: AsyncSignalSubject {
        self.subject
    }
 
    private let subject = AsyncSignalSubject()
    
    /// Initializes an async signal subject.
    public init() {}
    
}
