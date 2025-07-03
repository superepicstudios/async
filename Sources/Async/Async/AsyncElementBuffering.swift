//
//  AsyncElementBuffering.swift
//  Async
//
//  Created by Mitch Treece on 5/26/25.
//  Copyright © 2025 Super Epic Studios, LLC.
//

import Foundation

/// Protocol describing something that buffers async elements.
public protocol AsyncElementBuffering {
    
    /// Flag indicating if we currently have buffered elements.
    var hasBufferedElements: Bool { get }
    
}
