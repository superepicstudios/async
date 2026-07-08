//
//  Task+Async.swift
//  Async
//
//  Created by Mitch Treece on 6/17/25.
//  Copyright © 2025 Super Epic Studios, LLC.
//

@preconcurrency import Combine
import Foundation

/// Representation of the various ``Task`` errors.
public enum TaskError: Error {
    
    /// A timeout (maximum duration) error.
    case timeout
}

extension Task {
    
    /// Stores the task as a type-erased cancellable in the specified set.
    /// - parameter set: The set in which to store this ``Task``.
    public func store(in set: inout CancellableSet) {
        set.insert(AnyCancellable {
            cancel()
        })
    }
}

extension Task where Success == Void, Failure == Never {
    
    /// An empty task that performs no work, and never fails.
    public static var empty: Self { .init() {} }
}

extension Task where Success == Never, Failure == Never {
    
    /// Suspends the current task for a given duration, and swallows thrown errors.
    /// - parameter duration: A duration to sleep for.
    /// - parameter tolerance: An allowed sleep tolerance.
    /// - parameter clock: A clock to use for sleeping.
    public static func sleepNonThrowing<C: Clock>(
        for duration: C.Instant.Duration,
        tolerance: C.Instant.Duration? = nil,
        using clock: C = .continuous
    ) async {
        try? await sleep(
            for: duration,
            tolerance: tolerance,
            clock: clock
        )
    }
    
    /// Performs a body of work, enforcing a minimum execution duration.
    /// - parameter duration: The minimum duration.
    /// - parameter body: The work to execute.
    public static func withMinimumDuration<T>(
        _ duration: Duration,
        body: () async -> T
    ) async -> T {
        
        let clock = ContinuousClock()
        async let sleep: () = clock.sleep(for: duration)
        
        let result = await body()
        try? await sleep
        return result
    }
    
    /// Performs a body of work, enforcing a minimum execution duration.
    /// - parameter duration: The minimum duration.
    /// - parameter throwImmediately: Flag indicating if errors should be thrown _before_ the minimum duration.
    /// - parameter body: The work to execute.
    public static func withThrowingMinimumDuration<T>(
        _ duration: Duration,
        throwImmediately: Bool = false,
        body: () async throws -> T
    ) async throws -> T {
        
        let clock = ContinuousClock()
        async let sleep: () = clock.sleep(for: duration)
        
        do {
            let result = try await body()
            try await sleep
            return result
        }
        catch {
            guard !throwImmediately else {
                throw error
            }
            
            try await sleep
            throw error
        }
    }
    
    /// Performs a body of work, enforcing a maximum (timeout) execution duration.
    /// - parameter duration: The maximum duration.
    /// - parameter body: The work to execute.
    public static func withMaximumDuration<T: Sendable>(
        _ duration: Duration,
        body: @escaping @Sendable () async throws -> T
    ) async throws -> T {

        let clock = ContinuousClock()
        
        let task = Task<T, any Error> {
            let result = try await body()
            try Task.checkCancellation()
            return result
        }
        
        let timeout = Task<Void, any Error> {
            try await clock.sleep(for: duration)
            task.cancel()
        }
        
        do {
            let result = try await task.value
            timeout.cancel()
            return result
        }
        catch {
            throw TaskError.timeout
        }
    }
}
