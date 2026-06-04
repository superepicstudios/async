//
//  StreamTests.swift
//  AsyncTests
//
//  Created by Mitch Treece on 6/3/26.
//  Copyright © 2026 Super Epic Studios, LLC.
//

@testable import Async
import Foundation
import Testing

@Suite
struct StreamTests {
    
    // MARK: ReplayStream
    
    enum TestError: Error {
        case mock
    }
    
    @Test
    func `replay stream replays elements`() async throws {
        
        let sut = ReplayStream<Int, Never>(buffering: 2)
        
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
    func `replay stream drops oldest elements outside its buffer`() async throws {
        
        let sut = ReplayStream<Int, Never>(buffering: 2)
        
        sut.send(0)
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
    
    // MARK: PassthroughStream

    @Test
    func `passthrough stream drops values when there are no consumers`() async throws {
        
        let sut = PassthroughStream<Int, Never>()
        
        sut.send(0) // Dropped (no consumers)
        
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
    
    // MARK: ValueStream
    
    @Test
    func `value stream buffers initial element`() async throws {
        
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
    
    // MARK: Driver
    
    @Test
    func `driver buffers initial element`() async {
        
        let sut = Driver<Int>(1)
        
        let task = sut.sequenceOnMain { s in
            MainActor.assertIsolated()
            
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
}
