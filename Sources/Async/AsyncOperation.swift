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

/// `AsyncOperation` is a type used to manage synchronous queue operations.
/// The internal thread is synchronous.
/// It uses `DispatchSemaphore` to schedule the execution of the queue.
public final class AsyncOperation: Identifiable {
    
    /// The name of the operation queue.
    ///
    /// - Note:
    /// The format is `com.async.operation.#_id_#`.
    public private(set) var name: String
        
    /// Start a synchronous thread scheduling operation.
    /// - Parameter operationClosure: The operation closure.
    /// - Returns: The synchronous thread scheduling operation.
    @discardableResult static func task(operationClosure: @escaping (_ operation: AsyncOperation) -> Void) -> AsyncOperation {
        let operation = AsyncOperation(operationClosure: operationClosure)
        operation.start()
        operation.freeAfterFinish()
        return operation
    }

    /// The id of the operation queue.
    public private(set) var id: String = UUID().uuidString
    
    /// The operation queue.
    public private(set) var operationQueue: DispatchQueue
    
    /// The operation closure.
    private var operationClosure: (_ operation: AsyncOperation) -> Void
    
    /// The barrier closure.
    /// It can be used to insert a barrier closure between multiple groups of events to isolate the operations of multiple groups of events.
    private var barrierClosure: ((_ operation: AsyncOperation) -> Void)? = nil
    
    /// The free closure.
    private var freeClosure: ((_ operation: AsyncOperation) -> Void)? = nil
    
    /// The semaphore.
    private var semaphore: DispatchSemaphore
    
    /// Initialize the operation queue object.
    /// - Parameter operationClosure: The operation closure.
    private init(operationClosure: @escaping (_ operation: AsyncOperation) -> Void) {
        self.name = "com.async.operation.\(id)"
        // Used for thread scheduling
        self.operationQueue = DispatchQueue(label: name, attributes: .concurrent)
        // Used for result callback limitation
        self.semaphore = DispatchSemaphore(value: 0)
        self.operationClosure = operationClosure
        
        asyncWaitQueues[self.name] = self
    }
    
    /// Start executing the operation queue task.
    private func start() {
        operationQueue.async { [weak self] in
            guard let sSelf = self else { return }
            sSelf.operationClosure(sSelf)
        }
    }
    
    /// Add a barrier closure to the operation queue.
    private func barrier() {
        operationQueue.async(flags: .barrier) { [weak self] in
            guard let sSelf = self else { return }
            sSelf.barrierClosure?(sSelf)
        }
    }
    
    /// Free the operation queue.
    private func free() {
        operationQueue.async { [weak self] in
            guard let sSelf = self else { return }
            sSelf.freeClosure?(sSelf)
        }
    }
    
    /// Release the operation queue after the task finishes.
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
        print("Async Operation: id: \(id), name: \(name) deinit")
    }
}

extension AsyncOperation {
    
    /// Start a waiting event and return a restricted type.
    ///
    /// ```swift
    /// Async.Task { operation in
    ///     operation.await<Success> { resultClosure in
    ///
    ///         let object = /* Perform some task and get a result */
    ///         // The object is an instance of Success.
    ///         resultClosure(.success(object))
    ///
    ///         let error = /* Perform some task and get an error */
    ///         resultClosure(.failure(error))
    ///     }
    /// }
    /// ```
    ///
    /// - Parameter taskClosure: The task closure.
    /// - Returns: The result of the waiting event.
    @discardableResult
    public func await<T>(_ taskClosure: (@escaping (Result<T, Error>) -> Void) -> Void) -> Result<T, Error> {
        var result: Result<T, Error>?
        taskClosure { [weak self] tempResult in
            guard let sSelf = self else { return }
            result = tempResult
            sSelf.semaphore.signal()
        }
        semaphore.wait()
        return result ?? .failure(AsyncError.resultError)
    }
    
