//
//  Mutex+Async.swift
//  Async
//
//  Created by Mitch Treece on 6/21/25.
//

import Synchronization

extension Mutex {
        
    /// Initializes an optional mutex with a `nil` value.
    public init<T>() where Value == Optional<T> {
        self.init(nil)
    }

}

extension Mutex {
    
    // We're effectively re-implementing the `ValueManaging` protocol here.
    // We can't directly conform to it because of associated value `Copyable`
    // requirements.
    
    public func get() -> Value {
        withLock { $0 }
    }

    public func set(_ value: Value) {

        // Workaround info: https://github.com/swiftlang/swift/issues/77199

        let workaround = { value }

        withLock {
            $0 = workaround()
        }

    }
    
}
