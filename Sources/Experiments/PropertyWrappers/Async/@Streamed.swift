//
//  @Streamed.swift
//  Async
//
//  Created by Mitch Treece on 5/18/25.
//  Copyright © 2025 Super Epic Studios, LLC.
//

/// A type that streams elements using an async sequence.
///
/// ```swift
/// @Streamed var value: Int = 0
///
/// Task {
///     for await e in $value {
///         print("Element: \(element)")
///     }
/// }
///
/// value = 1
/// value = 2
/// value = 3
///
/// // → "Element: 0"
/// // → "Element: 1"
/// // → "Element: 2"
/// // → "Element: 3"
/// ```
///
/// - Note: This is similar to ``@Published`` but instead of publishing values,
///   it streams values using an async sequence.
///
/// - Tip: You can access the async sequence using dollar ( $ ) syntax.
@propertyWrapper
public struct Streamed<Element: Sendable>: Sendable {
    
    private let subject: AsyncCurrentValueSubject<Element>
    
    /// The wrapped async sequence's latest element.
    public var wrappedValue: Element {
        willSet {
            self.subject.send(newValue)
        }
    }
    
    /// The wrapped async sequence.
    public var projectedValue: AnyAsyncValueSequence<Element> {
        self.subject.eraseToAnyValueSequence()
    }
    
    /// Initializes a streamed value with an initial value.
    /// - parameter wrappedValue: The initial value to give the underlying async sequence.
    public init(wrappedValue: Element) {
        
        self.subject = .init(wrappedValue)
        self.wrappedValue = wrappedValue
        
    }
    
}
