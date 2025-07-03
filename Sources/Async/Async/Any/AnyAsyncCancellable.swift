//
//  AnyAsyncCancellable.swift
//  Async
//
//  Created by Mitch Treece on 7/3/25.
//  Copyright © 2025 Super Epic Studios, LLC.
//

import Foundation

/// A type-erased async cancellable object.
public typealias AnyAsyncCancellable = Task<Void, any Error>
