//
//  CancellableSet.swift
//  Async
//
//  Created by Mitch Treece on 4/13/22.
//  Copyright © 2025 Super Epic Studios, LLC.
//

@preconcurrency import Combine

/// A set of cancellable elements.
///
/// - SeeAlso: ``CancelBag``
public typealias CancellableSet = Set<AnyCancellable>
