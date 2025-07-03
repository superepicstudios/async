//
//  SignalSubjectTests.swift
//  Async
//
//  Created by Mitch Treece on 5/18/25.
//

@testable import Async
import Testing

@Suite
final class SignalSubjectTests {
    
    private var bag: CancellableBag
    
    init() {
        self.bag = .init()
    }
    
    @Test
    func testSend() async {
        
        let sut: SignalSubject = .init()
        
        await confirmation { c in
            
            sut
                .eraseToAnyPublisher()
                .sink { c.confirm() }
                .store(in: &self.bag)
            
            sut.send()
            
        }
                
    }
    
}
