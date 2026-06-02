//
//  TestablePublisher.swift
//  AsyncTesting
//
//  Created by Mitch Treece on 1/24/26.
//  Copyright © 2026 Super Epic Studios, LLC.
//

@preconcurrency public import Combine
public import Foundation

/// Wraps a publisher, and exposes testing functions & helpers.
///
/// - [Stack Overflow](https://stackoverflow.com/questions/76273105/collecting-publisher-values-with-async/78506360#78506360)
/// - [AsyncRecorder](https://github.com/StatusQuo/AsyncRecorder)
public final class TestablePublisher<Output, Failure> where Output: Sendable, Failure: Sendable {

    enum PublisherOutput: Sendable {

        case value(Output)
        case timeout
        case finished
        case failure(Failure)

        var isFinished: Bool {
            switch self {
            case .finished: true
            default: false
            }
        }
    }

    enum PublisherError: Error {
        case timeout
        case failure(Failure)
    }

    private let timeout: RunLoop.SchedulerTimeType.Stride
    private var stream: AsyncStream<PublisherOutput>!
    private var subscription: AnyCancellable!
    
    var iterator: AsyncStream<PublisherOutput>.Iterator!
    var isSkipping: Bool = false

    init(
        _ publisher: any Publisher<Output, Failure>,
        timeout: RunLoop.SchedulerTimeType.Stride
    ) where Failure: Error {

        self.timeout = timeout

        let wrappedPublisher = publisher
            .eraseToAnyPublisher()
            .mapError { PublisherError.failure($0) }
            .timeout(self.timeout, scheduler: RunLoop.main) { PublisherError.timeout }
            .buffer(size: .max, prefetch: .byRequest, whenFull: .dropOldest)
            .eraseToAnyPublisher()

        subscribe(wrappedPublisher)
    }

    // MARK: Private

    private func subscribe(_ publisher: AnyPublisher<Output, PublisherError>) {

        var handler: ((Output) -> Void)!
        var completion: ((PublisherError?) -> Void)!

        self.stream = AsyncStream { continuation in

            handler = { value in
                continuation.yield(PublisherOutput.value(value))
            }

            completion = { error in

                if let error {
                    switch error {
                    case .timeout: continuation.yield(.timeout)
                    case .failure(let error): continuation.yield(.failure(error))
                    }
                } else {
                    continuation.yield(.finished)
                }

                continuation.finish()
                self.subscription = nil
            }
        }

        self.subscription = publisher.sink { result in
            switch result {
            case .finished: completion(nil)
            case .failure(let error): completion(error)
            }

            self.subscription = nil
        } receiveValue: { value in
            handler(value)
        }

        self.iterator = self.stream.makeAsyncIterator()
    }
}

// MARK: Publisher + Testable

extension Publisher {
    
    /// Wraps and returns a testable publisher.
    /// - parameter timeout: The testable publisher's timeout interval.
    /// - returns: A testable publisher.
    public func testable(
        timeout: RunLoop.SchedulerTimeType.Stride = .seconds(1)
    ) -> TestablePublisher<Output, Failure> where Output: Sendable, Failure: Sendable {
        .init(
            self,
            timeout: timeout
        )
    }
}
