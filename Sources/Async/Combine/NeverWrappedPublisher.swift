//
//  NeverWrappedPublisher.swift
//  Async
//
//  Created by Mitch Treece on 6/1/26.
//  Copyright © 2026 Super Epic Studios, LLC.
//

@preconcurrency public import Combine
import Foundation

/// A publisher that wraps another failable publisher, and makes it look non-failable.
public struct NeverWrappedPublisher<Output, WrappedFailure: Error>: Publisher {

    public typealias Failure = Never

    private final class WrappedSubscriber: Subscriber {

        typealias Input = Output
        typealias Failure = WrappedFailure

        private let downstream: AnySubscriber<Output, Never>

        init(_ downstream: AnySubscriber<Output, Never>) {
            self.downstream = downstream
        }

        func receive(subscription: any Subscription) {
            self.downstream.receive(subscription: subscription)
        }

        func receive(_ input: Output) -> Subscribers.Demand {
            self.downstream.receive(input)
        }

        func receive(completion: Subscribers.Completion<WrappedFailure>) {
            self.downstream.receive(completion: .finished)
        }
    }

    private let wrapped: any Publisher<Output, WrappedFailure>

    public init(_ wrapped: any Publisher<Output, WrappedFailure>) {
        self.wrapped = wrapped
    }

    public func receive<S>(subscriber: S) where S: Subscriber, Never == S.Failure, Output == S.Input {
        let wrappedSubscriber = WrappedSubscriber(AnySubscriber(subscriber))
        self.wrapped.receive(subscriber: wrappedSubscriber)
    }
}
