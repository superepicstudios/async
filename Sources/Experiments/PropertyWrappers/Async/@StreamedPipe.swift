//
//  @StreamedPipe.swift
//  Async
//
//  Created by Mitch Treece on 6/13/25.
//  Copyright © 2025 Super Epic Studios, LLC.
//

import SwiftUI

/// A type that connects to an async sequence, and re-streams its elements.
///
/// ```swift
/// let subject = AsyncCurrentValueSubject(0)
///
/// @StreamedPipe var value: Int = 0
/// $value.connect(to: subject)
///
/// // value == 0
/// subject.send(1) // value == 1
/// subject.send(2) // value == 2
/// subject.send(3) // value == 3
/// ```
///
/// - Note: This is similar to ``@Streamed`` but instead of streaming elements,
///   it wraps an async sequence, and re-streams its elements.
///
/// - Tip: You can access the property wrapper using dollar ( $ ) syntax.
///   The property wrapper exposes a `connect(to:)` function that streams
///   an async sequence's elements.
@Observable
@propertyWrapper
public final class StreamedPipe<Element: Sendable>: Sendable {
        
    /// The connected async sequence's latest element.
    public var wrappedValue: Element {
        get { return self.managedValue.get() }
        set { self.managedValue.set(newValue) }
    }
    
    /// The property wrapper as a projected value.
    ///
    /// - Note: This is implemented to maintain consistent usage conventions
    ///   between property wrappers. With this implemented, you can access this
    ///   property wrapper with dollar ( $ ) syntax.
    public var projectedValue: StreamedPipe<Element> { self }
    
    private let managedValue: Critical<Element>
    
    /// Initializes a streamed pipe with an initial value.
    /// - parameter wrappedValue: The pipe's initial value.
    public init(wrappedValue: Element) {
        self.managedValue = .init(wrappedValue)
    }
    
}

@available(iOS 18, *)
public extension StreamedPipe {
    
    /// Connects to an async sequence.
    /// - parameter sequence: The async sequence to connect to.
    func connect<S: AsyncSequence>(to sequence: S) where S: Sendable, S.Element == Element, S.Failure == Never {
                
        Task {

            for await element in sequence {
                self.wrappedValue = element
            }

        }

    }
    
}

@available(*, obsoleted: 18)
public extension StreamedPipe {
    
    /// Connects to an async sequence.
    /// - parameter sequence: The async sequence to connect to.
    func connect<S: AsyncSequence>(to sequence: S) where S: Sendable, S.Element == Element {
        
        Task {

            do {
                for try await element in sequence {
                    self.wrappedValue = element
                }
            }
            catch {}

        }

    }
    
}
