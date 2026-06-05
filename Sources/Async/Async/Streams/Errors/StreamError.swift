//
//  StreamError.swift
//  Async
//
//  Created by Mitch Treece on 6/1/26.
//  Copyright © 2026 Super Epic Studios, LLC.
//

public import Foundation

/// Representation of the various stream errors.
public enum StreamError: LocalizedError, Sendable {

    /// An empty stream access error.
    case emptyStream

    /// An unexpectedly caught error.
    case unexpectedError

    public var errorDescription: String? {
        switch self {
        case .emptyStream: "Attempting to access the latest element of an empty stream."
        case .unexpectedError: "Caught an unexpected error."
        }
    }
}
