//
//  ImmediateClock.swift
//  Async
//
//  Created by Mitch Treece on 5/20/25.
//  Copyright © 2025 Super Epic Studios, LLC.
//

import Foundation

/// A clock that sleeps instantly, and doesn't suspend.
public final class ImmediateClock<Duration: DurationProtocol & Hashable>: Clock, @unchecked Sendable {
    
    private var sleepCount: Int = 0
    
    public var now: Instant { _now }
    @Mutex private var _now: Instant = .init()

    public private(set) var minimumResolution: Duration = .zero

    public init(now: Instant = .init()) {
        self._now = now
    }

    public func sleep(
        until deadline: Instant,
        tolerance: Duration?
    ) async throws {

        self.sleepCount += 1
        try Task.checkCancellation()
        self._now = deadline

    }
    
}

// MARK: Types

extension ImmediateClock {
    
    /// An ``ImmediateClock`` instant.
    public struct Instant: InstantProtocol {

        private let offset: Duration

        /// Initializes an ``ImmediateClock`` instant.
        /// - parameter offset: The instant's initial offset.
        public init(offset: Duration = .zero) {
            self.offset = offset
        }

        public static func < (lhs: Self, rhs: Self) -> Bool {
            lhs.offset < rhs.offset
        }

        public func advanced(by duration: Duration) -> Self {
            .init(offset: self.offset + duration)
        }

        public func duration(to other: Self) -> Duration {
            other.offset - self.offset
        }

    }
    
}
