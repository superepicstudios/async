//
//  StreamTests.swift
//  AsyncTests
//
//  Created by Mitch Treece on 6/3/26.
//  Copyright © 2026 Super Epic Studios, LLC.
//

@testable import Async
import AsyncTesting
import Foundation
import Testing

@Suite
struct StreamTests {
    
    // MARK: Replay
    
    @Test
    func `replay stream buffers expected count of elements`() async throws {

        let sut = ReplayStream<Int, Never>(buffering: 2)

        sut.send(0) // dropped
        sut.send(1)
        sut.send(2)
        
        let task = sut.sequence { s in
            var results = [Int]()
            for try await e in s {
                results.append(e)
            }
            return results
        }
        
        sut.send(3)
        sut.send(completion: .finished)
  
        let results = try await task.value
        #expect(results == [1, 2, 3])
    }

    @Test
    func `replay stream sends failure`() async {

        let sut = ReplayStream<Int, TestError>(buffering: 0)
        let task = sut.sequence { for try await _ in $0 {}}

        sut.send(completion: .failure(.mock))

        await #expect(throws: TestError.self) {
            try await task.value
        }
    }

    @Test
    func `replay stream replays failure`() async {

        let sut = ReplayStream<Int, TestError>(buffering: 0)

        sut.send(completion: .failure(.mock))

        let task = sut.sequence { for try await _ in $0 {}}

        await #expect(throws: TestError.self) {
            try await task.value
        }
    }

    @Test
    func `replay stream can be erased into any stream or relay`() {

        let sut = ReplayStream<Int, Never>(buffering: 2)
        let stream = sut.eraseToAnyStream()
        let relay = sut.eraseToAnyRelay()

        #expect(type(of: sut) == ReplayStream<Int, Never>.self)
        #expect(type(of: stream) == AnyStream<Int, Never>.self)
        #expect(type(of: relay) == AnyRelay<Int>.self)
    }

    // MARK: Value

    @Test
    func `value stream sends initial element`() async throws {

        let sut = ValueStream<Int, Never>(1)

        let task = sut.sequence { s in
            var results = [Int]()
            for try await e in s {
                results.append(e)
            }
            return results
        }

        sut.send(2)
        sut.send(3)
        sut.send(completion: .finished)

        let results = try await task.value
        #expect(results == [1, 2, 3])
    }

    @Test
    func `value stream sends latest element`() async throws {

        let sut = ValueStream<Int, Never>(0)

        sut.send(1)

        let task = sut.sequence { s in
            var results = [Int]()
            for try await e in s {
                results.append(e)
            }
            return results
        }

        sut.send(2)
        sut.send(3)
        sut.send(completion: .finished)

        let results = try await task.value
        #expect(results == [1, 2, 3])
    }

    @Test
    func `value stream sends failure`() async {

        let sut = ValueStream<Int, TestError>(0)
        let task = sut.sequence { for try await _ in $0 {}}

        sut.send(completion: .failure(.mock))

        await #expect(throws: TestError.self) {
            try await task.value
        }
    }

    @Test
    func `value stream replays failure`() async {

        let sut = ValueStream<Int, TestError>(0)

        sut.send(completion: .failure(.mock))

        let task = sut.sequence { for try await _ in $0 {}}

        await #expect(throws: TestError.self) {
            try await task.value
        }
    }

    @Test
    func `value stream can be erased into any stream or relay`() {

        let sut = ValueStream<Int, Never>(0)
        let stream = sut.eraseToAnyStream()
        let relay = sut.eraseToAnyRelay()

        #expect(type(of: sut) == ValueStream<Int, Never>.self)
        #expect(type(of: stream) == AnyStream<Int, Never>.self)
        #expect(type(of: relay) == AnyRelay<Int>.self)
    }

    // MARK: Passthrough

    @Test
    func `passthrough stream only sends elements after consumption`() async throws {

        let sut = PassthroughStream<Int, Never>()
        
        sut.send(0) // dropped

        let task = sut.sequence { s in
            var results = [Int]()
            for try await e in s {
                results.append(e)
            }
            return results
        }
        
        sut.send(1)
        sut.send(2)
        sut.send(3)
        sut.send(completion: .finished)
  
        let results = try await task.value
        #expect(results == [1, 2, 3])
    }

    @Test
    func `passthrough stream sends failure`() async {

        let sut = PassthroughStream<Int, TestError>()
        let task = sut.sequence { for try await _ in $0 {}}

        sut.send(completion: .failure(.mock))

        await #expect(throws: TestError.self) {
            try await task.value
        }
    }

    @Test
    func `passthrough stream replays failure`() async {

        let sut = PassthroughStream<Int, TestError>()

        sut.send(completion: .failure(.mock))

        let task = sut.sequence { for try await _ in $0 {}}

        await #expect(throws: TestError.self) {
            try await task.value
        }
    }

    @Test
    func `passthrough stream can be erased into any stream or relay`() {

        let sut = PassthroughStream<Int, Never>()
        let stream = sut.eraseToAnyStream()
        let relay = sut.eraseToAnyRelay()

        #expect(type(of: sut) == PassthroughStream<Int, Never>.self)
        #expect(type(of: stream) == AnyStream<Int, Never>.self)
        #expect(type(of: relay) == AnyRelay<Int>.self)
    }

    // MARK: Signal

    @Test
    func `signal stream only sends signals after consumption`() async throws {

        let sut = SignalStream<Never>()

        sut.send() // dropped

        let task = sut.sequence { s in
            var signalCount: Int = 0
            for try await _ in s {
                signalCount += 1
            }
            return signalCount
        }

        sut.send()
        sut.send(completion: .finished)

        let result = try await task.value
        #expect(result == 1)
    }

    @Test
    func `signal stream sends failure`() async {

        let sut = SignalStream<TestError>()
        let task = sut.sequence { for try await _ in $0 {}}

        sut.send(completion: .failure(.mock))

        await #expect(throws: TestError.self) {
            try await task.value
        }
    }

    @Test
    func `signal stream replays failure`() async {

        let sut = SignalStream<TestError>()

        sut.send(completion: .failure(.mock))

        let task = sut.sequence { for try await _ in $0 {}}

        await #expect(throws: TestError.self) {
            try await task.value
        }
    }

    @Test
    func `signal stream can be erased into any stream or relay`() {

        let sut = SignalStream<Never>()
        let stream = sut.eraseToAnyStream()
        let relay = sut.eraseToAnyRelay()

        #expect(type(of: sut) == SignalStream<Never>.self)
        #expect(type(of: stream) == AnyStream<Void, Never>.self)
        #expect(type(of: relay) == AnyRelay<Void>.self)
    }

    // MARK: Just

    @Test
    func `just stream sends initial element and finishes`() async {

        let sut = JustStream<Int>(1)

        let task = sut.sequence { s in
            var results = [Int]()
            for await e in s {
                results.append(e)
            }
            return results
        }

        let results = await task.value
        #expect(results == [1])
    }

    @Test
    func `just stream can be erased into any stream or relay`() {

        let sut = JustStream<Int>(0)
        let stream = sut.eraseToAnyStream()
        let relay = sut.eraseToAnyRelay()

        #expect(type(of: sut) == JustStream<Int>.self)
        #expect(type(of: stream) == AnyStream<Int, Never>.self)
        #expect(type(of: relay) == AnyRelay<Int>.self)
    }

    // MARK: Empty

    @Test
    func `empty stream sends no elements and finishes immediately`() async {

        let sut = EmptyStream()

        let task = sut.sequence { s in
            var received: Bool = false
            for await _ in s {
                received = true
            }
            return received
        }

        let receivedElement = await task.value
        #expect(!receivedElement)
    }

    @Test
    func `empty stream can be erased into any stream or relay`() {

        let sut = EmptyStream()
        let stream = sut.eraseToAnyStream()
        let relay = sut.eraseToAnyRelay()

        #expect(type(of: sut) == EmptyStream.self)
        #expect(type(of: stream) == AnyStream<Void, Never>.self)
        #expect(type(of: relay) == AnyRelay<Void>.self)
    }

    // MARK: Driver

    @Test
    func `driver sends initial element`() async {

        let sut = Driver<Int>(1)

        let task = sut.sequenceOnMain { s in
            var results = [Int]()
            for await e in s {
                results.append(e)
            }
            return results
        }

        sut.send(2)
        sut.send(3)
        sut.send(completion: .finished)

        let results = await task.value
        #expect(results == [1, 2, 3])
    }

    @Test
    func `driver sends latest element`() async {

        let sut = Driver<Int>(0)

        sut.send(1)

        let task = sut.sequenceOnMain { s in
            var results = [Int]()
            for await e in s {
                results.append(e)
            }
            return results
        }

        sut.send(2)
        sut.send(3)
        sut.send(completion: .finished)

        let results = await task.value
        #expect(results == [1, 2, 3])
    }

    @Test
    func `driver delivers elements on the main-actor`() async {

        let sut = Driver<Int>(1)
        let publisher = sut.makePublisher()
        let testablePublisher = publisher.testable()

        sut.sequenceOnMain {
            for await _ in $0 {}
        }

        sut.observeOnMain { _ in
            MainActor.assertIsolated()
        }

        let _ = publisher.sink { _ in
            assert(Thread.current.isMainThread)
        }

        sut.send(2)
        sut.send(3)
        sut.send(completion: .finished)

        await testablePublisher.expect([1, 2, 3])
    }

    @Test
    func `driver can be erased into any stream, relay, or driver`() {

        let sut = Driver<Int>(0)
        let stream = sut.eraseToAnyStream()
        let relay = sut.eraseToAnyRelay()
        let driver = sut.eraseToAnyDriver()

        #expect(type(of: sut) == Driver<Int>.self)
        #expect(type(of: stream) == AnyStream<Int, Never>.self)
        #expect(type(of: relay) == AnyRelay<Int>.self)
        #expect(type(of: driver) == AnyDriver<Int>.self)
    }
}
