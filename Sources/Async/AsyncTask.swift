//
//  AsyncTask.swift
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

/// `AsyncTask` is a task wrapper type used to wrap subtasks.
public class AsyncTask<Success, Failure>: AsyncTaskType where Failure : Error {

    fileprivate let id = UUID()
    
    public init(responseClosure: @escaping (@escaping (Result<Success, Failure>) -> Void) -> Void) {
        self.responseClosure = responseClosure
    }
    
    // Asynchronous result data callback
    public var responseClosure: (@escaping (Result<Success, Failure>) -> Void) -> Void
    
    /// Perform subtask action.
    /// - Parameter closure: Closure called after execution.
    public func action(closure: @escaping () -> Void) {
        responseClosure { [weak self] tempResult in
            guard let sSelf = self else { return }
            sSelf.result = tempResult
            closure()
        }
    }
    
    /// After the task is executed, you can get the corresponding `result`.
    ///
    /// - Note:
    /// 1. All `AsyncTask` tasks that are awaited must have a `Result`. The `Success` in `Result` represents a successful execution result, and `Failure` represents a failure with an associated error.
    /// 2. The `Result` of the `AsyncTask` task can only be accessed after it is awaited. If the `Result` is `nil`, it means the task has not been executed (has not been added to `await`).
    public var result: Result<Success, Failure>?
}

extension AsyncTask: Equatable {
    public static func == (lhs: AsyncTask, rhs: AsyncTask) -> Bool {
        return lhs.id == rhs.id
    }
}
