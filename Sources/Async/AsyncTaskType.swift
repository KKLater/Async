//
//  File.swift
//
//  Copyright (c) 2023 Later
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:

//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.

//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//


import Foundation

/// Task type
public protocol AsyncTaskType {
    /// Task execution success
    associatedtype Success
    
    /// Task execution failure
    associatedtype Failure: Error
    
    /// Perform subtask action.
    ///
    /// After the task is executed, the `result` needs to be saved.
    ///
    /// ```swift
    /// func action(closure: @escaping () -> Void) {
    ///
    ///     // Execute the task and obtain the execution result
    ///     let result = ……
    ///
    ///     // After the task execution is complete, the task execution result 'Result<Success, Failure>' needs to be saved
    ///     self.result = result
    ///     closure()
    /// }
    /// ```
    ///
    /// - Parameter closure: Closure called after execution.
    func action(closure: @escaping () -> Void)
    
    /// After the task is executed, the corresponding `result` can be obtained.
    ///
    /// - Note:
    /// 1. All `AsyncTask` tasks that are awaited must have a `Result`. The `Success` in `Result` represents the successful result of the task execution, while `Failure` represents the failure of the task execution and indicates the error.
    /// 2. The `Result` of an `AsyncTask` task can only be used after being awaited. If the `Result` is nil, it means the task has not been executed (not added to `await`).
    var result: Result<Success, Failure>? { get set }
}

/// Provides a shortcut for AsyncTaskType to get the result or error
/// The result or error of a Task can only be obtained after it is managed and scheduled for execution by an AsyncOperation.
///
/// ```swift
/// Async.Task { operation in
///     /// Create a task using any AsyncTaskType type
///     let task = ……
///     let await = operation.await(task)
///
///     /// Get the value of task
///     let value = task.value
///
///     /// Get the error of task
///     let error = task.error
/// }
/// ```
public extension AsyncTaskType {
    /// Get the task result.
    /// If the task is executed successfully, `value` will have a value; if the task fails to execute or has not been executed, `value` will be nil.
    var value: Success? {
        switch result {
        case .success(let success):
            return success
        case .failure(_):
            return nil
        case nil:
            return nil
        }
    }
    
    /// Get the task execution error.
    /// After the task is executed, if it fails, there will be an `error`. If the task has not been executed, `error` will be nil.
    var error: Failure? {
        switch result {
        case .success(_):
            return nil
        case .failure(let failure):
            return failure
        case nil:
            return nil
        }
    }
}
