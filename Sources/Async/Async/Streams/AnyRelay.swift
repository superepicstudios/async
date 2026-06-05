//
//  AnyRelay.swift
//  Async
//
//  Created by Mitch Treece on 6/1/26.
//  Copyright © 2026 Super Epic Studios, LLC.
//

@preconcurrency public import Combine
import Foundation

/// A type-erased stream of elements that never produces failures.
///
/// ```swift
/// let stream = ValueStream<Int, Never>(1)
/// let erased: AnyRelay<Int> = stream.eraseToAnyRelay()
///
/// erased.sequence { seq in
///     for await e in seq {
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
/// - SeeAlso: ``AnyStream``, ``AnyDriver``
public struct AnyRelay<Element: Sendable>: NonFailableStream {
    
    private let wrapped: Wrapped

    public init<S>(_ failable: S) where S: FailableStream, S.Element == Element {
        self.wrapped = .failable(FailableStreamBox(failable))
    }

    public init(_ nonFailable: any NonFailableStream<Element>) {
        self.wrapped = .nonFailable(nonFailable)
    }
    
    public func makeAsyncSequence() -> any AsyncSendableSequence<Element, Never> {
        self.wrapped.makeAsyncSequence()
    }
    
    public func makePublisher() -> any Publisher<Element, Never> {
        self.wrapped.makePublisher()
    }
}

// MARK: Wrapped

extension AnyRelay {

    fileprivate struct FailableStreamBox: Sendable {

        let publisher: any Publisher<Element, Never>
        let elementProvider: (any StreamElementProviding<Element>)?
        let makeAsyncSequence: @Sendable () -> any AsyncSendableSequence<Element, Never>

        init<S>(_ stream: S) where S: FailableStream, S.Element == Element {
            self.publisher = NeverWrappedPublisher<Element, S.Failure>(stream.makePublisher())
            self.elementProvider = stream as? any StreamElementProviding<Element>
            self.makeAsyncSequence = { AsyncNeverWrappedSequence<Element, S.Failure>(stream.makeAsyncSequence()) }
        }
    }

    fileprivate enum Wrapped {

        case failable(FailableStreamBox)
        case nonFailable(any NonFailableStream<Element>)

        var elementProvider: (any StreamElementProviding<Element>)? {
            switch self {
            case let .failable(box):
                box.elementProvider
            case let .nonFailable(nonFailable):
                nonFailable as? any StreamElementProviding<Element>
            }
        }

        func makeAsyncSequence() -> any AsyncSendableSequence<Element, Never> {
            switch self {
            case let .failable(box):
                box.makeAsyncSequence()
            case let .nonFailable(nonFailable):
                nonFailable.makeAsyncSequence()
            }
        }
        
        func makePublisher() -> any Publisher<Element, Never> {
            switch self {
            case let .failable(box):
                box.publisher
            case let .nonFailable(nonFailable):
                nonFailable.makePublisher()
            }
        }
    }
}

// MARK: Sequencing

extension AnyRelay: StreamSequencing, StreamMainSequencing {}

// MARK: Element

extension AnyRelay: StreamElementProviding, NonFailableStreamElementObserving, NonFailableStreamElementMainObserving {

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
        onFinished: (@Sendable () async -> Void)?
    ) -> Task<Void, Never> {
        guard let observer = self.wrapped as? any NonFailableStreamElementObserving<Element> else {
            return Task {}
        }
        
        return observer.observe(
            priority: priority,
            onElement: onElement,
            onFinished: onFinished
        )
    }
    
    @discardableResult
    public func observeOnMain(
        onElement: @escaping @MainActor (Element) async -> Void,
        onFinished: (@MainActor () async -> Void)?
    ) -> Task<Void, Never> {
        guard let observer = self.wrapped as? any NonFailableStreamElementMainObserving<Element> else {
            return Task {}
        }
        
        return observer.observeOnMain(
            onElement: onElement,
            onFinished: onFinished
        )
    }
}
