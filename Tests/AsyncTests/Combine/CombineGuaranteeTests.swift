//
//  CombineGuaranteeTests.swift
//  AsyncTests
//
//  Created by Mitch Treece on 5/18/25.
//  Copyright © 2025 Super Epic Studios, LLC.
//

@testable import Async
import Testing

@Suite
final class CombineGuaranteeTests {
    
    @Test
    func `AnyGuaranteePublisher<O> is AnyPublisher<O,F>`() async {
        let sut = PassthroughSubject<Int, Never>().eraseToAnyPublisher()
        #expect(type(of: sut) == AnyGuaranteePublisher<Int>.self)
    }
    
    @Test
    func `GuaranteePassthroughSubject<O> is PassthroughSubject<O,F>`() {
        let sut = GuaranteePassthroughSubject<Int>()
        #expect(type(of: sut) == PassthroughSubject<Int, Never>.self)
    }
    
    @Test
    func `GuaranteeCurrentValueSubject<O> is CurrentValueSubject<O,F>`() {
        let sut = GuaranteeCurrentValueSubject(0)
        #expect(type(of: sut) == CurrentValueSubject<Int, Never>.self)
    }
    
    @Test
    func `GuaranteeReplaySubject<O> is ReplaySubject<O,F>`() {
        let sut = GuaranteeReplaySubject<Int>(bufferSize: 1)
        #expect(type(of: sut) == ReplaySubject<Int, Never>.self)
    }
    
    @Test
    func `GuaranteeFuture<T> is Future<T,F>`() {
        let sut = GuaranteeFuture<Int> { _ in }
        #expect(type(of: sut) == Future<Int, Never>.self)
    }
}
