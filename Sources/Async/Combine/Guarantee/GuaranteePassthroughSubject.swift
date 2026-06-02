//
//  GuaranteePassthroughSubject.swift
//  Async
//
//  Created by Mitch Treece on 4/13/22.
//  Copyright © 2025 Super Epic Studios, LLC.
//

@preconcurrency import Combine

/// A subject that outputs elements to downstream subscribers, and can never fail.
public typealias GuaranteePassthroughSubject<Output> = PassthroughSubject<Output, Never>
