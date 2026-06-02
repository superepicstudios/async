//
//  TestablePublisher+Next.swift
//  AsyncTesting
//
//  Created by Mitch Treece on 1/24/26.
//  Copyright © 2026 Super Epic Studios, LLC.
//

public import Testing

extension TestablePublisher {

    /// Gets the next output value in the publisher's stream.
    /// - parameter location: The caller's source location.
    /// - returns: The next output value.
    ///
    /// ```swift
    /// let subject = CurrentValueSubject<Int, Never>(0)
    /// let sut = subject.testable()
    /// await #expect(sut.next() == 0)
    /// ```
    public func next(location: SourceLocation = #_sourceLocation) async -> Output? {
        switch await self.iterator.next() {
        case .value(let result): return result
        case .timeout: Issue.record("Publisher timeout", sourceLocation: location)
        case .none, .finished: Issue.record("Publisher stream ended", sourceLocation: location)
        case .failure: Issue.record("Unhandled publisher error", sourceLocation: location)
        }

        return nil
    }
}
