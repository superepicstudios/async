//
//  TestablePublisherTests.swift
//  AsyncTesting
//
//  Created by Mitch Treece on 1/24/26.
//  Copyright © 2026 Super Epic Studios, LLC.
//

@testable import AsyncTesting
@preconcurrency import Combine
import Testing

@Suite
struct TestablePublisherTests {

    private let currentValue = CurrentValueSubject<Int, Never>(0)
    private let passthrough = PassthroughSubject<Int, Never>()

    // MARK: Next

    @Test
    func `next returns expected value`() async {
        let sut = self.currentValue.testable()

        self.currentValue.send(1)
        self.currentValue.send(2)
        self.currentValue.send(3)

        await #expect(sut.next() == 0)
    }

    // MARK: Expect

    @Test
    func `expect validates single expectation`() async {
        let sut = self.currentValue.testable()

        self.currentValue.send(1)
        self.currentValue.send(2)
        self.currentValue.send(3)

        await sut.expect(0, 1, 2, 3)
    }

    @Test
    func `expect validates multiple expectations`() async {
        let sut = self.currentValue.testable()

        self.currentValue.send(1)
        self.currentValue.send(2)
        self.currentValue.send(3)

        await sut
            .expect(0, 1)
            .expect(2, 3)
    }

    @Test
    func `expect fails on unexpected element`() async {
        await withKnownIssue {
            let sut = self.currentValue.testable()

            self.currentValue.send(1)
            self.currentValue.send(2)
            self.currentValue.send(3)

            await sut.expect(0, 1, 2, 3, 4)
        }
    }

    @Test
    func `expectFinished fails when not finished`() async {
        await withKnownIssue {
            let sut = self.currentValue.testable()

            self.currentValue.send(1)
            self.currentValue.send(2)
            self.currentValue.send(3)

            await sut
                .expect(0, 1, 2)
                .expectFinished()
        }
    }

    @Test
    func `expectFailure fails when not failed`() async throws {
        await withKnownIssue {
            let sut = self.currentValue.testable()

            self.currentValue.send(1)
            self.currentValue.send(2)
            self.currentValue.send(3)

            try await sut
                .expect(0, 1, 2)
                .expectFailure()
        }
    }

    @Test
    func `expect(_:count:) validates expectation counts`() async {
        let sut = self.currentValue.testable()

        self.currentValue.send(1)
        self.currentValue.send(2)
        self.currentValue.send(2)
        self.currentValue.send(3)
        self.currentValue.send(3)
        self.currentValue.send(3)

        await sut
            .expect(0)
            .expect(1, count: 1)
            .expect(2, count: 2)
            .expect(3, count: 3)
    }

    @Test
    func `expect(_:count:) fails on mismatched count`() async {
        await withKnownIssue {
            let sut = self.currentValue.testable()

            self.currentValue.send(1)

            await sut
                .expect(0)
                .expect(1, count: 2)
        }
    }

    @Test
    func `expectCondition validates expected condition`() async {
        let sut = self.currentValue.testable()

        self.currentValue.send(1)
        self.currentValue.send(2)
        self.currentValue.send(3)

        await sut
            .expect(0)
            .expectCondition { $0! > 0 }
    }

    // MARK: Skip

    @Test
    func `skip ignores element`() async {
        let sut = self.currentValue.testable()

        self.currentValue.send(1)
        self.currentValue.send(2)
        self.currentValue.send(3)

        await sut
            .expect(0, 1)
            .skip() // 2
            .expect(3)
    }

    @Test
    func `skip ignores multiple elements`() async {
        let sut = self.currentValue.testable()

        self.currentValue.send(1)
        self.currentValue.send(2)
        self.currentValue.send(2)
        self.currentValue.send(3)
        self.currentValue.send(3)
        self.currentValue.send(3)

        await sut
            .expect(0)
            .expect(1)
            .skip() // 2
            .skip() // 2
            .expect(3, count: 3)
    }
}
