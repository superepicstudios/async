//
//  Critical.swift
//  Async
//
//  Created by Mitch Treece on 5/20/25.
//  Copyright © 2025 Super Epic Studios, LLC.
//

import Darwin

/// A type that wraps a value, and manages critical read & write operations using a locked buffer.
///
/// - Note: This is a public reimplementation of ``ManagedCriticalState`` from
///   [AsyncAlgorithms](https://github.com/apple/swift-async-algorithms).
///
/// - SeeAlso: ``@Mutex``
public struct Critical<Value>: ValueManaging {
    
    /// The critical value.
    public var value: Value {
        get { get() }
        set { set(newValue) }
    }
    
    private let buffer: ManagedBuffer<Value, os_unfair_lock>
    
    /// Initializes a critical value.
    /// - parameter initial: The initial value.
    public init(_ initial: Value) {
        
        self.buffer = LockedBuffer.create(minimumCapacity: 1) { buffer in
            
            buffer.withUnsafeMutablePointerToElements { lock in
                lock.initialize(to: os_unfair_lock())
            }
            
            return initial
            
        }
                
    }
    
    /// Initializes an optional critical value.
    public init<T>() where Value == Optional<T> {
        self.init(nil)
    }
    
    /// Accesses the critical value's memory, providing isolated & mutable access to the value.
    /// - parameter closure: A closure to perform on the managed value.
    @discardableResult
    public func withCriticalRegion<R>(_ closure: (inout Value) throws -> R) rethrows -> R {
        
        return try buffer.withUnsafeMutablePointers { header, lock in
            
            os_unfair_lock_lock(lock)
            defer { os_unfair_lock_unlock(lock) }
            return try closure(&header.pointee)
            
        }
        
    }
    
    // MARK: ValueManaging
    
    public func get() -> Value {
        withCriticalRegion { $0 }
    }
    
    public func set(_ value: Value) {
        withCriticalRegion { $0 = value }
    }
    
}

extension Critical: @unchecked Sendable where Value: Sendable {}

// MARK: LockedBuffer

fileprivate final class LockedBuffer<Value>: ManagedBuffer<Value, os_unfair_lock> {
    
    deinit {
        
        _ = withUnsafeMutablePointerToElements { lock in
            lock.deinitialize(count: 1)
        }
        
    }
    
}
