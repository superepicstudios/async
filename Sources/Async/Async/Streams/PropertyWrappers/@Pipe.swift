//
//  @Pipe.swift
//  Async
//
//  Created by Mitch Treece on 6/1/26.
//  Copyright © 2026 Super Epic Studios, LLC.
//

@preconcurrency public import Combine
import Foundation
import Synchronization

/// Wraps an element, connects to an external stream, and re-streams its elements.
///
/// ```swift
/// let stream = ValueStream<Int, Never>(1)
///
/// @Pipe var pipe: Int = 0
///
/// $pipe.connect(to: stream) // pipe == 1
/// stream.send(2) // pipe == 2
/// stream.send(3) // pipe == 3
/// ```
///
/// - Note: This is similar to ``@Streamed`` except it connects to an external stream, and re-streams its elements.
///
/// - Warning: Property wrappers don't play nice with Swift 6 sendability requirements. The backing storage is always generated
///   as a mutable `var`, regardless if it's actually mutable or not. Until Swift gains immutable property wrapper support, it's
///   recommended to use streams directly - _or_ - add `@unchecked Sendable` conformance to the enclosing type _if_ you're certain
///   about its thread-safety semantics.
///
/// - SeeAlso: ``@Streamed``
@propertyWrapper
public final class Pipe<Element: Sendable>: Sendable {
    
    public var wrappedValue: Element {
        get { self.value.withLock { $0 }}
        set { self.value.withLock { $0 = newValue }}
    }
    
    public var projectedValue: Pipe<Element> { self }
    
    private let value: Mutex<Element>
    
    public init(wrappedValue: Element) {
        self.value = .init(wrappedValue)
    }
    
    @discardableResult
    public func connect<S: StreamProtocol>(
        to stream: S,
        priority: TaskPriority = .medium
    ) -> Task<Void, Never> where S.Element == Element, S.Failure == Never {
        Task(priority: priority) {
            for await element in stream {
                self.wrappedValue = element
            }
        }
    }
}
