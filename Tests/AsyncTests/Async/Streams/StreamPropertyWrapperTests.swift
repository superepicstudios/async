//
//  StreamPropertyWrapperTests.swift
//  AsyncTests
//
//  Created by Mitch Treece on 6/3/26.
//  Copyright © 2026 Super Epic Studios, LLC.
//

@testable import Async
import Foundation
import Testing

@Suite
struct StreamPropertyWrapperTests {

    // MARK: @Streamed

    @Test
    func `@Streamed`() async throws {

        @Streamed var sut = 1
        #expect(type(of: $sut) == AnyStream<Int, Never>.self)

        let task = $sut.sequence { s in
            var results = [Int]()
            for try await e in s {
                results.append(e)
                if results == [1, 2, 3] {
                    break
                }
            }
            return results
        }

        sut = 2
        sut = 3

        let results = try await task.value
        #expect(results == [1, 2, 3])
    }

    // MARK: @Stream

    @Test
    func `@Stream`() async throws {

        @Async.Stream<Int, Never>(1) var sut
        #expect(type(of: sut) == AnyStream<Int, Never>.self)
        #expect(type(of: $sut) == ValueStream<Int, Never>.self)

        let task = sut.sequence { s in
            var results = [Int]()
            for try await e in s {
                results.append(e)
            }
            return results
        }

        $sut.send(2)
        $sut.send(3)
        $sut.send(completion: .finished)

        let results = try await task.value
        #expect(results == [1, 2, 3])
    }

    // MARK: @Relay

    @Test
    func `@Relay`() async {

        @Relay<Int>(1) var sut
        #expect(type(of: sut) == AnyRelay<Int>.self)
        #expect(type(of: $sut) == ValueStream<Int, Never>.self)

        let task = sut.sequence { s in
            var results = [Int]()
            for await e in s {
                results.append(e)
            }
            return results
        }

        $sut.send(2)
        $sut.send(3)
        $sut.send(completion: .finished)

        let results = await task.value
        #expect(results == [1, 2, 3])
    }

    // MARK: @Passthrough

    @Test
    func `@Passthrough`() async throws {

        @Passthrough<Int, Never> var sut
        #expect(type(of: sut) == AnyStream<Int, Never>.self)
        #expect(type(of: $sut) == PassthroughStream<Int, Never>.self)

        let task = sut.sequence { s in
            var results = [Int]()
            for try await e in s {
                results.append(e)
            }
            return results
        }

        $sut.send(1)
        $sut.send(2)
        $sut.send(3)
        $sut.send(completion: .finished)

        let results = try await task.value
        #expect(results == [1, 2, 3])
    }

    // MARK: @PassthroughRelay

    @Test
    func `@PassthroughRelay`() async {

        @PassthroughRelay<Int> var sut
        #expect(type(of: sut) == AnyRelay<Int>.self)
        #expect(type(of: $sut) == PassthroughStream<Int, Never>.self)

        let task = sut.sequence { s in
            var results = [Int]()
            for await e in s {
                results.append(e)
            }
            return results
        }

        $sut.send(1)
        $sut.send(2)
        $sut.send(3)
        $sut.send(completion: .finished)

        let results = await task.value
        #expect(results == [1, 2, 3])
    }

    // MARK: @Signal

    @Test
    func `@Signal`() async throws {

        @Signal<Never> var sut
        #expect(type(of: sut) == AnyStream<Void, Never>.self)
        #expect(type(of: $sut) == SignalStream<Never>.self)

        let task = sut.sequence { s in
            var signalCount: Int = 0
            for try await _ in s {
                signalCount += 1
            }
            return signalCount
        }

        $sut.send()
        $sut.send(completion: .finished)

        let signalCount = try await task.value
        #expect(signalCount == 1)
    }

    // MARK: @SignalRelay

    @Test
    func `@SignalRelay`() async {

        @SignalRelay var sut
        #expect(type(of: sut) == AnyRelay<Void>.self)
        #expect(type(of: $sut) == SignalStream<Never>.self)

        let task = sut.sequence { s in
            var signalCount: Int = 0
            for await _ in s {
                signalCount += 1
            }
            return signalCount
        }

        $sut.send()
        $sut.send(completion: .finished)

        let signalCount = await task.value
        #expect(signalCount == 1)
    }

    // MARK: @Drive

    @Test
    func `@Drive`() async {

        @Drive<Int>(1) var sut
        #expect(type(of: sut) == AnyDriver<Int>.self)
        #expect(type(of: $sut) == Driver<Int>.self)

        let task = sut.sequenceOnMain { s in
            var results = [Int]()
            for await e in s {
                results.append(e)
            }
            return results
        }

        $sut.send(2)
        $sut.send(3)
        $sut.send(completion: .finished)

        let results = await task.value
        #expect(results == [1, 2, 3])
    }

    // MARK: @Pipe

    @Test
    func `@Pipe`() async {

        @Async.Pipe<Int> var sut = 0
        #expect(type(of: $sut) == Pipe<Int>.self)

        let stream = ValueStream<Int, Never>(1)
                
        $sut.connect(to: stream)
        #expect(sut == 1)

        stream.send(2)
        #expect(sut == 2)

        stream.send(3)
        #expect(sut == 3)
    }
}
