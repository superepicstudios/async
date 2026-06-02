//
//  CombinePublisherTests.swift
//  AsyncTests
//
//  Created by Mitch Treece on 5/18/25.
//  Copyright © 2025 Super Epic Studios, LLC.
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
    private var cancellables: CancellableSet
    
    init() {
        self.object = .init()
        self.cancellables = .init()
    }
    
    // MARK: Tap
    
    @Test
    func `tap gets expected values`() throws {
        let sut = GuaranteeCurrentValueSubject<Int>(0)
        #expect(try sut.tap() == 0)
        sut.send(1)
        #expect(try sut.tap() == 1)
    }
    
    @Test
    func `tap throws empty output error when buffer is empty`() {
        let sut = GuaranteePassthroughSubject<Int>()
        
        #expect(
            throws: PublisherError.emptyOutput,
            performing: {
                try sut.tap()
            }
        )
    }
    
    @Test
    func `tap(or:) returns expected values`() {
        let sut1 = GuaranteeCurrentValueSubject<Int>(0)
        #expect(try sut1.tap(or: 1) == 0)
        
        let sut2 = GuaranteePassthroughSubject<Int>()
        #expect(try sut2.tap(or: 1) == 1)
    }
    
    // MARK: Recieve
    
    @Test
    func `receiveOnMainQueue executes on expected thread`() async throws {
        let sut = GuaranteePassthroughSubject<Int>()
        
        try await confirmation { c in
            sut.receiveOnMainQueue()
                .filter { _ in Thread.current.isMainThread }
                .sink { _ in c.confirm() }
                .store(in: &self.cancellables)
            
            sut.send(42)
            
            try await Task.sleep(
                for: .seconds(0.3)
            )
        }
    }
    
    @Test
    func `receiveOnMainLoop executes on expected thread`() async throws {
        let sut = GuaranteePassthroughSubject<Int>()
        
        try await confirmation { c in
            sut.receiveOnMainLoop()
                .filter { _ in Thread.current.isMainThread }
                .sink { _ in c.confirm() }
                .store(in: &self.cancellables)
            
            sut.send(42)
            
            try await Task.sleep(
                for: .seconds(0.3)
            )
        }
    }
    
    // MARK: Weak
    
    @Test
    func `weakSink has expected capture semantics`() async throws {
        let sut = GuaranteePassthroughSubject<Int>()
        
        autoreleasepool {
            let ref = Object()
            self.object.ref = ref
            #expect(self.object.ref != nil)
        }
        
        await confirmation { c in
            sut.weakSink(capturing: self.object) { wObject, value in
                #expect(wObject != nil)
                #expect(wObject!.ref == nil)
                c.confirm()
            }
            .store(in: &self.cancellables)
            
            sut.send(42)
        }
    }
    
    // MARK: Guard
    
    @Test
    func `guard filters out nil values`() async {
        let sut = GuaranteePassthroughSubject<Int?>()
        var failed: Bool = false
        
        await confirmation { c in
            sut.guard()
                .sink {
                    if $0 == 42 {
                        c.confirm()
                    } else {
                        failed = true
                    }
                }
                .store(in: &self.cancellables)
            
            sut.send(nil)
            sut.send(42)
        }
        
        #expect(!failed)
    }
    
    // MARK: Equals
    
    @Test
    func `equals filters out non-equal values`() async {
        let sut = GuaranteePassthroughSubject<Int>()
        var failed: Bool = false
        
        await confirmation { c in
            sut.equals(42)
                .sink {
                    if $0 == 42 {
                        c.confirm()
                    } else {
                        failed = true
                    }
                }
                .store(in: &self.cancellables)
         
            sut.send(24)
            sut.send(42)
        }
        
        #expect(!failed)
    }
    
    @Test
    func `notEquals filters out equal values`() async {
        let sut = GuaranteePassthroughSubject<Int>()
        var failed: Bool = false

        await confirmation { c in
            sut.notEquals(42)
                .sink {
                    if $0 != 42 {
                        c.confirm()
                    } else {
                        failed = true
                    }
                }
                .store(in: &self.cancellables)
            
            sut.send(42)
            sut.send(24)
        }
        
        #expect(!failed)
    }
    
    // MARK: Bool
    
    @Test
    func `isTrue filters out false values`() async {
        let sut = GuaranteePassthroughSubject<Bool>()
        var failed: Bool = false
        
        await confirmation { c in
            sut.isTrue()
                .sink {
                    if $0 {
                        c.confirm()
                    } else {
                        failed = true
                    }
                }
                .store(in: &self.cancellables)
            
            sut.send(false)
            sut.send(true)
        }
        
        #expect(!failed)
    }
    
    @Test
    func `isFalse filters out true values`() async {
        let sut = GuaranteePassthroughSubject<Bool>()
        var failed: Bool = false
        
        await confirmation { c in
            sut.isFalse()
                .sink {
                    if !$0 {
                        c.confirm()
                    } else {
                        failed = true
                    }
                }
                .store(in: &self.cancellables)
            
            sut.send(true)
            sut.send(false)
        }
        
        #expect(!failed)
    }
}
