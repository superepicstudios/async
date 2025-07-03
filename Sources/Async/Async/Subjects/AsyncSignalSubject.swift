//
//  AsyncSignalSubject.swift
//  Async
//
//  Created by Mitch Treece on 5/25/25.
//  Copyright © 2025 Super Epic Studios, LLC.
//

import Foundation

/// An async subject that broadcasts signals to downstream consumers.
///
/// ```swift
/// let subject = AsyncSignalSubject()
///
/// Task {
///
///     for await _ in subject {
///         print("Signal")
///     }
///
///     print("Finished")
///
/// }
///
/// subject.send()
/// subject.send(.finished)
///
/// // → "Signal"
/// // → "Finished"
/// ```
public typealias AsyncSignalSubject = AsyncPassthroughSubject<Void>

public extension AsyncSignalSubject where Element == Void {
    
    /// Sends a signal to downstream consumers.
    func send() {
        send(())
    }
    
}
