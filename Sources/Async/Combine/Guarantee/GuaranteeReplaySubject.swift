//
//  GuaranteeReplaySubject.swift
//  Async
//
//  Created by Mitch Treece on 6/1/26.
//  Copyright © 2026 Super Epic Studios, LLC.
//

@preconcurrency import Combine
@preconcurrency import CombineExt

/// A subject that replays a buffered amount of elements to downstream subscribers, and can never fail.
public typealias GuaranteeReplaySubject<Output> = ReplaySubject<Output, Never>

