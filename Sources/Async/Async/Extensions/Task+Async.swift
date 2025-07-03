//
//  Task+Async.swift
//  Async
//
//  Created by Mitch Treece on 6/17/25.
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
    public func store(in set: inout Set<AnyCancellable>) {
        
        set.insert(.init {
            cancel()
        })
        
    }
    
}

extension Task where Success == Never, Failure == Never {
    
    /// Performs a body of work, enforcing a minimum execution duration.
    /// - parameter duration: The minimum duration.
    /// - parameter throwImmediately: Flag indicating if errors should be thrown _before_
    ///   the minimum duration.
    /// - parameter body: The work to execute.
    public static func withMinimumDuration<T>(
        _ duration: Duration,
        _ body: () async -> T
    ) async -> T {
        
        let clock = ContinuousClock()
        async let sleep: () = clock.sleep(for: duration)
        
        let result = await body()
        try? await sleep
        return result
        
    }
    
    /// Performs a body of work, enforcing a minimum execution duration.
    /// - parameter duration: The minimum duration.
    /// - parameter throwImmediately: Flag indicating if errors should be thrown _before_
    ///   the minimum duration.
    /// - parameter body: The work to execute.
    public static func withMinimumDuration<T>(
        _ duration: Duration,
        throwImmediately: Bool = false,
        _ body: () async throws -> T
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
        _ body: @escaping @Sendable () async throws -> T
    ) async throws -> T {

        let clock = ContinuousClock()
        
        let work = Task<T, any Error> {
            
            let result = try await body()
            try Task.checkCancellation()
            return result
            
        }
        
        let timeout = Task<Void, any Error> {
            
            try await clock.sleep(for: duration)
            work.cancel()
            
        }
        
        do {
            
            let result = try await work.value
            timeout.cancel()
            return result
            
        }
        catch {
            throw TaskError.timeout
        }
        
    }
    
}
