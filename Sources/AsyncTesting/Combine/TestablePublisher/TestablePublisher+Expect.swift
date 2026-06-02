//
//  TestablePublisher+Expect.swift
//  AsyncTesting
//
//  Created by Mitch Treece on 1/24/26.
//  Copyright © 2026 Super Epic Studios, LLC.
//

public import Testing

// MARK: Values

extension TestablePublisher where Output: Equatable {

    /// Creates an expectation for a set of values in the publisher's output stream.
    /// - parameter values: The values to expect.
    /// - parameter location: The caller's source location.
    /// - returns: The testable publisher.
    ///
    /// ```swift
    /// let subject = PassthroughSubject<Int, Never>()
    /// let sut = subject.testable()
    ///
    /// subject.send(1)
    /// subject.send(2)
    /// subject.send(3)
    ///
    /// await sut.expect([1, 2, 3])
    /// ```
    @discardableResult
    public func expect(
        _ values: [Output],
        location: SourceLocation = #_sourceLocation
    ) async -> Self {

        var collectedValues = [Output]()

        for _ in 0..<values.count {
            if let value = await next(location: location) {
                collectedValues.append(value)
            }
        }

        if self.isSkipping {
            if collectedValues != values {
                while let value = await next(location: location) {
                    collectedValues.append(value)
                    if collectedValues.contains(values) {
                        break
                    }
                }
            }

            #expect(
                collectedValues.contains(values),
                sourceLocation: location
            )
        } else {
            #expect(
                collectedValues == values,
                sourceLocation: location
            )
        }

        self.isSkipping = false
        return self
    }

    /// Creates an expectation for a set of values in the publisher's output stream.
    /// - parameter values: The values to expect.
    /// - parameter location: The caller's source location.
    /// - returns: The testable publisher.
    ///
    /// ```swift
    /// let subject = PassthroughSubject<Int, Never>()
    /// let sut = subject.testable()
    ///
    /// subject.send(1)
    /// subject.send(2)
    /// subject.send(3)
    ///
    /// await sut.expect(1, 2, 3)
    /// ```
    @discardableResult
    public func expect(
        _ values: Output...,
        location: SourceLocation = #_sourceLocation
    ) async -> Self {
        await expect(
            values,
            location: location
        )
    }

    /// Creates an expectation for a number of value occurrences in the publisher's output stream.
    /// - parameter value: The value to expect.
    /// - parameter count: The number of times to expect the value.
    /// - parameter location: The caller's source location.
    /// - returns: The testable publisher.
    ///
    /// ```swift
    /// let subject = PassthroughSubject<Int, Never>()
    /// let sut = subject.testable()
    ///
    /// subject.send(1)
    /// subject.send(2)
    /// subject.send(2)
    ///
    /// await sut.expect(1).expect(2, count: 2)
    /// ```
    @discardableResult
    public func expect(
        _ value: Output,
        count: Int,
        location: SourceLocation = #_sourceLocation
    ) async -> Self {

        let values: [Output] = .init(
            repeating: value,
            count: count
        )

        return await expect(
            values,
            location: location
        )
    }
}

// MARK: Finished

extension TestablePublisher {

    /// Creates an expectation for a finished completion in the publisher's output stream.
    /// - parameter location: The caller's source location.
    ///
    /// ```swift
    /// let subject = PassthroughSubject<Int, Never>()
    /// let sut = subject.testable()
    ///
    /// subject.send(1)
    /// subject.send(2)
    /// subject.send(3)
    /// subject.send(completion: .finished)
    ///
    /// await sut.expect(1, 2, 3).expectFinished()
    /// ```
    public func expectFinished(location: SourceLocation = #_sourceLocation) async {

        var output: PublisherOutput?

        if self.isSkipping {
            while let value = await self.iterator.next() {
                output = value

                if value.isFinished {
                    break
                }
            }
        } else {
            output = await self.iterator.next()
        }

        self.isSkipping = false

        #expect(
            output?.isFinished == true,
            sourceLocation: location
        )
    }
}

// MARK: Failure

extension TestablePublisher where Failure: Error {

    /// Creates an expectation for a failed completion in the publisher's output stream.
    /// - parameter location: The caller's source location.
    ///
    /// ```swift
    /// let subject = CurrentValueSubject<Int, Never>(0)
    /// let sut = subject.testable()
    ///
    /// subject.send(1)
    /// subject.send(2)
    /// subject.send(3)
    ///
    /// await sut.expect(1, 2).expectFailure()
    /// ```
    public func expectFailure( location: SourceLocation = #_sourceLocation) async throws {

        var output: PublisherOutput?

        if self.isSkipping {
            while let value = await self.iterator.next() {
                output = value

                switch value {
                case .failure: break
                default: continue
                }
            }
        } else {
            output = await self.iterator.next()
        }

        self.isSkipping = false

        switch output {
        case .failure(let error): throw error
        default: Issue.record("Expected failure never received", sourceLocation: location)
        }
    }
}

// MARK: Invocations

extension TestablePublisher {

    /// Creates an expectation for a number of publisher stream invocations.
    /// - parameter count: The number of invocations to expect.
    /// - parameter location: The caller's source location.
    /// - returns: The testable publisher.
    ///
    /// ```swift
    /// let subject = PassthroughSubject<Int, Never>()
    /// let sut = subject.testable()
    ///
    /// subject.send(1)
    /// subject.send(2)
    /// subject.send(3)
    ///
    /// await sut.expectInvocations(3)
    /// ```
    @discardableResult
    public func expectInvocations(
        _ count: Int = 1,
        location: SourceLocation = #_sourceLocation
    ) async -> Self {

        var counter = 0

        for _ in 0..<count {
            if await next(location: location) != nil {
                counter += 1
            }
        }

        #expect(
            counter == count,
            sourceLocation: location
        )

        return self
    }
}

// MARK: Condition

extension TestablePublisher {

    /// Creates an expectation of a condition, given an output in the publisher stream.
    /// - parameter condition: The condition to evaluate.
    /// - parameter location: The caller's source location.
    /// - returns: The testable publisher.
    ///
    /// ```swift
    /// let subject = CurrentValueSubject<Int, Never>(0)
    /// let sut = subject.testable()
    ///
    /// subject.send(1)
    /// subject.send(2)
    /// subject.send(3)
    ///
    /// await sut.expect(0).expect { $0! >= 1 }
    /// ```
    @discardableResult
    public func expectCondition(
        _ condition: (Output?) -> Bool,
        location: SourceLocation = #_sourceLocation
    ) async -> Self {

        var output: Output?

        if let value = await next(location: location) {
            output = value
        }

        if self.isSkipping {
            if !condition(output) {
                while let value = await next(location: location) {
                    output = value

                    if condition(output) {
                        break
                    }
                }
            }
        }

        self.isSkipping = false

        #expect(
            condition(output),
            sourceLocation: location
        )

        return self
    }
}
