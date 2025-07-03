//
//  AsyncValueProviding.swift
//  Async
//
//  Created by Mitch Treece on 6/24/25.
//

import Foundation

/// Protocol describing something async, that can synchronously provide a latest value.
public protocol AsyncValueProviding<Element>: Sendable {

    associatedtype Element: Sendable

    /// The latest value.
    var value: Element { get }

}
