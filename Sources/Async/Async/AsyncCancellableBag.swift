//
//  AsyncCancellableBag.swift
//  Async
//
//  Created by Mitch Treece on 7/3/25.
//  Copyright © 2025 Super Epic Studios, LLC.
//

import Foundation

/// Async cancellable storage that cancels added items when removed, _or_ on `deinit`.
///
/// - Note: In case contained cancellables need to be manually cancelled,
///   empty the bag, or create a new one in its place.
public typealias AsyncCancellableBag = Set<AnyAsyncCancellable>
