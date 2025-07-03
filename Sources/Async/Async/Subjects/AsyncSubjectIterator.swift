//
//  AsyncSubjectIterator.swift
//  Async
//
//  Created by Mitch Treece on 5/17/25.
//  Copyright © 2025 Super Epic Studios, LLC.
//

import Foundation

/// Protocol describing an async subject iterator that produces elements one at a time.
public protocol AsyncSubjectIterator: AsyncIteratorProtocol, AsyncElementBuffering, Sendable {}
