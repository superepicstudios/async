//
//  View+Combine.swift
//  Async
//
//  Created by Mitch Treece on 5/16/25.
//  Copyright © 2025 Super Epic Studios, LLC.
//

@preconcurrency import Combine
public import SwiftUI

extension View {
    
    /// Adds an animated action to perform when this view receives values from a publisher.
    /// - parameter publisher: The publisher to receive values from.
    /// - parameter action: The action to perform.
    /// - returns: A view that triggers `action` when `publisher` receives a value.
    @inlinable
    public func onReceiveWithAnimation<P: Publisher>(
        _ publisher: P,
        perform action: @escaping (P.Output) -> Void
    ) -> some View where P.Failure == Never {
        
        onReceive(publisher) { output in
            withAnimation {
                action(output)
            }
        }
        
    }
    
}
