//
//  @Mutex.swift
//  Async
//
//  Created by Mitch Treece on 6/21/25.
//

import Synchronization

/// A macro that wraps a value in a ``Mutex``,
/// and enforces thread-safe read & write operations.
@attached(accessor)
@attached(peer, names: prefixed(_))
public macro Mutex() = #externalMacro(
    module: "AsyncMacros",
    type: "MutexMacro"
)
