//
//  MutexMacroTests.swift
//  AsyncMacrosTests
//
//  Created by Mitch Treece on 6/15/25.
//  Copyright © 2025 Super Epic Studios, LLC.
//

@testable import Async
import Testing

@Suite
final class MutexMacroTests {
    
    @Mutex var int: Int = 0
    @Mutex var optionalInt: Int?
    @Mutex var string: String = "Hello, world!"
    @Mutex var optionalString: String?
    @Mutex var array: [Int] = []
    @Mutex var optionalArray: [Int]?
    
    @Test
    func testInt() {
        
        let s: AsyncCurrentValueSubject<Int> = .init(0)
        
        #expect(self.int == 0)
        self.int += 1
        #expect(self.int == 1)
        
    }
    
    @Test
    func testOptionalInt() {
        
        #expect(self.optionalInt == nil)
        self.optionalInt = 1
        #expect(self.optionalInt == 1)
        
    }
    
    @Test
    func testString() {
        
        #expect(self.string == "Hello, world!")
        self.string = "foobar"
        #expect(self.string == "foobar")
        
    }
    
    @Test
    func testOptionalStringR() {
        
        #expect(self.optionalString == nil)
        self.optionalString = "Hello, optional!"
        #expect(self.optionalString == "Hello, optional!")
        
    }
    
    @Test
    func testArray() {
        
        #expect(self.array == [])
        self.array = [1]
        #expect(self.array == [1])
        
    }
    
    @Test
    func testOptionalArray() {
        
        #expect(self.optionalArray == nil)
        self.optionalArray = [1]
        #expect(self.optionalArray == [1])
        
    }
    
}
