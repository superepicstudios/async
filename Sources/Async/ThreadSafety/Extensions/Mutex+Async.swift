//
//  Mutex+Async.swift
//  Async
//
//  Created by Mitch Treece on 6/21/25.
//  Copyright © 2025 Super Epic Studios, LLC.
//

import Synchronization

extension Mutex {
        
    /// Initializes an optional mutex with a `nil` value.
    public init<T>() where Value == Optional<T> {
        self.init(nil)
    }
}

extension Mutex {
    
    /// Gets the mutex's protected value.
    /// - returns: The mutex's protected value.
    public func get() -> Value {
        withLock { $0 }
    }

    /// Sets the mutex's protected value.
    /// - parameter value: A value.
    public func set(_ value: Value) {
        
        // More info about this workaround
        // here: https://github.com/swiftlang/swift/issues/77199
        let workaround = { value }

        withLock {
            $0 = workaround()
        }
    }
}
