//
//  AsyncTests
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

import XCTest
@testable import Async

final class AsyncTests: XCTestCase {
    func testAsyncOperationTasksTest() throws {
        
        let expectation = expectation(description: "")
        let queue = DispatchQueue(label: "addNumber")
        Async.Task { operation in
            NSLog("async----start----thread----%@", Thread.current)
            let number = 10
            let firstTask = self.asyncAdd1Task(number: number, on: queue)
            _ = operation.await(firstTask)
            
            guard let number = firstTask.value, number == 11 else { return }
            
            let secondResult = operation.await(self.asyncAdd2Task(number: number, on: queue))
            guard case .success(let number) = secondResult else { return }
            
            let thirdResult = operation.await(self.asyncAdd3Task(number: number, on: queue))
            guard case .success(let number) = thirdResult else { return }
            
            let fourResult = operation.await(self.asyncAdd4Task(number: number, on: queue))
            guard case .success(let number) = fourResult else { return }
            
            print(number)
            
//            let errorResult = operation.await { resultClosure in
//                resultClosure(.failed(error: AsyncError.resultError))
//            }
//            if let error = errorResult.error {
//                expectation.fulfill()
//                return
//            }
            
            operation.main {
                print("Thread ---- \(Thread.current)")
            }
        
            let newNumber = 100
            let newNumber1: Float = 100

            let firstAsyncTask = self.asyncAdd5Task(number: newNumber)
            let secondAsyncTask = self.asyncAdd6Task(number: newNumber1)
            
            let awaitResult = operation.await([firstAsyncTask, secondAsyncTask])
                        
            let tasksResults = awaitResult
            
            // 获取全部Error
            if let errors = tasksResults?.compactMap({
                if case .failure(_) = $0 {
                    return $0
                }
                return nil
            }) {
                print(errors)
            }
            // 获取单个result
            if let fResult = firstAsyncTask.value {
                print(fResult)
            }
            
            if let sResult = firstAsyncTask.value {
                print(sResult)
            }

            // 获取单个 Error
            if let fError = firstAsyncTask.value {
                print(fError)
            }
            if let sError = secondAsyncTask.value {
                print(sError)
            }
            // 获取全部result
            if let results = tasksResults?.compactMap({
                if case .success(_) = $0 {
                    return $0
                }
                return nil
            }) {
                print(results)
            }
            
            operation.await { responseClosure in
                NSLog("async----end----thread----%@", Thread.current)
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: 20) { error in
            if let error = error {
                print(error)
            }
        }
    }
    
    func asyncAdd1Task(number: Int, on queue: DispatchQueue) -> AsyncTask<Int, any Error> {
        return AsyncTask { resultClosure in
            queue.asyncAfter(deadline: .now()+1) {
                let newNumber = number + 1
                NSLog("asyncAdd1--delay 1s--%d----thread----%@", newNumber, Thread.current)
                resultClosure(.success(newNumber))
            }
        }
    }
    
    func asyncAdd2Task(number: Int, on queue: DispatchQueue) -> AsyncTask<Int, any Error> {
        return AsyncTask { resultClosure in
            queue.asyncAfter(deadline: .now()+2) {
                let newNumber = number + 2
                NSLog("asyncAdd2-- delay 2s--%d----thread----%@", newNumber, Thread.current)
                resultClosure(.success(newNumber))
            }
        }
    }
    
    func asyncAdd3Task(number: Int, on queue: DispatchQueue) -> AsyncTask<Int, any Error> {
        return AsyncTask { resultClosure in
            queue.asyncAfter(deadline: .now()+0.5) {
                let newNumber = number + 3
                NSLog("asyncAdd3--delay 0.5--%d----thread----%@", newNumber, Thread.current)
                resultClosure(.success(newNumber))
            }
        }
    }
    
    func asyncAdd4Task(number: Int, on queue: DispatchQueue) -> AsyncTask<Int, any Error> {
        return AsyncTask { resultClosure in
            queue.asyncAfter(deadline: .now()+4) {
                let newNumber = number + 4
                NSLog("asyncAdd4--delay 4s--%d----thread----%@", newNumber, Thread.current)
                resultClosure(.success(newNumber))
            }
        }
    }
    
    func asyncAdd5Task(number: Int) -> AsyncTask<Int, any Error> {
        return AsyncTask { resultClosure in
            DispatchQueue.main.asyncAfter(deadline: .now()+5) {
                let newNumber = number + 500
                NSLog("asyncAdd5--delay 5s--%d----thread----%@", newNumber, Thread.current)
                resultClosure(.success(newNumber))
            }
        }
    }
    
    func asyncAdd6Task(number: Float) -> AsyncTask<Float, any Error> {
        return AsyncTask { resultClosure in
            DispatchQueue.main.asyncAfter(deadline: .now()+6) {
                let newNumber = number + 500
                NSLog("asyncAdd6--delay 6s--%d----thread----%@", newNumber, Thread.current)
                resultClosure(.success(newNumber))
            }
        }
    }
}
