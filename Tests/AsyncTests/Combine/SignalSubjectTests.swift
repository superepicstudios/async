//
//  SignalSubjectTests.swift
//  AsyncTests
//
//  Created by Mitch Treece on 5/18/25.
//  Copyright © 2025 Super Epic Studios, LLC.
//

@testable import Async
import Testing

@Suite
final class SignalSubjectTests {
    
    private var cancellables: CancellableSet
    
    init() {
        self.cancellables = .init()
    }
    
    @Test
    func `signal is sent`() async {
        let sut: SignalSubject = .init()
        
        await confirmation { c in
            sut.eraseToAnyPublisher()
                .sink { c.confirm() }
                .store(in: &self.cancellables)
            
            sut.send()
        }
    }
}
