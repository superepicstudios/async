//
//  Actor+Async.swift
//  Async
//
//  Created by Mitch Treece on 5/12/25.
//  Copyright © 2025 Super Epic Studios, LLC.
//

import Foundation

extension Actor {
    
    /// Performs a closure within the actor's isolation context.
    /// - parameter body: The closure to perform.
    public func isolated<T: Sendable>(_ body: (isolated Self) -> T) -> T {
        body(self)
    }
    
}
