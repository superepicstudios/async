//
//  GuaranteeTask.swift
//  Async
//
//  Created by Mitch Treece on 5/12/25.
//  Copyright © 2025 Super Epic Studios, LLC.
//

import Foundation

/// A task that can never fail.
public typealias GuaranteeTask<T> = Task<T, Never>
