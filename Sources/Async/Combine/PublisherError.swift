//
//  PublisherError.swift
//  Async
//
//  Created by Mitch on 1/10/25.
//  Copyright © 2025 Super Epic Studios, LLC.
//

import Foundation

/// Representation of the various publisher errors.
public enum PublisherError: Error {
    
    /// An error representing empty value access
    /// of a publisher's output sequence.
    case emptyOutput
    
}
