//
//  StreamSequencing.swift
//  Async
//
//  Created by Mitch Treece on 6/1/26.
//  Copyright © 2026 Super Epic Studios, LLC.
//

import Foundation

/// Protocol describing a stream that sequences its elements.
public protocol StreamSequencing<Element>: Sendable {

    /// The stream's element type.
    associatedtype Element: Sendable
}

/// Protocol describing a stream that sequences its elements on the main-actor.
public protocol StreamMainSequencing<Element>: Sendable {

    /// The stream's element type.
    associatedtype Element: Sendable
}

extension FailableStream where Self: StreamSequencing {

    /// Observes the stream synchronously, providing immediate access to its sequence of elements.
    /// - parameter priority: An observation task priority.
    /// - parameter body: A closure that provides immediate access to the stream's sequence of elements.
    /// - returns: An observation task.
    @discardableResult
    public func sequence<Success: Sendable>(
        priority: TaskPriority = .medium,
        body: @escaping @Sendable (any AsyncSequence<Element, Failure>) async throws -> Success
    ) -> Task<Success, any Error> {
        let sequence = makeAsyncSequence()
        return Task(priority: priority) {
            try await body(sequence)
        }
    }
}

extension FailableStream where Self: StreamMainSequencing {

    /// Observes the stream synchronously on the main-actor, providing immediate access to its sequence of elements.
    /// - parameter body: A closure that provides immediate access to the stream's sequence of elements.
    /// - returns: An observation task.
    @discardableResult
    public func sequenceOnMain<Success: Sendable>(
        body: @escaping @MainActor (any AsyncSequence<Element, Failure>) async throws -> Success
    ) -> Task<Success, any Error> {
        let sequence = makeAsyncSequence()
        return Task(priority: .high) {
            try await body(sequence)
        }
    }
}

extension NonFailableStream where Self: StreamSequencing {

    /// Observes the stream synchronously, providing immediate access to its sequence of elements.
    /// - parameter priority: An observation task priority.
    /// - parameter body: A closure that provides immediate access to the stream's sequence of elements.
    /// - returns: An observation task.
    @discardableResult
    public func sequence<Success: Sendable>(
        priority: TaskPriority = .medium,
        body: @escaping @Sendable (any AsyncSequence<Element, Never>) async -> Success
    ) -> Task<Success, Never> {
        let sequence = makeAsyncSequence()
        return Task(priority: priority) {
            await body(sequence)
        }
    }
}

extension NonFailableStream where Self: StreamMainSequencing {

    /// Observes the stream synchronously on the main-actor, providing immediate access to its sequence of elements.
    /// - parameter body: A closure that provides immediate access to the stream's sequence of elements.
    /// - returns: An observation task.
    @discardableResult
    public func sequenceOnMain<Success: Sendable>(
        body: @escaping @MainActor (any AsyncSequence<Element, Never>) async -> Success
    ) -> Task<Success, Never> {
        let sequence = makeAsyncSequence()
        return Task(priority: .high) {
            await body(sequence)
        }
    }
}
