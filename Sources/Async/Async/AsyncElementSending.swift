//
//  AsyncElementSending.swift
//  Async
//
//  Created by Mitch Treece on 7/3/25.
//  Copyright © 2025 Super Epic Studios, LLC.
//

import Foundation

/// Protocol describing something that sends async elements.
public protocol AsyncElementSending {
    
    associatedtype SendingElement: Sendable
    
    /// Sends an element to downstream consumers.
    /// - parameter element: The element to send.
    func send(_ element: SendingElement)
    
}
