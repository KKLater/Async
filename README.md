# Async
Async library based on GCD implementation. Used to replace the system Concurrency library and support its basic Task, await, and async operations in lower version systems.

# Use

在使用 Async 之前，多任务处理类似于：
```swift
    func requestStep1Task(number: Int, completed: @escaping (Int) -> Void) {
        // 异步任务
    }
    
    func requestStep2Task(number: Int, completed: @escaping (Int) -> Void) {
        // 异步任务
    }
    
    func requestStep3Task(number: Int, completed: @escaping (Int) -> Void) {
        // 异步任务
    }

    
    func startRequest() {
        var number = 1
        /// 逐层嵌套
        requestStep1Task(number: number) { step1Number in
            print(step1Number)
            requestStep2Task(number: step1Number) { step2Number in
                print(step2Number)
                requestStep3Task(number: step2Number) { step3Number in
                    print(step2Number)
                }
            }
        }
    }
```

使用 Async 后代码组织方式：
```swift

    func asyncRequestStep1Task(number: Int) -> AsyncTask {
        return AsyncTask { resultClosure in
            DispatchQueue.main.asyncAfter(deadline: .now()+6) {
                let newNumber = number + 500
                NSLog("asyncRequestStep1Task--延迟6s--%d----thread----%@", newNumber, Thread.current)
                resultClosure(AsyncResult.success(result: newNumber))
            }
        }
    }
    
    func asyncRequestStep2Task(number: Int) -> AsyncTask {
        return AsyncTask { resultClosure in
            DispatchQueue.main.asyncAfter(deadline: .now()+6) {
                let newNumber = number + 500
                NSLog("asyncRequestStep2Task--延迟6s--%d----thread----%@", newNumber, Thread.current)
                resultClosure(AsyncResult.success(result: newNumber))
            }
        }
    }
    
    func asyncRequestStep3Task(number: Int) -> AsyncTask {
        return AsyncTask { resultClosure in
            DispatchQueue.main.asyncAfter(deadline: .now()+6) {
                let newNumber = number + 500
                NSLog("asyncRequestStep3Task--延迟6s--%d----thread----%@", newNumber, Thread.current)
                resultClosure(AsyncResult.success(result: newNumber))
            }
        }
    }

    
    func startRequest() {
        let number = 1
        Async.task { operation in
            let step1Result = operation.await(self.asyncRequestStep1Task(number: number))
            guard let step1Number = step1Result.result as? Int else {
                // 处理错误
                if let error = step1Result.error {
                    print(error)
                }
                return
            }
            
            let step2Result = operation.await(self.asyncRequestStep2Task(number: step1Number))
            guard let step2Number = step2Result.result as? Int else {
                // 处理错误
                if let error = step2Result.error {
                    print(error)
                }
                return
            }
            
            let step3Result = operation.await(self.asyncRequestStep3Task(number: step2Number))
            guard let step3Number = step3Result.result as? Int else {
                // 处理错误
                if let error = step3Result.error {
                    print(error)
                }
                return
            }
            
            print(step3Number)
        }
    }
```

对于多个任务的并发操作：

```swift
func asyncRequestStep1_1Task(number: Int) -> AsyncTask {
        return AsyncTask { resultClosure in
            DispatchQueue.main.asyncAfter(deadline: .now()+6) {
                let newNumber = number + 500
                NSLog("asyncRequestStep1Task--延迟6s--%d----thread----%@", newNumber, Thread.current)
                resultClosure(AsyncResult.success(result: newNumber))
            }
        }
    }
    
    func asyncRequestStep1_2Task(number: Int) -> AsyncTask {
        return AsyncTask { resultClosure in
            DispatchQueue.main.asyncAfter(deadline: .now()+6) {
                let newNumber = number + 500
                NSLog("asyncRequestStep2Task--延迟6s--%d----thread----%@", newNumber, Thread.current)
                resultClosure(AsyncResult.success(result: newNumber))
            }
        }
    }
    
    func asyncRequestStep3Task(number: Int) -> AsyncTask {
        return AsyncTask { resultClosure in
            DispatchQueue.main.asyncAfter(deadline: .now()+6) {
                let newNumber = number + 500
                NSLog("asyncRequestStep3Task--延迟6s--%d----thread----%@", newNumber, Thread.current)
                resultClosure(AsyncResult.success(result: newNumber))
            }
        }
    }

    
    func startRequest() {
        let number = 1
        Async.task { operation in
            
            let step1_1Task = self.asyncRequestStep1_1Task(number: number)
            let step1_2Task = self.asyncRequestStep1_2Task(number: number)
            let step1Results = operation.await([step1_1Task, step1_2Task])
                
            guard let step1_1Number = step1_1Task.result?.result as? Int,
                  let step1_2Number = step1_2Task.result?.result as? Int 
            else {
                // 处理错误
                return
            }
            let newNumber = step1_1Number + step1_2Number
            let step3Result = operation.await(self.asyncRequestStep3Task(number: newNumber))
            guard let step3Number = step3Result.result as? Int else {
                // 处理错误
                return
            }
            print(step3Number)
        }
    }
```

### ## [Installation](https://github.com/KKLater/Async#installation)

### [Swift Package Manager](https://github.com/KKLater/Async#swift-package-manager)

The [Swift Package Manager](https://swift.org/package-manager/) is a tool for automating the distribution of Swift code and is integrated into the `swift` compiler.

Once you have your Swift package set up, adding Async as a dependency is as easy as adding it to the `dependencies` value of your `Package.swift`.



```swift
dependencies: [
    .package(url: "https://github.com/KKLater/Async.git", .upToNextMajor(from: "0.0.1"))
]
```



## ##[License](https://github.com/KKLater/Async#license)

Async is released under the MIT license. [See LICENSE](https://github.com/KKLater/Async/blob/main/LICENSE) for details.

