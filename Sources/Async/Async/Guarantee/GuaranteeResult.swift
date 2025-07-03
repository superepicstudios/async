//
//  GuaranteeResult.swift
//  Async
//
//  Created by Mitch Treece on 5/12/25.
//  Copyright © 2025 Super Epic Studios, LLC.
//

import Foundation

/// A result that can never fail.
public typealias GuaranteeResult<T> = Result<T, Never>
