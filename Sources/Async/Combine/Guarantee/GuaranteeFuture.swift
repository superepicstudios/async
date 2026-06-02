//
//  GuaranteeFuture.swift
//  Async
//
//  Created by Mitch Treece on 7/27/22.
//  Copyright © 2025 Super Epic Studios, LLC.
//

@preconcurrency import Combine

/// A publisher that eventually produces a single value then finishes, and can never fail.
public typealias GuaranteeFuture<T> = Future<T, Never>
