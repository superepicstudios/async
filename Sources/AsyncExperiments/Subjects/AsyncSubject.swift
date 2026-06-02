//
//  AsyncSubject.swift
//  AsyncExperiments
//
//  Created by Mitch Treece on 5/17/25.
//  Copyright © 2025 Super Epic Studios, LLC.
//

import Foundation

/// Protocol describing an async subject that can send elements to downstream consumers.
public protocol AsyncSubject<Element>: AnyObject, AsyncSequence, AsyncElementSending, AsyncCompletionSending, Sendable
                                       where AsyncIterator: AsyncSubjectIterator, Element: Sendable {}
