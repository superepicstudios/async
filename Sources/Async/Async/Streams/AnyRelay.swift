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
/// - SeeAlso: ``AnyStream``
public struct AnyRelay<Element: Sendable>: NonFailableStream {

    private struct FailableStreamBox: Sendable {
        
        let publisher: any Publisher<Element, Never>
        let elementProvider: (any StreamElementProviding<Element>)?
        let makeAsyncSequence: @Sendable () -> any AsyncSendableSequence<Element, Never>
        
        init<S>(_ stream: S) where S: FailableStream, S.Element == Element {
            self.publisher = NeverWrappedPublisher<Element, S.Failure>(stream.publisher)
            self.elementProvider = stream as? any StreamElementProviding<Element>
            self.makeAsyncSequence = { AsyncNeverWrappedSequence<Element, S.Failure>(stream.makeAsyncSequence()) }
        }
    }
    
    private enum Wrapped {

        case failable(FailableStreamBox)
        case nonFailable(any NonFailableStream<Element>)

        var publisher: any Publisher<Element, Never> {
            switch self {
            case let .failable(box):
                box.publisher
            case let .nonFailable(nonFailable):
                nonFailable.publisher
            }
        }
        
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
    }
    
    public var publisher: any Publisher<Element, Never> {
        self.wrapped.publisher
    }

    private let wrapped: Wrapped

    public init<S>(failable: S) where S: FailableStream, S.Element == Element {
        self.wrapped = .failable(FailableStreamBox(failable))
    }

    public init(nonFailable: any NonFailableStream<Element>) {
        self.wrapped = .nonFailable(nonFailable)
    }
    
    public func makeAsyncSequence() -> any AsyncSendableSequence<Element, Never> {
        self.wrapped.makeAsyncSequence()
    }
}

// MARK: Sequencing

extension AnyRelay: StreamSequencing, StreamMainSequencing {}

// MARK: Observing

extension AnyRelay: NonFailableStreamObserving, NonFailableStreamMainObserving {
    
    @discardableResult
    public func observe(
        priority: TaskPriority,
        receiveElement: @escaping @Sendable (Element) async -> Void
    ) -> Task<Void, Never> {
        guard let observer = self.wrapped as? any NonFailableStreamObserving<Element> else {
            return Task {}
        }
        return observer.observe(
            priority: priority,
            receiveElement: receiveElement
        )
    }
    
    @discardableResult
    public func observeOnMain(
        receiveElement: @escaping @MainActor (Element) async -> Void
    ) -> Task<Void, Never> {
        guard let observer = self.wrapped as? any NonFailableStreamMainObserving<Element> else {
            return Task {}
        }
        return observer.observeOnMain(
            receiveElement: receiveElement
        )
    }
}

// MARK: Element Providing

extension AnyRelay: StreamElementProviding {
    
    /// The stream's latest element.
    ///
    /// - Warning: This assumes the stream has elements in its buffer.
    ///   If it doesn't, accessing this will throw a fatal error.
    public var latest: Element {
        guard let element = self.wrapped.elementProvider?.latest else {
            fatalError("Attempting to access the latest element of an empty stream. What are you doing developer?")
        }
        
        return element
    }
}
