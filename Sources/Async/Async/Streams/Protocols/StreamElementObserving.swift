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
    /// - parameter onElement: A closure called when the stream receives an element.
    /// - parameter onFailure: A closure called when the stream receives a failure.
    /// - parameter onFinished: A closure called when the stream finishes.
    /// - returns: An observation task.
    @discardableResult
    func observe(
        priority: TaskPriority,
        onElement: @escaping @Sendable (Element) async -> Void,
        onFailure: (@Sendable (Failure) async -> Void)?,
        onFinished: (@Sendable () async -> Void)?
    ) -> Task<Void, Never>
}

extension FailableStreamElementObserving {

    /// Observes the stream's elements.
    /// - parameter priority: An observation task priority.
    /// - parameter onElement: A closure called when the stream receives an element.
    /// - parameter onFailure: A closure called when the stream receives a failure.
    /// - parameter onFinished: A closure called when the stream finishes.
    /// - returns: An observation task.
    @discardableResult
    public func observe(
        priority: TaskPriority = .medium,
        onElement: @escaping @Sendable (Element) async -> Void,
        onFailure: (@Sendable (Failure) async -> Void)? = nil,
        onFinished: (@Sendable () async -> Void)? = nil
    ) -> Task<Void, Never> {
        observe(
            priority: priority,
            onElement: onElement,
            onFailure: onFailure,
            onFinished: onFinished
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
    /// - parameter onElement: A closure called when the stream receives an element.
    /// - parameter onFailure: A closure called when the stream receives a failure.
    /// - parameter onFinished: A closure called when the stream finishes.
    /// - returns: An observation task.
    @discardableResult
    func observeOnMain(
        onElement: @escaping @MainActor (Element) async -> Void,
        onFailure: (@MainActor (Failure) async -> Void)?,
        onFinished: (@MainActor () async -> Void)?
    ) -> Task<Void, Never>
}

extension FailableStreamElementMainObserving {

    /// Observes the stream's elements on the main-actor.
    /// - parameter onElement: A closure called when the stream receives an element.
    /// - parameter onFailure: A closure called when the stream receives a failure.
    /// - parameter onFinished: A closure called when the stream finishes.
    /// - returns: An observation task.
    @discardableResult
    public func observeOnMain(
        onElement: @escaping @MainActor (Element) async -> Void,
        onFailure: (@MainActor (Failure) async -> Void)? = nil,
        onFinished: (@MainActor () async -> Void)? = nil
    ) -> Task<Void, Never> {
        observeOnMain(
            onElement: onElement,
            onFailure: onFailure,
            onFinished: onFinished
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
    /// - parameter onElement: A closure called when the stream receives an element.
    /// - parameter onFinished: A closure called when the stream finishes.
    /// - returns: An observation task.
    @discardableResult
    func observe(
        priority: TaskPriority,
        onElement: @escaping @Sendable (Element) async -> Void,
        onFinished: (@Sendable () async -> Void)?
    ) -> Task<Void, Never>
}

extension NonFailableStreamElementObserving {

    /// Observes the stream's elements.
    /// - parameter priority: An observation task priority.
    /// - parameter onElement: A closure called when the stream receives an element.
    /// - parameter onFinished: A closure called when the stream finishes.
    /// - returns: An observation task.
    @discardableResult
    public func observe(
        priority: TaskPriority = .medium,
        onElement: @escaping @Sendable (Element) async -> Void,
        onFinished: (@Sendable () async -> Void)? = nil
    ) -> Task<Void, Never> {
        observe(
            priority: priority,
            onElement: onElement,
            onFinished: onFinished
        )
    }
}

// MARK: NonFailableStreamElementMainObserving

/// Protocol describing a non-failable stream that can observe its elements on the main-actor.
public protocol NonFailableStreamElementMainObserving<Element> {

    /// The stream's element type.
    associatedtype Element: Sendable
    
    /// Observes the stream's elements on the main-actor.
    /// - parameter onElement: A closure called when the stream receives an element.
    /// - parameter onFinished: A closure called when the stream finishes.
    /// - returns: An observation task.
    @discardableResult
    func observeOnMain(
        onElement: @escaping @MainActor (Element) async -> Void,
        onFinished: (@MainActor () async -> Void)?
    ) -> Task<Void, Never>
}

extension NonFailableStreamElementMainObserving {

    /// Observes the stream's elements on the main-actor.
    /// - parameter onElement: A closure called when the stream receives an element.
    /// - parameter onFinished: A closure called when the stream finishes.
    /// - returns: An observation task.
    @discardableResult
    public func observeOnMain(
        onElement: @escaping @MainActor (Element) async -> Void,
        onFinished: (@MainActor () async -> Void)? = nil
    ) -> Task<Void, Never> {
        observeOnMain(
            onElement: onElement,
            onFinished: onFinished
        )
    }
}
