//
//  StreamElementObserving.swift
//  Async
//
//  Created by Mitch Treece on 6/1/26.
//  Copyright © 2026 Super Epic Studios, LLC.
//

import Foundation

// MARK: FailableStreamElementObserving

/// Protocol describing a failable stream that can observe its elements.
public protocol FailableStreamElementObserving<Element, Failure> {

    /// The stream's element type.
    associatedtype Element: Sendable
    
    /// The stream's failure type.
    associatedtype Failure: Error
    
    /// Observes the stream's elements.
    /// - parameter priority: An observation task priority.
    /// - parameter receiveElement: A closure called when the stream receives an element.
    /// - parameter receiveFailure: A closure called when the stream receives a failure.
    /// - returns: An observation task.
    @discardableResult
    func observe(
        priority: TaskPriority,
        receiveElement: @escaping @Sendable (Element) async -> Void,
        receiveFailure: (@Sendable (Failure) async -> Void)?
    ) -> Task<Void, Never>
}

extension FailableStreamElementObserving {

    /// Observes the stream's elements.
    /// - parameter priority: An observation task priority.
    /// - parameter receiveElement: A closure called when the stream receives an element.
    /// - parameter receiveFailure: A closure called when the stream receives a failure.
    /// - returns: An observation task.
    @discardableResult
    public func observe(
        priority: TaskPriority = .medium,
        receiveElement: @escaping @Sendable (Element) async -> Void,
        receiveFailure: (@Sendable (Failure) async -> Void)? = nil
    ) -> Task<Void, Never> {
        observe(
            priority: priority,
            receiveElement: receiveElement,
            receiveFailure: receiveFailure
        )
    }
}

// MARK: FailableStreamElementMainObserving

/// Protocol describing a failable stream that can observe its elements on the main-actor.
public protocol FailableStreamElementMainObserving<Element, Failure> {

    /// The stream's element type.
    associatedtype Element: Sendable
    
    /// The stream's failure type.
    associatedtype Failure: Error
    
    /// Observes the stream's elements on the main-actor.
    /// - parameter receiveElement: A closure called when the stream receives an element.
    /// - parameter receiveFailure: A closure called when the stream receives a failure.
    /// - returns: An observation task.
    @discardableResult
    func observeOnMain(
        receiveElement: @escaping @MainActor (Element) async -> Void,
        receiveFailure: (@MainActor (Failure) async -> Void)?
    ) -> Task<Void, Never>
}

extension FailableStreamElementMainObserving {

    /// Observes the stream's elements on the main-actor.
    /// - parameter receiveElement: A closure called when the stream receives an element.
    /// - parameter receiveFailure: A closure called when the stream receives a failure.
    /// - returns: An observation task.
    @discardableResult
    func observeOnMain(
        receiveElement: @escaping @MainActor (Element) async -> Void,
        receiveFailure: (@MainActor (Failure) async -> Void)? = nil
    ) -> Task<Void, Never> {
        observeOnMain(
            receiveElement: receiveElement,
            receiveFailure: receiveFailure
        )
    }
}

// MARK: NonFailableStreamElementObserving

/// Protocol describing a non-failable stream that can observe its elements.
public protocol NonFailableStreamElementObserving<Element> {

    /// The stream's element type.
    associatedtype Element: Sendable
    
    /// Observes the stream's elements.
    /// - parameter priority: An observation task priority.
    /// - parameter receiveElement: A closure called when the stream receives an element.
    /// - returns: An observation task.
    @discardableResult
    func observe(
        priority: TaskPriority,
        receiveElement: @escaping @Sendable (Element) async -> Void
    ) -> Task<Void, Never>
}

extension NonFailableStreamElementObserving {

    /// Observes the stream's elements.
    /// - parameter priority: An observation task priority.
    /// - parameter receiveElement: A closure called when the stream receives an element.
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

// MARK: NonFailableStreamElementMainObserving

/// Protocol describing a non-failable stream that can observe its elements on the main-actor.
public protocol NonFailableStreamElementMainObserving<Element> {

    /// The stream's element type.
    associatedtype Element: Sendable
    
    /// Observes the stream's elements on the main-actor.
    /// - parameter receiveElement: A closure called when the stream receives an element.
    /// - returns: An observation task.
    @discardableResult
    func observeOnMain(receiveElement: @escaping @MainActor (Element) async -> Void) -> Task<Void, Never>
}
