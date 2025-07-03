//
//  AsyncCompletionSending.swift
//  Async
//
//  Created by Mitch Treece on 7/3/25.
//  Copyright © 2025 Super Epic Studios, LLC.
//

import Foundation

/// Protocol describing something that sends async completions.
public protocol AsyncCompletionSending {
    
    /// Sends a completion to downstream consumers.
    /// - parameter completion: The completion to send.
    func send(_ completion: AsyncCompletion)
    
}

/// Protocol describing something that sends async failable completions.
public protocol AsyncFailableCompletionSending {
    
    associatedtype SendingFailure: Error
    
    /// Sends a completion to downstream consumers.
    /// - parameter completion: The completion to send.
    func send(_ completion: AsyncFailableCompletion<SendingFailure>)
    
}
