# Async
Async library based on GCD implementation. Used to replace the system Concurrency library and support its basic Task, await, and async operations in lower version systems.

# Use



The `await` behavior of scheduling tasks must be executed within the scope of an `Async.Task` closure, otherwise the task cannot be executed.

Example:

```swift
import Async
Async.Task { operation in
	
    /// 1. Add await task using closure, the result cannot be directly obtained, it needs to be obtained using a case statement.
	  let result = operation.await { resultClosure in
        resultClosure(.failure(AsyncError.resultError))
    }

    switch result {
        case .success(let success):
            print(success)
        case .failure(let error):
            print(error)
    }

    /// 2. Create a task directly or create a task using a method. Besides using a case statement to obtain data or errors, data or errors can be obtained directly through the task.
    let task = AsyncTask<Any, AsyncError> { resultClosure in
        resultClosure(.failure(AsyncError.resultError))
    }
    
    /// 
    /// func testTask() -> AsyncTask<Any, any Error> {
    ///     return AsyncTask<Any, any Error> { resultClosure in
    ///         resultClosure(.failure(AsyncError.resultError))
    ///     }
    /// }
    ///
    /// let task = testTask()
    let taskResult = operation.await(task)
    switch taskResult {
    case .success(let success):
        print(success)
    case .failure(let error):
        print(error)
    case .none:
        print("nill")
    }

    /// Obtain data and errors directly from the task
    let value = task.value
    let error = task.error
            
    /// 3. In addition to using AsyncTask to create tasks, you can also conform to AsyncTaskType to customize tasks for consistent behavior in a series of tasks.
    /// Refer to AsyncTaskType for more details.
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

