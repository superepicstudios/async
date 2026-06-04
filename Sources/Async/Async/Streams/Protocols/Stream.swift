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

// MARK: Stream

/// Protocol describing a stream of elements.
public protocol Stream<Element>: Sendable {
    
    /// The stream's element type.
    associatedtype Element: Sendable
}

// MARK: FailableStream

/// Protocol describing a failable stream of elements.
///
/// Streams are unions between the standard library's [AsyncSequence](https://developer.apple.com/documentation/Swift/AsyncSequence), and Combine
/// [publishers](https://developer.apple.com/documentation/combine/publisher). They can be used in either context, and help bridge the gap between
/// Combine usage, and modern async API's.
///
/// ```swift
/// let stream = ValueStream<Int, Never>(0)
///
/// stream.observe { element in
///     print("Observe: \(element)")
/// }
///
/// stream.sequence { sequence in
///     for try await element in sequence {
///         print("Sequence: \(element)")
///     }
/// }
///
/// stream.publisher.sink { value in
///     print("Publisher: \(value)")
/// }
///
/// stream.send(1)
/// stream.send(2)
/// stream.send(3)
/// ```
public protocol FailableStream<Element, Failure>: Stream {
    
    /// The stream's failure type.
    associatedtype Failure: Error
    
    /// The stream's publisher.
    var publisher: any Publisher<Element, Failure> { get }
    
    /// Gets a new async sequence for the stream.
    /// - returns: A new async sequence.
    func makeAsyncSequence() -> any AsyncSendableSequence<Element, Failure>
}

// MARK: NonFailableStream

/// Protocol describing a non-failable stream of elements.
///
/// Streams are unions between the standard library's [AsyncSequence](https://developer.apple.com/documentation/Swift/AsyncSequence), and Combine
/// [publishers](https://developer.apple.com/documentation/combine/publisher). They can be used in either context, and help bridge the gap between
/// Combine usage, and modern async API's.
///
/// ```swift
/// let stream = ValueStream<Int, Never>(0) // failable
/// let relay: AnyRelay<Int> = stream.eraseToAnyRelay() // non-failable
///
/// relay.observe { element in
///     print("Observe: \(element)")
/// }
///
/// relay.sequence { sequence in
///     for await element in sequence {
///         print("Sequence: \(element)")
///     }
/// }
///
/// relay.publisher.sink { value in
///     print("Publisher: \(value)")
/// }
///
/// stream.send(1)
/// stream.send(2)
/// stream.send(3)
/// ```
public protocol NonFailableStream<Element>: Stream {
    
    /// The stream's publisher.
    var publisher: any Publisher<Element, Never> { get }
    
    /// Gets a new async sequence for the stream.
    /// - returns: A new async sequence.
    func makeAsyncSequence() -> any AsyncSendableSequence<Element, Never>
}
