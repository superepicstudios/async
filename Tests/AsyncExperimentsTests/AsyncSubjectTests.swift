//
//  AsyncSubjectTests.swift
//  Async
//
//  Created by Mitch Treece on 5/25/25.
//

@testable import Async
import Testing

@Suite
final class AsyncSubjectTests {
    
    // MARK: AsyncReplaySubject
    
    @Test func replay() async {
        
        let sut = AsyncReplaySubject<Int>(2)
        
        Task {
            
            var results = [Int]()
            
            for await e in sut {
                results.append(e)
            }
            
            #expect(results == [1, 2, 3, 4])
            
        }
        
        sut.send(1)
        sut.send(2)
        sut.send(3)
        
        Task {
            
            var results = [Int]()
            
            for await e in sut {
                results.append(e)
            }
            
            #expect(results == [2, 3, 4])
            
        }
        
        sut.send(4)
        sut.send(.finished)
        
    }
    
    @Test func replayZero() async {
        
        let sut = AsyncReplaySubject<Int>(0)
        
        Task {
            
            var results = [Int]()
            
            for await e in sut {
                results.append(e)
            }
            
            #expect(results == [1, 2, 3, 4])
            
        }
        
        sut.send(1)
        sut.send(2)
        sut.send(3)

        Task {
            
            var results = [Int]()
            
            for await e in sut {
                results.append(e)
            }
            
            #expect(results == [4])
            
        }
        
        sut.send(4)
        sut.send(.finished)
        
    }
    
    // MARK: AsyncPassthroughSubject
    
    @Test func passthrough() {
        
        let sut = AsyncPassthroughSubject<Int>()
        
        Task {
            
            var results = [Int]()
            
            for await e in sut {
                results.append(e)
            }
            
            #expect(results == [1, 2, 3, 4])
            
        }
        
        sut.send(1)
        sut.send(2)
        sut.send(3)

        Task {
            
            var results = [Int]()
            
            for await e in sut {
                results.append(e)
            }
            
            #expect(results == [4])
            
        }
        
        sut.send(4)
        sut.send(.finished)
        
    }
    
    // MARK: AsyncCurrentValueSubject
    
    @Test func currentValue() async {
        
        let sut = AsyncCurrentValueSubject<Int>(0)
        
        Task {
            
            var results = [Int]()
            
            for await e in sut {
                results.append(e)
            }
            
            #expect(results == [0, 1, 2])
            
        }
        
        sut.send(1)
        sut.send(2)
        
        Task {
            
            var results = [Int]()
            
            for await e in sut {
                results.append(e)
            }
            
            #expect(results == [2, 3, 4])
            
        }
        
        sut.send(3)
        sut.send(4)
        sut.send(.finished)

    }
    
    // MARK: AsyncSignalSubject
    
    @Test func signal() async {
        
        let sut = AsyncSignalSubject()
        
        Task {
            
            var count: Int = 0
            
            for await _ in sut {
                count += 1
            }
            
            #expect(count == 3)
            
        }
        
        sut.send()
        sut.send()
        sut.send()
        sut.send(.finished)
        
    }
    
}
