//
// Async.swift
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

import Foundation

/// `asyncWaitQueues` is a global management `Dictionary` instance for waiting threads.
/// It stores `AsyncOperation` instances with the `name` of the operation as the key.
/// It performs storage operations when an `AsyncOperation` is created and release operations when an `AsyncOperation` is finished.
internal var asyncWaitQueues = [String: AsyncOperation]()

/// `Async` is used to start a synchronous thread `AsyncOperation` for thread scheduling.
/// 
/// - Note:
/// When scheduling tasks, please note the following:
/// 1. All `AsyncTask` tasks with `await` must have a `Result`. The `Success` of the `Result` indicates the successful result of the task execution, and `Failure` indicates the task execution failure and the associated error.
/// 2. The `Result` of an `AsyncTask` task can only be used after the `await`. If the `Result` is nil, it means the task has not been executed (has not been added to the `await` for execution).
public struct Async {
    
    /// Start a synchronous thread for thread scheduling
    ///
    /// ```swift
    /// Async.Task { operation in
    ///
    ///     let result = operation.await(anyTask)
    ///     
    /// }
    /// ```
    /// - Parameter operationClosure: The closure for thread operations
    /// - Returns: The synchronous thread operation
    @discardableResult
    public static func Task(operationClosure: @escaping (_ operation: AsyncOperation) -> Void) -> AsyncOperation {
        let operation = AsyncOperation.task(operationClosure: operationClosure)
        return operation
    }
}
