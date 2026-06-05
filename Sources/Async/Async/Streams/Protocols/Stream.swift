//
//  Stream.swift
//  Async
//
//  Created by Mitch Treece on 6/1/26.
//  Copyright © 2026 Super Epic Studios, LLC.
//

@preconcurrency public import Combine
import Foundation

// MARK: StreamBase

/// Protocol describing a stream of elements.
public protocol StreamBase<Element>: Sendable {

    /// The stream's element type.
    associatedtype Element: Sendable
}

// MARK: FailableStream

/// Protocol describing a failable stream of elements.
///
/// Streams are unions between the standard library's [AsyncSequence](https://developer.apple.com/documentation/Swift/AsyncSequence),
/// and Combine [publishers](https://developer.apple.com/documentation/combine/publisher). They can be used in either context, and
/// help bridge the gap between Combine usage, and modern async API's.
///
/// ```swift
/// let stream = ValueStream<Int, Never>(0)
///
/// stream.observe { e in
///     print("Observe: \(e)")
/// }
///
/// stream.sequence { seq in
///     for try await e in seq {
///         print("Sequence: \(e)")
///     }
/// }
///
/// stream.publisher.sink { e in
///     print("Publisher: \(e)")
/// }
///
/// stream.send(1)
/// stream.send(2)
/// stream.send(3)
/// ```
public protocol FailableStream<Element, Failure>: StreamBase {

    /// The stream's failure type.
    associatedtype Failure: Error
    
    /// The stream's publisher.
    var publisher: any Publisher<Element, Failure> { get }
    
    /// Gets a new async sequence for the stream.
    /// - returns: A new async sequence.
    ///
    /// - Note: You shouldn't usually need to call this directly. If you're trying to observe/iterate
    ///   over the stream's elements, it's recommended to use the ``sequence(priority:body:)``,
    ///   ``observe(priority:receiveElement:receiveFailure:)``, or ``sink(receiveCompletion:receiveValue:)``
    ///   functions.
    func makeAsyncSequence() -> any AsyncSendableSequence<Element, Failure>
}

// MARK: NonFailableStream

/// Protocol describing a non-failable stream of elements.
///
/// Streams are unions between the standard library's [AsyncSequence](https://developer.apple.com/documentation/Swift/AsyncSequence),
/// and Combine [publishers](https://developer.apple.com/documentation/combine/publisher). They can be used in either context, and
/// help bridge the gap between Combine usage, and modern async API's.
///
/// ```swift
/// let stream = JustStream<Int>(0)
///
/// stream.observe { e in
///     print("Observe: \(e)")
/// }
///
/// stream.sequence { seq in
///     for await e in seq {
///         print("Sequence: \(e)")
///     }
/// }
///
/// stream.publisher.sink { e in
///     print("Publisher: \(e)")
/// }
/// ```
public protocol NonFailableStream<Element>: StreamBase {

    /// The stream's publisher.
    var publisher: any Publisher<Element, Never> { get }
    
    /// Gets a new async sequence for the stream.
    /// - returns: A new async sequence.
    ///
    /// - Note: You shouldn't usually need to call this directly. If you're trying to observe/iterate
    ///   over the stream's elements, it's recommended to use the ``sequence(priority:body:)``,
    ///   ``observe(priority:receiveElement:receiveFailure:)``, or ``sink(receiveCompletion:receiveValue:)``
    ///   functions.
    func makeAsyncSequence() -> any AsyncSendableSequence<Element, Never>
}
