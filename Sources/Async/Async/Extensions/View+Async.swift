//
//  View+Async.swift
//  Async
//
//  Created by Mitch Treece on 6/11/25.
//  Copyright © 2025 Super Epic Studios, LLC.
//

public import SwiftUI

extension View {
    
    /// Adds an action to perform when this view receives elements from an async sequence.
    /// - parameter sequence: The async sequence to stream elements from.
    /// - parameter action: The action to perform.
    /// - returns: A view that triggers `action` when `sequence` receives an element.
    @inlinable
    public func onStream<S: AsyncSequence & Sendable>(
        _ sequence: S,
        perform action: @escaping (S.Element) -> Void
    ) -> some View where S.Failure == Never {
        
        task {
            for await element in sequence {
                action(element)
            }
        }
        
    }
    
    /// Adds an animated action to perform when this view receives elements from an async sequence.
    /// - parameter sequence: The async sequence to stream elements from.
    /// - parameter action: The action to perform.
    /// - returns: A view that triggers `action` when `sequence` receives an element.
    @inlinable
    public func onStreamWithAnimation<S: AsyncSequence & Sendable>(
        _ sequence: S,
        perform action: @escaping (S.Element) -> Void
    ) -> some View where S.Failure == Never {
        
        onStream(sequence) { element in
            withAnimation {
                action(element)
            }
        }
        
    }
    
}
