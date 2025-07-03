//
//  CombinePropertyWrapperTests.swift
//  Async
//
//  Created by Mitch Treece on 5/18/25.
//

@testable import Async
import Testing

@Suite
final class CombinePropertyWrapperTests {
    
//    // MARK: @Publishing
//    
//    @Test
//    func testPublishingPassthrough() {
//        
//        @Publishing<Int, Never> var sut
//        #expect(type(of: sut) == AnyPublisher<Int, Never>.self)
//        #expect(type(of: $sut) == PassthroughSubject<Int, Never>.self)
//        
//    }
//    
//    @Test
//    func testPublishingValue() {
//        
//        @Publishing<Int, Never>(0) var sut
//        #expect(type(of: sut) == AnyPublisher<Int, Never>.self)
//        #expect(type(of: $sut) == CurrentValueSubject<Int, Never>.self)
//        
//    }
//    
//    // MARK: @PublishingGuarantee
//    
//    @Test
//    func testPublishingGuaranteePassthrough() {
//        
//        @Publishing<Int, Never> var sut
//        #expect(type(of: sut) == GuaranteePublisher<Int>.self)
//        #expect(type(of: $sut) == PassthroughSubject<Int, Never>.self)
//        
//    }
//    
//    @Test
//    func testPublishingGuaranteeValue() {
//        
//        @PublishingGuarantee<Int>(0) var sut
//        #expect(type(of: sut) == GuaranteePublisher<Int>.self)
//        #expect(type(of: $sut) == CurrentValueSubject<Int, Never>.self)
//        
//    }
//    
//    // MARK: @PublishingSignal
//    
//    @Test
//    func testPublishingSignal() {
//        
//        @PublishingSignal var sut
//        #expect(type(of: sut) == GuaranteePublisher<Void>.self)
//        #expect(type(of: $sut) == SignalSubject.self)
//        
//    }
//    
//    // MARK: @PublishedSubscription
//    
//    @Test
//    func testPublishedSubscription() {
//        
//        @PublishedSubscription var sut: Int = 0
//        
//        let subject = GuaranteePassthroughSubject<Int>()
//        $sut.subscribe(to: subject)
//        subject.send(1)
//        
//        #expect(sut == 1)
//        
//    }
    
}
