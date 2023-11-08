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

/// `asyncWaitQueues` 是一个全局的等待线程管理 `Dictionary` 实例。
/// 其以 `AsyncOperation` 的 `name`  为 `key`，`AsyncOperation` 实例为 `Value` 进行存储。
/// 其在 `AsyncOperation` 创建时进行存储操作，在 `AsyncOperation` 执行结束时，进行释放操作。
internal var asyncWaitQueues = [String: AsyncOperation]()

/// `Async` 用于启动一个同步线程 `AsyncOperation`，做线程调度。
/// - Note:
/// 线程调度的任务需要注意：
/// 1. 所有 `await` 的 `AsyncTask` 任务必须有结果 `Result`。`Result` 的 `Success` 标识任务执行成功结果，`Failure` 标识任务执行失败，并标识错误。
/// 2. 必须在 `await` 之后才可以使用 `AsyncTask` 任务的 `Result` 。如果结果 `Result` 为空，则任务还没有执行（没有添加到 `await` 执行）。
public struct Async {
    
    /// 启动一个同步线程调度线程管理
    /// - Parameter operationClosure: 线程操作事件
    /// - Returns: 同步线程调度
    @discardableResult
    public static func Task(operationClosure: @escaping (_ operation: AsyncOperation) -> Void) -> AsyncOperation {
        let operation = AsyncOperation.task(operationClosure: operationClosure)
        return operation
    }
}
