//
//  ReplayStream.swift
//  Async
//
//  Created by Mitch Treece on 6/1/26.
//  Copyright © 2026 Super Epic Studios, LLC.
//

@preconcurrency public import Combine
@preconcurrency import CombineExt
import Espresso
import Foundation
import Synchronization

/// A stream that replays a buffered amount of latest elements to downstream consumers.
///
/// ```swift
/// let stream = ReplayStream<Int, Never>(buffering: 2)
///
/// stream.send(0) // Dropped (outside buffer)
/// stream.send(1)
/// stream.send(2)
///
/// stream.sequence { seq in
///     for try await e in seq {
///         print("Received: \(e)")
///     }
///     print("Finished")
/// }
///
/// stream.send(3)
/// stream.send(completion: .finished)
///
/// // → "Received: 1"
/// // → "Received: 2"
/// // → "Received: 3"
/// // → "Finished"
/// ```
///
/// - SeeAlso: ``CombineExt/ReplaySubject``
public final class ReplayStream<Element: Sendable, Failure: Error>: FailableStream, @unchecked Sendable {
    
    public var publisher: any Publisher<Element, Failure> {
        self.subject
    }
    
    private let subject: ReplaySubject<Element, Failure>
    private let latestElement = Mutex<Element?>(nil)
    
    /// Initializes a replay stream.
    /// - parameter buffer: An amount of elements to buffer.
    public init(buffering buffer: UInt) {
        self.subject = ReplaySubject<Element, Failure>(
            bufferSize: Int(buffer)
        )
    }
    
    public func makeAsyncSequence() -> any AsyncSendableSequence<Element, Failure> {
        AsyncPublisherSequence(self.subject)
    }
}

// MARK: Sending

extension ReplayStream: StreamElementSending, FailableStreamCompletionSending {
    
    public func send(_ element: Element) {
        self.latestElement.withLock { $0 = element }
        self.subject.send(element)
    }

    public func send(completion: Subscribers.Completion<Failure>) {
        self.subject.send(completion: completion)
    }
}

// MARK: Erasing

extension ReplayStream: FailableStreamErasing {}

// MARK: Sequencing

extension ReplayStream: StreamSequencing, StreamMainSequencing {}

// MARK: Element

extension ReplayStream: StreamElementProviding, FailableStreamElementObserving, FailableStreamElementMainObserving {

    public var latest: Element {
        self.latestElement.withLock {
            if let val = $0 { val }
            else if let optional = $0 as? any OptionalRepresentable {
                optional.wrappedValue as! Element
            }
            else {
                fatalError(StreamError.emptyStream.localizedDescription)
            }
        }
    }

    @discardableResult
    public func observe(
        priority: TaskPriority,
        receiveElement: @escaping @Sendable (Element) async -> Void,
        receiveFailure: (@Sendable (Failure) async -> Void)?
    ) -> Task<Void, Never> {
        
        let sequence = makeAsyncSequence() as! AsyncPublisherSequence<Element, Failure>
        var iterator = sequence.makeAsyncIterator()

        return Task(priority: priority) {
            do {
                while let element = try await iterator.next() {
                    await receiveElement(element)
                }
            } catch let error as Failure {
                await receiveFailure?(error)
            } catch {
                fatalError(StreamError.unexpectedError.localizedDescription)
            }
        }
    }
    
    @discardableResult
    public func observeOnMain(
        receiveElement: @escaping @MainActor (Element) async -> Void,
        receiveFailure: (@MainActor (Failure) async -> Void)?
    ) -> Task<Void, Never> {
        
        let sequence = makeAsyncSequence() as! AsyncPublisherSequence<Element, Failure>
        var iterator = sequence.makeAsyncIterator()

        return Task(priority: .high) {
            do {
                while let element = try await iterator.next() {
                    await receiveElement(element)
                }
            } catch let error as Failure {
                await receiveFailure?(error)
            } catch {
                fatalError(StreamError.unexpectedError.localizedDescription)
            }
        }
    }
}
