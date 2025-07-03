//
//  ValueManaging.swift
//  Async
//
//  Created by Mitch Treece on 5/20/25.
//  Copyright © 2025 Super Epic Studios, LLC.
//

import Foundation

/// Protocol describing something that manages
/// thread-safe read & write value operations.
public protocol ValueManaging<Value> {
    
    associatedtype Value
    
    /// Gets the managed value.
    func get() -> Value
    
    /// Sets a managed value.
    /// - parameter value: The value to set.
    func set(_ value: Value)
    
}
