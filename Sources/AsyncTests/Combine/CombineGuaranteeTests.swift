//
//  CombineGuaranteeTests.swift
//  Async
//
//  Created by Mitch Treece on 5/18/25.
//

@testable import Async
import Testing

@Suite
final class CombineGuaranteeTests {
    
    @Test
    func testAnyPublisherIsGuaranteePublisher() async {
        
        let sut = PassthroughSubject<Int, Never>().eraseToAnyPublisher()
        #expect(type(of: sut) == AnyGuaranteePublisher<Int>.self)
        
    }
    
    @Test
    func testGuaranteePassthroughSubjectIsPassthroughSubject() {
        
        let sut = GuaranteePassthroughSubject<Int>()
        #expect(type(of: sut) == PassthroughSubject<Int, Never>.self)
        
    }
    
    @Test
    func testGuaranteeValueSubjectIsCurrentValueSubject() {
        
        let sut = GuaranteeCurrentValueSubject(0)
        #expect(type(of: sut) == CurrentValueSubject<Int, Never>.self)
        
    }
    
    @Test
    func testGuaranteeFutureIsFuture() {
        
        let sut = GuaranteeFuture<Int> { _ in }
        #expect(type(of: sut) == Future<Int, Never>.self)
        
    }
    
}
