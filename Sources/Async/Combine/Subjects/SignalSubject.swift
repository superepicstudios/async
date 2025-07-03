//
//  SignalSubject.swift
//  Async
//
//  Created by Mitch Treece on 4/13/22.
//  Copyright © 2025 Super Epic Studios, LLC.
//

@preconcurrency import Combine

/// A subject that sends signals to downstream subscribers.
public typealias SignalSubject = GuaranteePassthroughSubject<Void>
