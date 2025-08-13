//
//  Disposable.swift
//  Async
//
//  Created by Mitch Treece on 8/2/25.
//  Copyright © 2025 Super Epic Studios, LLC.
//

@preconcurrency import Combine
import Foundation

public protocol Bag: Cancellable, Sendable {
    
    func insert(_ cancellable: any Cancellable)
    func cancel()
    
}

extension Cancellable {
    
    public func store(in bag: any Bag) {
        bag.insert(self)
    }
    
}

extension Task {
    
    public func store(in bag: any Bag) {
        
        bag.insert(AnyCancellable {
            cancel()
        })
        
    }
    
}

public final class CancellableBagNew: Bag {
    
    private struct Storage: Sendable {

        var cancellables = Set<AnyCancellable>()
        var isCancelled = false

    }
        
    @Mutex private var storage: Storage = .init()
    
    public init() {}
    
    public func insert(_ cancellable: any Cancellable) {
        
        let isCancelled = self._storage.withLock {
            
            if !$0.isCancelled {
                $0.cancellables.insert(.init(cancellable))
            }
            
            return $0.isCancelled
            
        }
        
        if isCancelled {
            cancellable.cancel()
        }
        
    }
    
    public func cancel() {
        
        let cancellables = self._storage.withLock { storage -> Set<AnyCancellable> in
            
            guard !storage.isCancelled else {
                return []
            }
            
            storage.isCancelled = true
            
            let current = storage.cancellables
            storage.cancellables.removeAll()
            return current
            
        }
        
        cancellables.forEach {
            $0.cancel()
        }
        
    }
    
}
