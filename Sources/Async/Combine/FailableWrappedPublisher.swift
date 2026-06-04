//
//  FailableWrappedPublisher.swift
//  Async
//
//  Created by Mitch Treece on 6/1/26.
//  Copyright © 2026 Super Epic Studios, LLC.
//

@preconcurrency public import Combine
import Foundation

/// A publisher that wraps another non-failable publisher, and makes it look failable.
public struct FailableWrappedPublisher<Output, Failure: Error>: Publisher {
    
    final class WrappedSubscriber<DownstreamFailure: Error>: Subscriber {
        
        typealias Input = Output
        typealias Failure = Never
        
        private let downstream: AnySubscriber<Output, DownstreamFailure>
        
        init(_ downstream: AnySubscriber<Output, DownstreamFailure>) {
            self.downstream = downstream
        }
        
        func receive(subscription: any Subscription) {
            self.downstream.receive(subscription: subscription)
        }
        
        func receive(_ input: Output) -> Subscribers.Demand {
            self.downstream.receive(input)
        }
        
        func receive(completion: Subscribers.Completion<Never>) {
            self.downstream.receive(completion: .finished)
        }
    }
    
    private let wrapped: any Publisher<Output, Never>
    
    public init(_ wrapped: any Publisher<Output, Never>) {
        self.wrapped = wrapped
    }
    
    public func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
        let wrappedSubscriber = WrappedSubscriber<Failure>(AnySubscriber(subscriber))
        self.wrapped.receive(subscriber: wrappedSubscriber)
    }
}
