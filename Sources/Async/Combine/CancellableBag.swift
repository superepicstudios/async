//
//  CancellableBag.swift
//  Async
//
//  Created by Mitch Treece on 4/13/22.
//  Copyright © 2025 Super Epic Studios, LLC.
//

@preconcurrency import Combine

/// Cancellable storage that cancels added items when removed, _or_ on `deinit`.
///
/// - Note: In case contained cancellables need to be manually cancelled,
///   empty the bag, or create a new one in its place.
public typealias CancellableBag = Set<AnyCancellable>
