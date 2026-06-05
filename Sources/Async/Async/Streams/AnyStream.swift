//
//  AnyStream.swift
//  Async
//
//  Created by Mitch Treece on 6/1/26.
//  Copyright © 2026 Super Epic Studios, LLC.
//

@preconcurrency public import Combine
import Foundation

/// A type-erased stream of elements.
///
/// ```swift
/// let stream = ValueStream<Int, Never>(1)
/// let erased: AnyStream<Int, Never> = stream.eraseToAnyStream()
///
/// erased.sequence { seq in
///     for try await e in seq {
///         print("Received: \(e)")
///     }
///     print("Finished")
/// }
///
/// stream.send(2)
/// stream.send(3)
/// stream.send(completion: .finished)
///
/// // → "Received: 1"
/// // → "Received: 2"
/// // → "Received: 3"
/// // → "Finished"
/// ```
///
/// - SeeAlso: ``AnyRelay``, ``AnyDriver``
public struct AnyStream<Element: Sendable, Failure: Error>: FailableStream {

    public var publisher: any Publisher<Element, Failure> {
        self.wrapped.publisher
    }
    
    private let wrapped: Wrapped
    
    public init(_ failable: any FailableStream<Element, Failure>) {
        self.wrapped = .failable(failable)
    }
    
    public init(_ nonFailable: any NonFailableStream<Element>) {
        self.wrapped = .nonFailable(nonFailable)
    }
    
    public func makeAsyncSequence() -> any AsyncSendableSequence<Element, Failure> {
        self.wrapped.makeAsyncSequence()
    }
}

// MARK: Wrapped

extension AnyStream {

    fileprivate enum Wrapped {

        case failable(any FailableStream<Element, Failure>)
        case nonFailable(any NonFailableStream<Element>)

        var publisher: any Publisher<Element, Failure> {
            return switch self {
            case let .failable(failable):
                failable.publisher
            case let .nonFailable(nonFailable):
                FailureWrappedPublisher(nonFailable.publisher)
            }
        }

        var elementProvider: (any StreamElementProviding<Element>)? {
            switch self {
            case let .failable(failable):
                failable as? any StreamElementProviding<Element>
            case let .nonFailable(nonFailable):
                nonFailable as? any StreamElementProviding<Element>
            }
        }

        func makeAsyncSequence() -> any AsyncSendableSequence<Element, Failure> {
            switch self {
            case let .failable(failable):
                failable.makeAsyncSequence()
            case let .nonFailable(nonFailable):
                AsyncFailureWrappedSequence<Element, Failure>(nonFailable.makeAsyncSequence())
            }
        }
    }
}

// MARK: Sequencing

extension AnyStream: StreamSequencing, StreamMainSequencing {}

// MARK: Element

extension AnyStream: StreamElementProviding, FailableStreamElementObserving, FailableStreamElementMainObserving {

    public var latest: Element {
        guard let element = self.wrapped.elementProvider?.latest else {
            fatalError(StreamError.emptyStream.localizedDescription)
        }
        return element
    }

    @discardableResult
    public func observe(
        priority: TaskPriority,
        onElement: @escaping @Sendable (Element) async -> Void,
        onFailure: (@Sendable (Failure) async -> Void)?,
        onFinished: (@Sendable () async -> Void)?
    ) -> Task<Void, Never> {
        guard let observer = self.wrapped as? any FailableStreamElementObserving<Element, Failure> else {
            return Task {}
        }
        
        return observer.observe(
            priority: priority,
            onElement: onElement,
            onFailure: onFailure,
            onFinished: onFinished
        )
    }
    
    @discardableResult
    public func observeOnMain(
        onElement: @escaping @MainActor (Element) async -> Void,
        onFailure: (@MainActor (Failure) async -> Void)?,
        onFinished: (@MainActor () async -> Void)?
    ) -> Task<Void, Never> {
        guard let observer = self.wrapped as? any FailableStreamElementMainObserving<Element, Failure> else {
            return Task {}
        }
        
        return observer.observeOnMain(
            onElement: onElement,
            onFailure: onFailure,
            onFinished: onFinished
        )
    }
}
