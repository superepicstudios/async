//
//  CombineService.swift
//  Demo
//
//  Created by Mitch Treece on 5/12/25.
//

import Async
import Foundation

protocol CombineServiceProtocol: Sendable {
    
    var isLoadingPublisher: GuaranteePublisher<Bool> { get }
    var wordPublisher: GuaranteePublisher<String?> { get }

    func update()
    
}

final class CombineService: CombineServiceProtocol {
    
    @Publishing<String?>(nil) var wordPublisher
    @Publishing<Bool>(false) var isLoadingPublisher

    private let provider = WordProvider()
    
    func update() {
        
        guard !self.isLoadingPublisher.tap(or: false) else {
            return
        }
        
        self.$isLoadingPublisher.send(true)
                
        Task {
            
            do {
                
                let word = try await self.provider.get()
                self.$wordPublisher.send(word)
                
            }
            catch {
                print("[CombineService] Error: \(error.localizedDescription)")
            }
            
            self.$isLoadingPublisher.send(false)
            
        }
        
    }
    
}
