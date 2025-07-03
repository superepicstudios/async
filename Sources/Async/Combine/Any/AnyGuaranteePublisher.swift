//
//  AnyGuaranteePublisher.swift
//  Async
//
//  Created by Mitch Treece on 4/13/22.
//  Copyright © 2025 Super Epic Studios, LLC.
//

import Combine

/// A publisher that performs type erasure by wrapping another publisher, and can never fail.
public typealias AnyGuaranteePublisher<Output> = AnyPublisher<Output, Never>
