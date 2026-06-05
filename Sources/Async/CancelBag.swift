//
//  CancelBag.swift
//  Async
//
//  Created by Mitch Treece on 8/2/25.
//  Copyright © 2025 Super Epic Studios, LLC.
//

@preconcurrency import Combine

/// Thread safe cancellable storage that cancels elements when removed or destroyed.
///
/// - SeeAlso: ``CancellableSet``, ``AsyncCancellableSet``
public final class CancelBag: Cancellable, Sendable {

    private struct Storage: Sendable {
        var cancellables = CancellableSet()
        var isCancelled = false
    }

    @Mutex private var storage: Storage = .init()

    /// Initializes a cancel bag.
    public init() {}
    
    deinit {
        cancel()
    }

    /// Inserts an element into the cancel bag.
    /// - parameter element: The cancellable element to insert.
    ///
    /// - Note: Inserting an element into a bag that is already
    ///   cancelled will _not_ retain the element, and will
    ///   immediately cancel.
    public func insert(_ element: any Cancellable) {

        let isCancelled = self._storage.withLock { store in
            if !store.isCancelled {
                store.cancellables.insert(.init(element))
            }

            return store.isCancelled
        }

        if isCancelled {
            element.cancel()
        }
    }

    /// Removes and cancels all elements in the bag.
    public func dump() {
        cancel(terminal: false)
    }

    /// Cancels the bag, and all its elements.
    ///
    /// - Note: This introduces a terminal state from which
    ///   no additional elements can be added to the bag.
    public func cancel() {
        cancel(terminal: true)
    }

    // MARK: Private

    private func cancel(terminal: Bool) {

        let cancellables = self._storage.withLock { store -> Set<AnyCancellable> in

            guard !store.isCancelled else {
                return []
            }

            if terminal {
                store.isCancelled = true
            }

            let cancellables = store.cancellables
            store.cancellables.removeAll()
            return cancellables
        }

        cancellables.forEach {
            $0.cancel()
        }
    }
}

extension Cancellable {

    /// Stores the cancellable in a cancel bag.
    /// - parameter bag: A bag in which to store this cancellable.
    public func store(in bag: CancelBag) {
        bag.insert(self)
    }
}

extension Task {

    /// Stores the task in a cancel bag.
    /// - parameter bag: A bag in which to store this task.
    public func store(in bag: CancelBag) {
        bag.insert(AnyCancellable {
            cancel()
        })
    }
}