    /// Start a waiting event.
    ///
    /// ```swift
    /// Async.Task { operation in
    ///     operation.await { resultClosure in
    ///
    ///         let object = /* Perform some task and get a result */
    ///         resultClosure(.success(object))
    ///
    ///         let error = /* Perform some task and get an error */
    ///         resultClosure(.failure(error))
    ///     }
    /// }
    /// ```
    ///
    /// - Parameter taskClosure: The task closure.
    /// - Returns: The result of the waiting event.
    @discardableResult
    public func await(_ taskClosure: (@escaping (Result<Any, Error>) -> Void) -> Void) -> Result<Any, Error> {
        var result: Result<Any, Error>?
        taskClosure { [weak self] tempResult in
            guard let sSelf = self else { return }
            result = tempResult
            sSelf.semaphore.signal()
        }
        semaphore.wait()
        return result ?? .failure(AsyncError.resultError)
    }
   
    /// Start a waiting event.
    ///
    /// ```swift
    /// Async.Task { operation in
    ///
    ///     /// func testTask() -> AsyncTask<Int, any Error> {
    ///     ///     return AsyncTask<Int, any Error> { resultClosure in
    ///     ///         resultClosure(.success(5))
    ///     ///     }
    ///     /// }
    ///
    ///     // Create an instance of the type that follows the AsyncTaskType protocol
    ///     let task = testTask()
    ///     let result = operation.await(task)
    ///     if let value = task.value {
    ///         print(value) // 5
    ///     }
    /// }
    /// ```
    ///
    /// - Parameter task: The task.
    /// - Returns: The result of the waiting event.
    @discardableResult
    public func await<T: AsyncTaskType>(_ task: T) -> Result<T.Success, T.Failure>? {
        task.action { [weak self] in
            guard let sSelf = self else { return }
            sSelf.semaphore.signal()
        }
        semaphore.wait()
        return task.result
    }

    /// Start multiple waiting events.
    ///
    /// ```swift
    /// Async.Task { operation in
    ///
    ///     /// func testTask1() -> AsyncTask<Int, any Error> {
    ///     ///     return AsyncTask<Int, any Error> { resultClosure in
    ///     ///         resultClosure(.success(5))
    ///     ///     }
    ///     /// }
    ///     let task1 = self.testTask1()
    ///
    ///     /// func testTask2() -> AsyncTask<Int, any Error> {
    ///     ///     return AsyncTask<Int, any Error> { resultClosure in
    ///     ///         resultClosure(.success(10))
    ///     ///     }
    ///     /// }
    ///     let task2 = self.testTask2()
    ///
    ///     /// // error
    ///     /// func testTask3() -> AsyncTask<Int, any Error> {
    ///     ///     return AsyncTask<Int, any Error> { resultClosure in
    ///     ///         resultClosure(.failure(AsyncError.resultError))
    ///     ///     }
    ///     /// }
    ///     let task3 = self.testTask3()
    ///
    ///     let _ = operation.await([task1, task2, task3])
    ///
    ///     if let value1 = task1.value {
    ///         print(value1) // 5
    ///     }
    ///
    ///     if let value2 = task2.value {
    ///         print(value2) // 10
    ///     }
    ///
    ///     if let value3 = task3.value {
    ///         print(value3) // no print
    ///     }
    ///
    ///     if let error = task3.error {
    ///         print(error) // throw the error of task
    ///     }
    /// }
    /// ```
    /// - Parameter tasks: The tasks.
    /// - Returns: The results of the waiting events.
    @discardableResult
    public func await(_ tasks: [any AsyncTaskType]) -> [Result<Any, Error>?]? {
        let task = AsyncTask<[Result<Any, Error>?], Error> { [weak self] resultClosure in
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
                    var results: [Result<Any, Error>] = []
                    tasks.forEach {
                        if let value = $0.value {
                            results.append(Result<Any, Error>.success(value))
                        } else if let error = $0.error {
                            results.append(Result<Any, Error>.failure(error))
                        } else {
                            results.append(Result<Any, Error>.success(true))
                        }
                    }
                    resultClosure(.success(results))
                }
            }
        }
        
        let result = self.await(task)
        return try? result?.get()
    }
    
    /// Main thread event operation.
    /// - Parameter closure: The closure to be executed on the main thread.
    /// - Returns: The result of the main thread execution.
    @discardableResult
    public func main(_ closure: @escaping () -> Void) -> Bool {
        let task = AsyncTask<Bool, Error> { resultClosure in
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
