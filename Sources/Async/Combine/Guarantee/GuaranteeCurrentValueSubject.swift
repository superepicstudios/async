//
//  GuaranteeCurrentValueSubject.swift
//  Async
//
//  Created by Mitch Treece on 9/13/22.
//  Copyright © 2025 Super Epic Studios, LLC.
//

@preconcurrency import Combine

/// A subject that outputs an initial and all future values to downstream subscribers, and can never fail.
public typealias GuaranteeCurrentValueSubject<Output> = CurrentValueSubject<Output, Never>
