//
//  AsyncCompletion.swift
//  Async
//
//  Created by Mitch Treece on 5/18/25.
//  Copyright © 2025 Super Epic Studios, LLC.
//

import Foundation

/// Representation of the various async completion states.
public enum AsyncCompletion: Sendable {
    
    /// A finished state.
    case finished
    
}

/// Representation of the various failable async completion states.
public enum AsyncFailableCompletion<Failure: Error>: Sendable {
    
    /// A finished state.
    case finished
    
    /// A failure state.
    case failure(Failure)
    
    /// Flag indicating if the state is `finished`.
    var isFinished: Bool {
        
        return switch self {
        case .finished: true
        default: false
        }
        
    }
    
    /// Flag indicating if the state is `failure`.
    var isFailed: Bool {
        
        return switch self {
        case .failure: true
        default: false
        }
        
    }
    
}
