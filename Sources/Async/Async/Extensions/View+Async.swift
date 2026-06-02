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
    /// - parameter sequence: An async sequence to stream elements from.
    /// - parameter action: An action to perform when the sequence receives an element.
    /// - parameter onError: An error handler to call when the sequence receives a failure.
    /// - returns: A view that triggers `action` when `sequence` receives an element.
    @inlinable
    public func onStream<S: AsyncSequence & Sendable>(
        _ sequence: S,
        perform action: @escaping (S.Element) -> Void,
        onError: ((S.Failure) -> Void)? = nil
    ) -> some View {
        task {
            do {
                for try await element in sequence {
                    action(element)
                }
            } catch let error as S.Failure {
                onError?(error)
            } catch {
                fatalError("Attempting to iterate over an unexpected error. This shouldn't happen.")
            }
        }
    }
    
    /// Adds an animated action to perform when this view receives elements from an async sequence.
    /// - parameter sequence: An async sequence to stream elements from.
    /// - parameter action: An action to perform when the sequence receives an element.
    /// - parameter onError: An error handler to call when the sequence receives a failure.
    /// - returns: A view that triggers an animated `action` when `sequence` receives an element.
    @inlinable
    public func onStreamWithAnimation<S: AsyncSequence & Sendable>(
        _ sequence: S,
        perform action: @escaping (S.Element) -> Void,
        onError: ((S.Failure) -> Void)? = nil
    ) -> some View {
        onStream(
            sequence,
            perform: { element in
                withAnimation {
                    action(element)
                }
            },
            onError: onError
        )
    }
}
