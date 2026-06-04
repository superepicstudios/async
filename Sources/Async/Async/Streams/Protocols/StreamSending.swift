//
//  StreamSending.swift
//  Async
//
//  Created by Mitch Treece on 6/1/26.
//  Copyright © 2026 Super Epic Studios, LLC.
//

@preconcurrency public import Combine
import Foundation

/// Protocol describing a stream that sends elements to downstream consumers.
public protocol StreamElementSending<Element>: Sendable {
    
    /// The stream's element type.
    associatedtype Element: Sendable
    
    /// Sends an element to downstream consumers.
    /// - parameter element: An element.
    func send(_ element: Element)
}

extension StreamElementSending where Element == Void {
    
    /// Sends a signal to downstream consumers.
    func send() { send(()) }
}

/// Protocol describing a failable stream that sends completions to downstream consumers.
public protocol FailableStreamCompletionSending<Failure>: Sendable {
    
    /// The stream's failure type.
    associatedtype Failure: Error
    
    /// Sends a completion to downstream consumers.
    /// - parameter completion: A completion.
    ///
    /// - Note: This induces a terminal state from which no further elements can be sent.
    func send(completion: Subscribers.Completion<Failure>)
}

/// Protocol describing a non-failable stream that sends completions to downstream consumers.
public protocol NonFailableStreamCompletionSending: Sendable {
    
    /// Sends a completion to downstream consumers.
    /// - parameter completion: A completion.
    ///
    /// - Note: This induces a terminal state from which no further elements can be sent.
    func send(completion: Subscribers.Completion<Never>)
}
