//
//  StreamObserving.swift
//  Async
//
//  Created by Mitch Treece on 6/1/26.
//  Copyright © 2026 Super Epic Studios, LLC.
//

import Foundation

/// Protocol describing a failable stream that can be observed.
///
/// ```swift
/// enum ExampleError: Error {
///     case bad
/// }
///
/// let stream = ValueStream<Int, ExampleError>(1)
///
/// stream.observe { element in
///     print("Observed: \(element)"
/// } receiveError: { error in
///     print("Error: \(error)")
/// }
///
/// stream.send(2)
/// stream.send(3)
/// stream.send(completion: .failure(.bad))
///
/// // → "Observed: 1"
/// // → "Observed: 2"
/// // → "Observed: 3"
/// // → "Error: bad"
/// ```
public protocol FailableStreamObserving<Element, Failure> {
    
    /// The stream's element type.
    associatedtype Element: Sendable
    
    /// The stream's failure type.
    associatedtype Failure: Error
    
    /// Observes the stream.
    /// - parameter priority: An observation task priority.
    /// - parameter receiveElement: A closure called when the stream receives elements.
    /// - parameter receiveError: A closure called when the stream receives an error.
    /// - returns: An observation task.
    @discardableResult
    func observe(
        priority: TaskPriority,
        receiveElement: @escaping @Sendable (Element) async -> Void,
        receiveError: (@Sendable (Failure) async -> Void)?
    ) -> Task<Void, Never>
}

extension FailableStreamObserving {
    
    /// Observes the stream.
    /// - parameter priority: An observation task priority.
    /// - parameter receiveElement: A closure called when the stream receives elements.
    /// - parameter receiveError: A closure called when the stream receives an error.
    /// - returns: An observation task.
    @discardableResult
    public func observe(
        priority: TaskPriority = .medium,
        receiveElement: @escaping @Sendable (Element) async -> Void,
        receiveError: (@Sendable (Failure) async -> Void)? = nil
    ) -> Task<Void, Never> {
        observe(
            priority: priority,
            receiveElement: receiveElement,
            receiveError: receiveError
        )
    }
}

/// Protocol describing a failable stream that can be observed on the main-actor.
///
/// ```swift
/// enum ExampleError: Error {
///     case bad
/// }
///
/// let stream = ValueStream<Int, ExampleError>(1)
///
/// stream.observeOnMain { element in
///     print("Observed: \(element)"
/// } receiveError: { error in
///     print("Error: \(error)")
/// }
///
/// stream.send(1)
/// stream.send(2)
/// stream.send(completion: .failure(.bad))
///
/// // → "Observed: 1"
/// // → "Observed: 2"
/// // → "Observed: 3"
/// // → "Error: bad"
/// ```
public protocol FailableStreamMainObserving<Element, Failure> {
    
    /// The stream's element type.
    associatedtype Element: Sendable
    
    /// The stream's failure type.
    associatedtype Failure: Error
    
    /// Observes the stream on the main-actor.
    /// - parameter receiveElement: A closure called when the stream receives elements.
    /// - parameter receiveError: A closure called when the stream receives an error.
    /// - returns: An observation task.
    @discardableResult
    func observeOnMain(
        receiveElement: @escaping @MainActor (Element) async -> Void,
        receiveError: (@MainActor (Failure) async -> Void)?
    ) -> Task<Void, Never>
}

extension FailableStreamMainObserving {
    
    /// Observes the stream on the main-actor.
    /// - parameter receiveElement: A closure called when the stream receives elements.
    /// - parameter receiveError: A closure called when the stream receives an error.
    /// - returns: An observation task.
    @discardableResult
    func observeOnMain(
        receiveElement: @escaping @MainActor (Element) async -> Void,
        receiveError: (@MainActor (Failure) async -> Void)? = nil
    ) -> Task<Void, Never> {
        observeOnMain(
            receiveElement: receiveElement,
            receiveError: receiveError
        )
    }
}

/// Protocol describing a non-failable stream that can be observed.
///
/// ```swift
/// let stream = ValueStream<Int, Never>(1)
///
/// stream.observe { element in
///     print("Observed: \(element)")
/// }
///
/// stream.send(2)
/// stream.send(3)
///
/// // → "Observed: 1"
/// // → "Observed: 2"
/// // → "Observed: 3"
/// ```
public protocol NonFailableStreamObserving<Element> {
    
    /// The stream's element type.
    associatedtype Element: Sendable
    
    /// Observes the stream.
    /// - parameter priority: An observation task priority.
    /// - parameter receiveElement: A closure called when the stream receives elements.
    /// - returns: An observation task.
    @discardableResult
    func observe(
        priority: TaskPriority,
        receiveElement: @escaping @Sendable (Element) async -> Void
    ) -> Task<Void, Never>
}

extension NonFailableStreamObserving {
    
    /// Observes the stream.
    /// - parameter priority: An observation task priority.
    /// - parameter receiveElement: A closure called when the stream receives elements.
    /// - returns: An observation task.
    @discardableResult
    func observe(
        priority: TaskPriority = .medium,
        receiveElement: @escaping @Sendable (Element) async -> Void
    ) -> Task<Void, Never> {
        observe(
            priority: priority,
            receiveElement: receiveElement
        )
    }
}

/// Protocol describing a non-failable stream that can be observed on the main-actor.
///
/// ```swift
/// let stream = Driver<Int>(1)
///
/// stream.observeOnMain { element in
///     print("Observed: \(element)")
/// }
///
/// stream.send(2)
/// stream.send(3)
///
/// // → "Observed: 1"
/// // → "Observed: 2"
/// // → "Observed: 3"
/// ```
public protocol NonFailableStreamMainObserving<Element> {
    
    /// The stream's element type.
    associatedtype Element: Sendable
    
    /// Observes the stream on the main-actor.
    /// - parameter receiveElement: A closure called when the stream receives elements.
    /// - returns: An observation task.
    @discardableResult
    func observeOnMain(receiveElement: @escaping @MainActor (Element) async -> Void) -> Task<Void, Never>
}
