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

public protocol AsyncTaskType {
    associatedtype Success
    associatedtype Failure: Error
    func action(closure: @escaping () -> Void)
    var value: Success? { get }
    var error: Failure? { get }
}
/// `AsyncTask`是一个任务包装类型，用于包装子任务
public class AsyncTask<Success, Failure>: AsyncTaskType where Failure : Error {
    public var value: Success? {
        switch result {
        case .success(let success):
            return success
        case .failure(_):
            return nil
        case nil:
            return nil
        }
    }
    
    public var error: Failure? {
        switch result {
        case .success(_):
            return nil
        case .failure(let failure):
            return failure
        case nil:
            return nil
        }
    }
    fileprivate let id = UUID()
    
    public init(responseClosure: @escaping (@escaping (Result<Success, Failure>) -> Void) -> Void) {
        self.responseClosure = responseClosure
    }
    
    // 异步结果数据回调
    public var responseClosure: (@escaping (Result<Success, Failure>) -> Void) -> Void

    
    /// 子任务执行操作
    /// - Parameter closure: 执行结束回调
    public func action(closure: @escaping () -> Void) {
        responseClosure { tempResult in
            self.result = tempResult
            closure()
        }
    }
    
    /// 任务执行结束回调后，可以获取到对应 `result`
    ///
    /// - Note:
    /// 1. 所有 `await` 的 `AsyncTask` 任务必须有结果 `Result`。`Result` 的 `Success` 标识任务执行成功结果，`Failure` 标识任务执行失败，并标识错误。
    /// 2. 必须在 `await` 之后才可以使用 `AsyncTask` 任务的 `Result` 。如果结果 `Result` 为空，则任务还没有执行（没有添加到 `await` 执行）。
    var result: Result<Success, Failure>?
}
extension AsyncTask: Equatable {
    public static func == (lhs: AsyncTask, rhs: AsyncTask) -> Bool {
        return lhs.id == rhs.id
    }
}
