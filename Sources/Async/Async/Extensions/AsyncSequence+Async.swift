//
//  AsyncSequence+Async.swift
//  Async
//
//  Created by Mitch Treece on 6/25/25.
//  Copyright © 2025 Super Epic Studios, LLC.
//

import Foundation

extension AsyncSequence where Self: Sendable {
    
    /// Attaches a consumer with closure-based behavior to the async sequence.
    /// - parameter body: The closure to execute on receipt of a value.
    /// - returns: A cancellable task instance, which you use when you end
    ///   assignment of the received value. Deallocation of the task will tear
    ///   down the consumer stream.
    ///
    /// ```swift
    /// let subject = AsyncPassthroughSubject<Int>()
    /// let bag = AsyncCancellableBag()
    ///
    /// subject
    ///     .sink { print("Received: \($0)") }
    ///     .store(in: &bag)
    ///
    /// subject.send(1)
    /// subject.send(2)
    /// subject.send(3)
    ///
    /// // → "Received: 1"
    /// // → "Received: 2"
    /// // → "Received: 3"
    /// ```
    public func sink(_ body: @escaping @Sendable (Element) -> Void) -> AnyAsyncCancellable {
        
        Task {
            for try await element in self {
                body(element)
            }
        }
        
    }
    
    /// Attaches a consumer with weak closure-based behavior to the async sequence.
    /// - parameter object: The object to weakly capture.
    /// - parameter body: The closure to execute on receipt of a value.
    /// - returns: A cancellable task instance, which you use when you end
    ///   assignment of the received value. Deallocation of the task will tear
    ///   down the consumer stream.
    ///
    /// ```swift
    /// let subject = AsyncPassthroughSubject<Int>()
    /// let bag = AsyncCancellableBag()
    ///
    /// subject
    ///     .weakSink(capturing: self) { weakSelf, element in
    ///         weakSelf?.log(element)
    ///     }
    ///     .store(in: &bag)
    ///
    /// subject.send(1)
    /// subject.send(2)
    /// subject.send(3)
    ///
    /// // → "Received: 1"
    /// // → "Received: 2"
    /// // → "Received: 3"
    /// ```
    public func weakSink<Object: AnyObject & Sendable>(
        capturing object: Object,
        _ body: @escaping @Sendable (Object?, Element) -> Void
    ) -> AnyAsyncCancellable {
        
        sink { [weak object] value in
            body(object, value)
        }
        
    }
    
    /// Assigns each element from an async sequence to a property on an object.
    /// - parameter keyPath: A key path that indicates the property to assign.
    /// - parameter object: The object that contains the property. The consumer assigns the
    ///   object’s property every time it receives a new value.
    /// - returns: A cancellable task instance, which you use when you end
    ///   assignment of the received value. Deallocation of the task will tear
    ///   down the consumer stream.
    ///
    /// ```swift
    /// var value: Int = 0
    /// let subject = AsyncPassthroughSubject<Int>()
    /// let bag = AsyncCancellableBag()
    ///
    /// subject
    ///     .assign(to: \.value, on: self)
    ///     .store(in: &bag)
    ///
    /// subject.send(1) // Value = 1
    /// subject.send(2) // Value = 2
    /// subject.send(3) // Value = 3
    /// ```
    public func assign<Object: AnyObject & Sendable>(
        to keyPath: ReferenceWritableKeyPath<Object, Element> & Sendable,
        on object: Object
    ) -> AnyAsyncCancellable {
        
        sink { value in
            object[keyPath: keyPath] = value
        }
        
    }
    
    /// Weakly assigns each element from an async sequence to a property on an object.
    /// - parameter keyPath: A key path that indicates the property to assign.
    /// - parameter object: The object that contains the property. The consumer assigns the
    ///   object’s property every time it receives a new value.
    /// - returns: A cancellable task instance, which you use when you end
    ///   assignment of the received value. Deallocation of the task will tear
    ///   down the consumer stream.
    ///
    /// ```swift
    /// var value: Int = 0
    /// let subject = AsyncPassthroughSubject<Int>()
    /// let bag = AsyncCancellableBag()
    ///
    /// subject
    ///     .weakAssign(to: \.value, on: self)
    ///     .store(in: &bag)
    ///
    /// subject.send(1) // Value = 1
    /// subject.send(2) // Value = 2
    /// subject.send(3) // Value = 3
    /// ```
    public func weakAssign<Object: AnyObject & Sendable>(
        to keyPath: ReferenceWritableKeyPath<Object, Element> & Sendable,
        on object: Object
    ) -> AnyAsyncCancellable {
        
        weakSink(capturing: object) { weakObject, value in
            weakObject?[keyPath: keyPath] = value
        }
        
    }
    
}
