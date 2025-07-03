//
//  AsyncService.swift
//  Demo
//
//  Created by Mitch Treece on 6/22/25.
//

import Async
import Foundation

protocol AsyncServiceProtocol: Sendable {
    
    var isLoadingStream: AnyAsyncSequence<Bool> { get }
    var wordStream: AnyAsyncSequence<String?> { get }
    
    func update()
    
}

final class AsyncService: AsyncServiceProtocol {
    
    @Streaming<Bool>(false) var isLoadingStream
    @Streaming<String?>(nil) var wordStream
    
    private let provider = WordProvider()
    
    func update() {

        print("AsyncService.update() - main: \(Thread.current.isMainThread)")
        
        Task {
            
            print("AsyncService.update() - task - main: \(Thread.current.isMainThread)")
                        
            guard !(await self.isLoadingStream.tap(or: false)) else {
                return
            }
            
            self.$isLoadingStream.send(true)
            
            do {
                
                let word = try await self.provider.get()
                self.$wordStream.send(word)
                
            }
            catch {
                print("[AsyncService] Error: \(error.localizedDescription)")
            }
            
            self.$isLoadingStream.send(false)
            
        }
        
    }
    
}
