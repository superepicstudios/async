//
//  AsyncGuaranteeTests.swift
//  Async
//
//  Created by Mitch Treece on 5/20/25.
//

@testable import Async
import Testing

@Suite
final class AsyncGuaranteeTests {
    
    @Test func taskIsGuaranteeTask() {
        
        let sut = Task<Void, Never> {}
        #expect(type(of: sut) == GuaranteeTask<Void>.self)
        
    }
    
    @Test func resultIsGuaranteeResult() {
        
        let sut: Result<Int, Never> = .success(0)
        #expect(type(of: sut) == GuaranteeResult<Int>.self)
        
    }
    
}
