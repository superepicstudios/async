//
//  AsyncBufferedChannelTests.swift
//  Async
//
//  Created by Mitch Treece on 5/26/25.
//

@testable import Async
import Testing

fileprivate enum MockError: Error {
    case mock
}

@Suite
final class AsyncBufferedChannelTests {
    
    // MARK: AsyncBufferedChannel
    
    /// Single consumer should receive all elements.
    @Test func singleConsumer() async {
                
        let sut = AsyncBufferedChannel<Int>()
        
        Task {

            var results = [Int]()
            
            for await e in sut {
                results.append(e)
            }
            
            #expect(results == [1, 2])
            
        }
        
        sut.send(1)
        sut.send(2)
        sut.send(.finished)
        
    }
    
    /// Multiple consumers should have elements spread
    /// amongst them (i.e. not shared / multicast).
    @Test func multipleConsumers() {
        
        let sut = AsyncBufferedChannel<Int>()
        
        Task {

            var results = [Int]()
            
            for await e in sut {
                results.append(e)
            }
            
            #expect(results.count == 1)
            
        }
        
        Task {

            var results = [Int]()
            
            for await e in sut {
                results.append(e)
            }
            
            #expect(results.count == 1)
            
        }
        
        sut.send(1)
        sut.send(2)
        sut.send(.finished)
        
    }
    
    // MARK: AsyncThrowingBufferedChannel
    
    /// Single consumer should receive all (throwing) elements.
    @Test func singleConsumerThrowing() {
                
        let sut = AsyncThrowingBufferedChannel<Int, MockError>()
        
        Task {

            var results = [Int]()
            
            for try await e in sut {
                results.append(e)
            }
            
            #expect(results == [1, 2])
            
        }
        
        sut.send(1)
        sut.send(2)
        sut.send(.finished)
        
    }
    
    /// Single consumer should receive one element, and a thrown error.
    @Test func singleConsumerThrowingThrows() {
                
        let sut = AsyncThrowingBufferedChannel<Int, MockError>()
        
        Task {

            var results = [Int]()
            var caught: (any Error)?
            
            do {
                for try await e in sut {
                    results.append(e)
                }
            }
            catch {
                caught = error
            }
            
            #expect(results == [1, 2])
            #expect(caught != nil)
            #expect(type(of: caught!) == MockError.self)
            #expect((caught! as! MockError) == .mock)
            
        }
        
        sut.send(1)
        sut.send(2)
        sut.send(.failure(.mock))
        
    }
    
    /// Multiple consumers should have (throwing) elements
    /// spread amongst them (i.e. not shared / multicast).
    @Test func multipleConsumersThrowing() {
        
        let sut = AsyncThrowingBufferedChannel<Int, MockError>()
        
        Task {

            var results = [Int]()
            
            for try await e in sut {
                results.append(e)
            }
            
            #expect(results.count == 1)
            
        }
        
        Task {

            var results = [Int]()
            
            for try await e in sut {
                results.append(e)
            }
            
            #expect(results.count == 1)
            
        }
        
        sut.send(1)
        sut.send(2)
        sut.send(.failure(.mock))
        
    }
    
    /// Multiple consumers should receive one element, and a thrown error.
    @Test func multipleConsumersThrowingThrows() {
        
        let sut = AsyncThrowingBufferedChannel<Int, MockError>()
        
        Task {

            var results = [Int]()
            var caught: (any Error)?
            
            do {
                for try await e in sut {
                    results.append(e)
                }
            }
            catch {
                caught = error
            }
            
            #expect(results.count == 1)
            #expect(caught != nil)
            #expect(type(of: caught!) == MockError.self)
            #expect((caught! as! MockError) == .mock)
            
        }
        
        Task {

            var results = [Int]()
            var caught: (any Error)?
            
            do {
                for try await e in sut {
                    results.append(e)
                }
            }
            catch {
                caught = error
            }
            
            #expect(results.count == 1)
            #expect(caught != nil)
            #expect(type(of: caught!) == MockError.self)
            #expect((caught! as! MockError) == .mock)
            
        }
        
        sut.send(1)
        sut.send(2)
        sut.send(.failure(.mock))
        
    }
    
}
