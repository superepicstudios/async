//
//  Publisher+Combine.swift
//  Async
//
//  Created by Mitch Treece on 4/13/22.
//  Copyright © 2025 Super Epic Studios, LLC.
//

@preconcurrency import Combine
import Dispatch
import Foundation
import SECommon

// MARK: Async

extension Publisher where Failure == Never {
        
    /// A publisher that exposes its elements as an async sequence.
    public func asAsync() -> AsyncPublisher<Self> {
        self.values
    }
    
}

extension Publisher {
        
    /// A publisher that exposes its elements as a throwing async sequence.
    public func asAsyncThrowing() -> AsyncThrowingPublisher<Self> {
        self.values
    }
    
}

// MARK: Tap

extension Publisher {

    /// Gets the publisher's latest value.
    /// - returns: The publisher's latest value.
    ///
    /// - Note: This assumes the publisher has values in its output sequence.
    ///   If it doesn't, calling this will throw an exception. For example, when
    ///   using a ``PassthroughSubject`` and erasing to ``AnyPublisher``, calling
    ///   this will throw a ``PublisherError.emptyStream`` excpetion as ``PassthroughSubject``
    ///   does not buffer its values.
    ///
    /// - Tip: Consider using ``tap(or:)`` when unsure about the publisher's value semantics.
    public func tap() throws -> Output {
        
        var value: Output?
        var error: Error?
        var bag = CancellableBag()

        sink { completion in

            switch completion {
            case .failure(let e): error = e
            case .finished: break
            }

        } receiveValue: { v in
            value = v
        }
        .store(in: &bag)

        if let value {
            return value
        }
        else if let error {
            throw error
        }
        else {
            throw PublisherError.emptyOutput
        }
        
    }
    
    /// Gets the publisher's latest, _or_ a default value if accessing the latest
    /// value would result in an error.
    /// - parameter default: The default value to use if an error is returned.
    /// - returns: The publisher's latest, _or_ a default value.
    public func tap(or default: Output) -> Output {
        (try? tap()) ?? `default`
    }
    
    /// Gets the publisher's latest value.
    ///
    /// - Note: This assumes the publisher has values in its output sequence.
    ///   If it doesn't, calling this will throw an exception. For example, when
    ///   using a ``PassthroughSubject`` and erasing to ``AnyPublisher``, calling
    ///   this will throw a ``PublisherError.emptyStream`` excpetion as ``PassthroughSubject``
    ///   does not buffer its values.
    public func unsafeTap() -> Output {
        try! tap()
    }
    
}

extension Publisher where Output: DefaultValueProviding {
    
    /// Gets the publisher's latest, _or_ default value if accessing the latest
    /// value would result in an error.
    func tapOrDefault() -> Output {
        tap(or: Output.defaultValue)
    }
    
}

// MARK: Scheduling

extension Publisher {

    /// Specifies the main-queue as the receiving scheduler for published elements.
    /// - parameter options: Optional schedular options to use.
    /// - returns: A publisher that delivers elements using the main-queue.
    public func receiveOnMainQueue(
        options: DispatchQueue.SchedulerOptions? = nil
    ) -> Publishers.ReceiveOn<Self, DispatchQueue> {

        receive(
            on: .main,
            options: options
        )

    }
    
    /// Specifies the main run-loop as the receiving scheduler for published elements.
    /// - parameter options: Optional schedular options to use.
    /// - returns: A publisher that delivers elements using the main run-loop.
    public func receiveOnMainLoop(
        options: RunLoop.SchedulerOptions? = nil
    ) -> Publishers.ReceiveOn<Self, RunLoop> {
        
        receive(
            on: .main,
            options: options
        )

    }
    
}

// MARK: Weak

extension Publisher {
    
    /// Attaches a weak subscriber to the publisher.
    /// - parameter object: The object to weakly capture.
    /// - parameter onValue: The closure to call when a value is received.
    /// - returns: A cancellable instance, which you use when you end assignment
    ///   of the received value. Deallocation of the result will tear down the
    ///   subscription stream.
    public func weakSink<T: AnyObject>(
        capturing object: T,
        onValue: @escaping (T?, Output) -> Void
    ) -> AnyCancellable {
        
        sink(
            receiveCompletion: { _ in },
            receiveValue: { [weak object] in onValue(object, $0) }
        )
        
    }
    
    /// Weakily assigns each element from the publisher to a property on an object.
    /// - parameter keyPath: A key path that indicates the property to assign.
    /// - parameter object: The object that contains the property.
    /// - returns: A cancellable instance, which you use when you end assignment
    ///   of the received value. Deallocation of the result will tear down the
    ///   subscription stream.
    public func weakAssign<T: AnyObject>(
        to keyPath: ReferenceWritableKeyPath<T, Output>,
        on object: T
    ) -> AnyCancellable {
        
        weakSink(capturing: object) { weakObject, value in
            weakObject?[keyPath: keyPath] = value
        }
        
    }
    
}

// MARK: Guard

extension Publisher where Output: OptionalRepresentable {
    
    public func `guard`() -> AnyPublisher<Output.Wrapped, Failure> {
        
        filter { $0.wrappedValue != nil }
            .map { $0.wrappedValue! }
            .eraseToAnyPublisher()
        
    }
    
}

// MARK: Equals

extension Publisher where Output: Equatable {
    
    /// Filters non-equivalent outputs out of the publisher sequence.
    public func equals(_ value: Output) -> AnyPublisher<Output, Failure> {
        
        filter { $0 == value }
            .eraseToAnyPublisher()
        
    }
    
    /// Filters equivalent outputs out of the publisher sequence.
    public func notEquals(_ value: Output) -> AnyPublisher<Output, Failure> {
        
        filter { $0 != value }
            .eraseToAnyPublisher()
        
    }
    
}

// MARK: Bool

extension Publisher where Output == Bool {
    
    /// Filters `false` outputs out of a publisher sequence.
    public func isTrue() -> AnyPublisher<Output, Failure> {
        equals(true)
    }
    
    /// Filters `true` outputs out of a publisher sequence.
    public func isFalse() -> AnyPublisher<Output, Failure> {
        equals(false)
    }

}
