//
//  AsyncSendableSequence.swift
//  Async
//
//  Created by Mitch Treece on 6/3/26.
//  Copyright © 2026 Super Epic Studios, LLC.
//

import Foundation

public typealias AsyncSendableSequence<Element: Sendable, Failure: Sendable> = AsyncSequence<Element, Failure> & Sendable
