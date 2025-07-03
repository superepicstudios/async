//
//  CombinePublisherTests.swift
//  Async
//
//  Created by Mitch Treece on 5/18/25.
//

@testable import Async
import Foundation
import Testing

fileprivate class Object {
    
    let id: String
    weak var ref: Object?

    init(id: String = UUID().uuidString) {
        self.id = id
    }
    
}

@Suite
final class CombinePublisherTests {
    
    private var object: Object
    private var bag: CancellableBag
    
    init() {
        
        self.object = .init()
        self.bag = .init()
        
    }
    
    // MARK: Tap
    
    @Test
    func testTap() throws {
        
        let sut = CurrentValueSubject<Int, Never>(0)
        
        #expect(try sut.tap() == 0)
        sut.send(42)
        #expect(try sut.tap() == 42)
        
    }
    
    @Test
    func testTapPassthroughThrows() {
        
        let sut = PassthroughSubject<Int, Never>()
        
        #expect(
            throws: PublisherError.emptyOutput,
            performing: { try sut.tap() }
        )

    }
    
    @Test
    func testTapOr() {
        
        let sut = PassthroughSubject<Int, Never>()
        #expect(try sut.tap(or: 42) == 42)
        
    }
    
    // MARK: Recieve
    
    @Test
    func testReceiveOnMainQueue() async throws {
                
        let sut = PassthroughSubject<Int, Never>()
        
        try await confirmation { c in
            
            sut
                .receiveOnMainQueue()
                .filter { _ in Thread.current.isMainThread }
                .sink { _ in c.confirm() }
                .store(in: &self.bag)
            
            sut.send(42)
            
            try await Task.sleep(
                for: .seconds(0.3)
            )
            
        }
        
    }
    
    @Test
    func testReceiveOnMainLoop() async throws {
                
        let sut = PassthroughSubject<Int, Never>()
        
        try await confirmation { c in
            
            sut
                .receiveOnMainLoop()
                .filter { _ in Thread.current.isMainThread }
                .sink { _ in c.confirm() }
                .store(in: &self.bag)
            
            sut.send(42)
            
            try await Task.sleep(
                for: .seconds(0.3)
            )
            
        }
        
    }
    
    // MARK: Weak
    
    @Test
    func testWeakSink() async throws {
        
        let sut = PassthroughSubject<Int, Never>()
        
        autoreleasepool {
            
            let ref = Object()
            self.object.ref = ref
            #expect(self.object.ref != nil)
            
        }
        
        await confirmation { c in
            
            sut
                .weakSink(capturing: self.object) { wObject, value in
                    
                    #expect(wObject != nil)
                    #expect(wObject!.ref == nil)
                    c.confirm()
                    
                }
                .store(in: &self.bag)
            
            sut.send(42)
            
        }
        
    }
    
    // MARK: Guard
    
    @Test
    func testGuardPasses() async {
        
        let sut = PassthroughSubject<Int?, Never>()
        
        await confirmation { c in
            
            sut
                .guard()
                .sink { _ in c.confirm() }
                .store(in: &self.bag)
            
            sut.send(42)
            
        }
        
    }
    
    @Test
    func testGuardFails() async throws {
        
        let sut = PassthroughSubject<Int?, Never>()
        var flag: Bool = false
        
        try await confirmation { c in
            
            sut
                .guard()
                .sink { _ in flag = true }
                .store(in: &self.bag)
            
            sut.send(nil)
            
            try await Task.sleep(
                for: .seconds(0.1)
            )
            
            c.confirm()
            
        }
        
        #expect(!flag)
        
    }
    
    // MARK: Equals
    
    @Test
    func testEqualPasses() async {
        
        let sut = PassthroughSubject<Int, Never>()

        await confirmation { c in
            
            sut
                .equals(42)
                .sink { _ in c.confirm() }
                .store(in: &self.bag)
            
            sut.send(42)
            
        }
        
    }
    
    @Test
    func testEqualFails() async throws {
        
        let sut = PassthroughSubject<Int, Never>()
        var flag: Bool = false

        try await confirmation { c in
            
            sut
                .equals(43)
                .sink { _ in flag = true }
                .store(in: &self.bag)
            
            sut.send(42)
            
            try await Task.sleep(
                for: .seconds(0.1)
            )
            
            c.confirm()
            
        }
        
        #expect(!flag)
        
    }
    
    @Test
    func testNotEqualPasses() async {
        
        let sut = PassthroughSubject<Int, Never>()

        await confirmation { c in
            
            sut
                .notEquals(43)
                .sink { _ in c.confirm() }
                .store(in: &self.bag)
            
            sut.send(42)
            
        }
        
    }
    
    @Test
    func testNotEqualFails() async throws {
        
        let sut = PassthroughSubject<Int, Never>()
        var flag: Bool = false

        try await confirmation { c in
            
            sut
                .notEquals(42)
                .sink { _ in flag = true }
                .store(in: &self.bag)
            
            sut.send(42)
            
            try await Task.sleep(
                for: .seconds(0.1)
            )
            
            c.confirm()
            
        }
        
        #expect(!flag)
        
    }
    
    // MARK: Bool
    
    @Test
    func testIsTruePasses() async {
        
        let sut = PassthroughSubject<Bool, Never>()

        await confirmation { c in
            
            sut
                .isTrue()
                .sink { _ in c.confirm() }
                .store(in: &self.bag)
            
            sut.send(true)
            
        }
        
    }
    
    @Test
    func testIsTrueFails() async throws {
        
        let sut = PassthroughSubject<Bool, Never>()
        var flag: Bool = false

        try await confirmation { c in
            
            sut
                .isTrue()
                .sink { _ in flag = true }
                .store(in: &self.bag)
            
            sut.send(false)
            
            try await Task.sleep(
                for: .seconds(0.1)
            )
            
            c.confirm()
            
        }
        
        #expect(!flag)
        
    }
    
    @Test
    func testIsFalsePasses() async {
        
        let sut = PassthroughSubject<Bool, Never>()

        await confirmation { c in
            
            sut
                .isFalse()
                .sink { _ in c.confirm() }
                .store(in: &self.bag)
            
            sut.send(false)
            
        }
        
    }
    
    @Test
    func testIsFalseFails() async throws {
        
        let sut = PassthroughSubject<Bool, Never>()
        var flag: Bool = false

        try await confirmation { c in
            
            sut
                .isFalse()
                .sink { _ in flag = true }
                .store(in: &self.bag)
            
            sut.send(true)
            
            try await Task.sleep(
                for: .seconds(0.1)
            )
            
            c.confirm()
            
        }
        
        #expect(!flag)
        
    }
    
}
