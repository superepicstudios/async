//
//  @PublishedPipe.swift
//  Async
//
//  Created by Mitch Treece on 5/13/25.
//  Copyright © 2025 Super Epic Studios, LLC.
//

import Combine
import SwiftUI

/// A type that subscribes to a publisher, and re-publishes its values.
///
/// ```swift
/// let subject = CurrentValueSubject<Int, Never>(0)
///
/// @PublishedPipe var value: Int = 0
/// $value.connect(to: subject)
///
/// // value == 0
/// subject.send(1) // value == 1
/// subject.send(2) // value == 2
/// subject.send(3) // value == 3
/// ```
///
/// - Note: This is similar to ``@Published`` but instead of _directly_ wrapping a value,
///   it subscribes to a publisher, and re-publishes its values.
///
/// - Tip: You can access the property wrapper using dollar ( $ ) syntax.
///   The property wrapper exposes a `subscribe(to:)` function that creates
///   a subscription to a publisher's output sequence.
@Observable
@propertyWrapper
public final class PublishedPipe<Output> {
    
    /// The subscribed publisher's latest value.
    public private(set) var wrappedValue: Output
    
    /// The property wrapper as a projected value.
    ///
    /// - Note: This is implemented to maintain consistent usage conventions
    ///   between property wrappers. With this implemented, you can access this
    ///   property wrapper with dollar ( $ ) syntax.
    public var projectedValue: PublishedPipe<Output> { self }
    
    @ObservationIgnored
    private let initialValue: Output
    
    @ObservationIgnored
    private var bag = CancellableBag()
    
    deinit {
        self.bag.removeAll()
    }
    
    /// Initializes a published pipe.
    /// - parameter wrappedValue: The pipe's initial value.
    public init(wrappedValue: Output) {
        
        self.initialValue = wrappedValue
        self.wrappedValue = wrappedValue
        
    }
    
    /// Subscribes to a publisher's output sequence.
    /// - parameter publisher: The publisher to subscribe to.
    public func subscribe<P: Publisher>(to publisher: P) where P.Output == Output, P.Failure == Never {

        self.bag.removeAll()
        
        publisher
            .eraseToAnyPublisher()
            .weakAssign(to: \.wrappedValue, on: self)
            .store(in: &self.bag)
        
    }
    
    /// Unsubscribes from the underlying publisher's output sequence.
    /// - parameter flush: Flag indicating if the pipe should be flushed,
    ///   and its value returned to an initial state.
    public func unsubscribe(flush: Bool = false) {
        
        self.bag.removeAll()
        
        if flush {
            self.wrappedValue = self.initialValue
        }
        
    }
    
}
