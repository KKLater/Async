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

/// `AsyncTask`是一个任务包装类型，用于包装子任务
public class AsyncTask {
    fileprivate let id = UUID()
    
    public init(responseClosure: @escaping (@escaping (AsyncResult) -> Void) -> Void) {
        self.responseClosure = responseClosure
    }
    
    // 异步结果数据回调
    public var responseClosure: (@escaping (AsyncResult) -> Void) -> Void
    
    
    /// 子任务执行操作
    /// - Parameter closure: 执行结束回调
    func action(closure: @escaping () -> Void) {
        responseClosure { tempResult in
            self.result = tempResult
            closure()
        }
    }
    
    /// 任务执行结束回调后，可以获取到对应 `result`
    /// 成功时，可以使用其 `result`
    /// 失败时，可以使用其 `error`
    var result: AsyncResult?
}
extension AsyncTask: Equatable {
    public static func == (lhs: AsyncTask, rhs: AsyncTask) -> Bool {
        return lhs.id == rhs.id
    }
}
