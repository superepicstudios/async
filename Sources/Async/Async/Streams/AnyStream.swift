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
/// - SeeAlso: ``AnyRelay``
public struct AnyStream<Element: Sendable, Failure: Error>: FailableStream {
    
    enum Wrapped {
        
        case failable(any FailableStream<Element, Failure>)
        case nonFailable(any NonFailableStream<Element>)
        
        var publisher: any Publisher<Element, Failure> {
            return switch self {
            case let .failable(failable):
                failable.publisher
            case let .nonFailable(nonFailable):
                FailableWrappedPublisher(nonFailable.publisher)
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
                AsyncFailableWrappedSequence<Element, Failure>(nonFailable.makeAsyncSequence())
            }
        }
    }

    public var publisher: any Publisher<Element, Failure> {
        self.wrapped.publisher
    }
    
    private let wrapped: Wrapped
    
    public init(failable: any FailableStream<Element, Failure>) {
        self.wrapped = .failable(failable)
    }
    
    public init(nonFailable: any NonFailableStream<Element>) {
        self.wrapped = .nonFailable(nonFailable)
    }
    
    public func makeAsyncSequence() -> any AsyncSendableSequence<Element, Failure> {
        self.wrapped.makeAsyncSequence()
    }
}

// MARK: Sequencing

extension AnyStream: StreamSequencing, StreamMainSequencing {}

// MARK: Observing

extension AnyStream: FailableStreamObserving, FailableStreamMainObserving {
    
    public func observe(
        priority: TaskPriority,
        receiveElement: @escaping @Sendable (Element) async -> Void,
        receiveFailure: (@Sendable (Failure) async -> Void)?
    ) -> Task<Void, Never> {
        guard let observer = self.wrapped as? any FailableStreamObserving<Element, Failure> else {
            return Task {}
        }
        return observer.observe(
            priority: priority,
            receiveElement: receiveElement,
            receiveFailure: receiveFailure
        )
    }
    
    public func observeOnMain(
        receiveElement: @escaping @MainActor (Element) async -> Void,
        receiveFailure: (@MainActor (Failure) async -> Void)?
    ) -> Task<Void, Never> {
        guard let observer = self.wrapped as? any FailableStreamMainObserving<Element, Failure> else {
            return Task {}
        }
        return observer.observeOnMain(
            receiveElement: receiveElement,
            receiveFailure: receiveFailure
        )
    }
}

// MARK: Element Providing

extension AnyStream: StreamElementProviding {
    
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
