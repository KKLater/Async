//
//  AsyncOperation.swift
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

/// `AsyncOperation` 是一个用于管理同步队列操作的类型。
/// 内部线程为同步逻辑。
/// 内部使用 `DispatchSemaphore` 调度队列的执行。
public final class AsyncOperation: Identifiable {
    
    /// 操作队列的名称，
    ///
    /// - Note
    /// `com.async.operation.#_id_#` 格式
    public private(set) var name: String
        
    /// 启动一个同步线程调度线程管理
    /// - Parameter operationClosure: 线程操作事件
    /// - Returns: 同步线程调度
    @discardableResult public static func task(operationClosure: @escaping (_ operation: AsyncOperation) -> Void) -> AsyncOperation {
        let operation = AsyncOperation(operationClosure: operationClosure)
        operation.start()
        operation.freeAfterFinish()
        return operation
    }

    /// 操作队列 `id`
    public var id: String = UUID().uuidString
    
    /// 操作队列
    private var operationQueue: DispatchQueue
    
    /// 操作任务队列
    private var operationClosure: (_ operation: AsyncOperation) -> Void
    
    /// 操作任务屏蔽队列
    /// 可以用于在多组事件之间插入屏蔽队列，隔离多组事件操作
    private var barrierClosure: ((_ operation: AsyncOperation) -> Void)? = nil
    
    /// 操作队列释放
    private var freeClosure: ((_ operation: AsyncOperation) -> Void)? = nil
    
    /// 信号量
    private var semaphore: DispatchSemaphore
    
    /// 初始化操作队列对象
    /// - Parameter operationClosure: 操作队列任务
    private init(operationClosure: @escaping (_: AsyncOperation) -> Void) {
        self.name = "com.async.operation.\(id)"
        // 用于线程调度
        self.operationQueue = DispatchQueue(label: name, attributes: .concurrent)
        // 用户结果回调限制
        self.semaphore = DispatchSemaphore(value: 0)
        self.operationClosure = operationClosure
        
        asyncWaitQueues[self.name] = self
    }
    
    /// 开始执行操作队列任务
    private func start() {
        operationQueue.async { [weak self] in
            guard let sSelf = self else { return }
            sSelf.operationClosure(sSelf)
        }
    }
    
    /// 屏蔽分隔队列任务
    private func barrier() {
        operationQueue.async(flags: .barrier) { [weak self] in
            guard let sSelf = self else { return }
            sSelf.barrierClosure?(sSelf)
        }
    }
    
    /// 释放队列任务
    private func free() {
        operationQueue.async { [weak self] in
            guard let sSelf = self else { return }
            sSelf.freeClosure?(sSelf)
        }
    }
    
    /// 队列任务执行结束后，释放操作
    private func freeAfterFinish() {
        if barrierClosure == nil {
            self.barrierClosure = { operation in
                
            }
        }
        
        self.freeClosure = { operation in
            asyncWaitQueues[operation.name] = nil
        }
        
        free()
    }

    deinit {
        print("deinit")
    }
}

extension AsyncOperation {
    
    /// 启动一个等待事件，返回限制类型
    /// - Parameter responseClosure: 等待事件包装
    /// - Returns: 等待事件响应结果
    @discardableResult
    public func await<T>(_ taskClosure: (@escaping (Result<T, any Error>) -> Void) -> Void) -> Result<T, any Error> {
        var result: Result<T, any Error>?
        taskClosure { [weak self] tempResult in
            guard let sSelf = self else { return }
            result = tempResult
            sSelf.semaphore.signal()
        }
        semaphore.wait()
        return result ?? .failure(AsyncError.resultError)
    }
    
    /// 启动一个等待事件
    /// - Parameter taskClosure: 等待事件包装
    /// - Returns: 等待事件响应结果
    @discardableResult
    public func await(_ taskClosure: (@escaping (Result<Any, any Error>) -> Void) -> Void) -> Result<Any, any Error> {
        var result: Result<Any, any Error>?
        taskClosure { [weak self] tempResult in
            guard let sSelf = self else { return }
            result = tempResult
            sSelf.semaphore.signal()
        }
        semaphore.wait()
        return result ?? .failure(AsyncError.resultError)
    }
    
    /// 启动一个等待事件
    /// - Parameter response: 等待事件包装
    /// - Returns: 等待事件响应结果
    @discardableResult
    public func await<Success, Failure>(_ task: AsyncTask<Success, Failure>) -> Result<Success, Failure>? where Failure: Error {
        return self.await(task: task)
    }

    /// 启动多个等待事件
    /// - Parameter tasks: 多个等待事件包装
    /// - Returns: 等待事件响应结果
    @discardableResult
    public func await(_ tasks: [AsyncTask<Any, any Error>]) -> [Result<Any, any Error>?]? {
        let task = AsyncTask<[Result<Any, any Error>?], any Error> { [weak self] resultClosure in
            guard let sSelf = self else { return }
            let group = DispatchGroup()
            sSelf.operationQueue.async(group: group) {
                tasks.forEach { task in
                    group.enter()
                    task.action {
                        group.leave()
                    }
                }
                group.notify(queue: sSelf.operationQueue) {
                    let results = tasks.map { $0.result }
                    resultClosure(.success(results))
                }
            }
        }
        
        let result = self.await(task)
        return try? result?.get()
    }
    
    @discardableResult
    public func await(_ tasks: [any AsyncTaskType]) -> [Result<Any, any Error>?]? {
        let task = AsyncTask<[Result<Any, any Error>?], any Error> { [weak self] resultClosure in
            guard let sSelf = self else { return }
            let group = DispatchGroup()
            sSelf.operationQueue.async(group: group) {
                tasks.forEach { task in
                    group.enter()
                    task.action {
                        group.leave()
                    }
                }
                group.notify(queue: sSelf.operationQueue) {
                    var results: [Result<Any, any Error>] = []
                    tasks.forEach {
                        if let value = $0.value {
                            results.append(Result<Any, any Error>.success(value))
                        } else if let error = $0.error {
                            results.append(Result<Any, any Error>.failure(error))
                        } else {
                            results.append(Result<Any, any Error>.success(true))
                        }
                    }
                    resultClosure(.success(results))
                }
            }
        }
        
        let result = self.await(task)
        return try? result?.get()
    }
    
    /// 主线程事件操作
    /// - Parameter closure: 主线程任务执行
    /// - Returns: 主线程执行结果回调
    @discardableResult
    public func main(_ closure: @escaping () -> Void) -> Bool {
        let task = AsyncTask<Bool, any Error> { resultClosure in
            DispatchQueue.main.async {
                closure()
                resultClosure(.success(true))
            }
        }
        let result = self.await(task: task)
        guard case .success(let success) = result else {
            return false
        }

        return success
    }
}

extension AsyncOperation {
    @discardableResult
    private func await<Success, Failure>(task: AsyncTask<Success, Failure>) -> Result<Success, Failure>? where Failure: Error {
        var result: Result<Success, Failure>?
        task.responseClosure { [weak self] tempResult in
            guard let sSelf = self else { return }
            result = tempResult
            sSelf.semaphore.signal()
        }
        semaphore.wait()
        return result
    }    
}
