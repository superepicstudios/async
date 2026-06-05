//
//  MainQueuePublisher.swift
//  Async
//
//  Created by Mitch Treece on 6/1/26.
//  Copyright © 2026 Super Epic Studios, LLC.
//

@preconcurrency public import Combine
import Foundation

/// A publisher that wraps another publisher, and delivers elements & completions on the main-queue.
public struct MainQueuePublisher<Output: Sendable, Failure: Error & Sendable>: Publisher {
    
    private let wrapped: any Publisher<Output, Failure>

    public init(_ wrapped: any Publisher<Output, Failure>) {
        self.wrapped = wrapped
    }

    public func receive<S>(subscriber: S) where S: Subscriber, S.Input == Output, S.Failure == Failure {
        let wrappedSubscriber = WrappedSubscriber(AnySubscriber(subscriber))
        self.wrapped.receive(subscriber: wrappedSubscriber)
    }
}

extension MainQueuePublisher {
    
    private final class WrappedSubscriber: Subscriber, @unchecked Sendable {

        typealias Input = Output
        
        private let downstream: AnySubscriber<Output, Failure>

        init(_ downstream: AnySubscriber<Output, Failure>) {
            self.downstream = downstream
        }

        func receive(subscription: any Subscription) {
            downstream.receive(subscription: subscription)
        }

        func receive(_ input: Output) -> Subscribers.Demand {
            DispatchQueue.main.async { [downstream, input] in
                _ = downstream.receive(input)
            }
            return .none
        }

        func receive(completion: Subscribers.Completion<Failure>) {
            DispatchQueue.main.async { [downstream] in
                switch completion {
                case .finished:
                    downstream.receive(completion: .finished)
                case let .failure(error):
                    downstream.receive(completion: .failure(error))
                }
            }
        }
    }
}
