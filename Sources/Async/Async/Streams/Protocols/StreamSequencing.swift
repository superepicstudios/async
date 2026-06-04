//
//  StreamSending.swift
//  Async
//
//  Created by Mitch Treece on 6/1/26.
//  Copyright © 2026 Super Epic Studios, LLC.
//

import Foundation

/// Protocol describing a stream that sequences its elements.
public protocol StreamSequencing: Sendable {}

/// Protocol describing a stream that sequences its elements on the main-actor.
public protocol StreamMainSequencing: Sendable {}

extension FailableStream where Self: StreamSequencing {
    
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
    
    public func sequenceOnMain<Success: Sendable>(
        body: @escaping @MainActor (any AsyncSequence<Element, Never>) async -> Success
    ) -> Task<Success, Never> {
        let sequence = makeAsyncSequence()
        return Task(priority: .high) {
            await body(sequence)
        }
    }
}
