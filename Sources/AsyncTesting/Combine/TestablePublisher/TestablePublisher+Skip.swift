//
//  TestablePublisher+Skip.swift
//  AsyncTesting
//
//  Created by Mitch Treece on 1/24/26.
//  Copyright © 2026 Super Epic Studios, LLC.
//

import Foundation

extension TestablePublisher {

    /// Skips to the next expectation.
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
    /// await sut.expect(1).skip().expect(3)
    /// ```
    @discardableResult
    public func skip() async -> Self {
        self.isSkipping = true
        return self
    }
}
