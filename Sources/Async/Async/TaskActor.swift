//
//  TaskActor.swift
//  Async
//
//  Created by Mitch Treece on 6/9/25.
//  Copyright © 2025 Super Epic Studios, LLC.
//

import Foundation

/// An actor that isolates and executes a task.
///
/// ```swift
/// class ValueProvider {
///
///     private(set) var value: Int = 0
///     private let generator = NumberGenerator()
///     private let updateTask = TaskActor<Int>()
///
///     func update() async {
///
///         self.value = await self.updateTask.run { [weak self] in
///             await self?.generator.generate() ?? 0
///         }
///
///     }
///
/// }
/// ```
public actor TaskActor<T: Sendable> {
    
    private var task: Task<T, any Error>?
    
    /// Executes a task closure within the actor's isolation context.
    /// - parameter operation: The task closure to execute.
    /// - returns: The value returned by the task closure.
    public func run(_ operation: @escaping @Sendable () async throws -> T) async throws -> T {
        
        if self.task == nil {
            self.task = Task {
                try await operation()
            }
        }
        
        defer {
            self.task = nil
        }
        
        return try await self.task!.value
        
    }
    
}
