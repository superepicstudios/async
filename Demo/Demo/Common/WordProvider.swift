//
//  WordProvider.swift
//  Demo
//
//  Created by Mitch Treece on 5/13/25.
//

import Foundation

struct WordProvider: Sendable {
    
    enum Error: Swift.Error {
        case missingWord
    }
    
    private let minimumTaskDuration: TimeInterval
    
    init(minimumTaskDuration: TimeInterval = 1) {
        self.minimumTaskDuration = minimumTaskDuration
    }
    
    @concurrent
    func get() async throws -> String {
        
        print("WordProvider.get() - main: \(Thread.current.isMainThread)")
        
        let request = URLRequest(url: URL(
            string: "https://random-word-api.herokuapp.com/word"
        )!)
        
        let start = Date.now
        
        let data = try await URLSession
            .shared
            .data(for: request)
            .0
        
        let end = Date.now
        
        if self.minimumTaskDuration > 0 && (end.timeIntervalSince(start) < self.minimumTaskDuration) {
            
            let remainingTime = (self.minimumTaskDuration - end.timeIntervalSince(start))
            
            try await Task.sleep(
                for: .seconds(remainingTime)
            )
            
        }
        
        let array = try JSONSerialization
            .jsonObject(with: data) as? [String] ?? []
        
        if let word = array.first {
            return word.capitalized
        }
        
        throw Error.missingWord
        
    }
    
}
