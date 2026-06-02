//
//  StreamProtocol.swift
//  Async
//
//  Created by Mitch Treece on 6/1/26.
//  Copyright © 2026 Super Epic Studios, LLC.
//

@preconcurrency public import Combine
@preconcurrency import CombineExt
import Foundation

/// Protocol describing an observable stream of elements.
///
/// Streams are unions between the standard library's ``AsyncSequence``, and [Combine's](https://developer.apple.com/documentation/combine) ``Publisher``.
/// They can be used in either context, and help bridge the gap between [Combine](https://developer.apple.com/documentation/combine) usage, and modern async API's.
///
/// ```swift
/// let stream = ValueStream<Int, Never>(0)
///
/// Task {
///     for try await value in stream {
///         print("AsyncSequence: \(value)")
///     }
/// }
///
/// stream.sink { value in
///     print("Publisher: \(value)")
/// }
///
/// stream.send(1)
/// stream.send(2)
/// stream.send(3)
/// ```
public protocol StreamProtocol<Element, Failure>: AsyncSequence, Publisher, Sendable
    where Element: Sendable, Element == Output, Failure: Error, Failure == AsyncIterator.Failure {}
