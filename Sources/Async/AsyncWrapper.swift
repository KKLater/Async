//
//  AsyncWrapper.swift
//
//
//  Created by 罗树新 on 2023/11/14.
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

/// AsyncWrapper is used to add extensions to the AsyncCompatible protocol to avoid library conflicts.
///
/// ```swift
/// /// Add the AsyncCompatible protocol to String.
/// extension String: AsyncCompatible {}
///
/// /// Add extension when the AsyncWrapper generic type is String.
/// ///
/// /// ```swift
/// /// let isEmpty = "temp".async.isEmpty
/// /// ```
/// extension AsyncWrapper where Base == String {
///     var isEmpty: Bool {
///         return wrapper.isEmpty
///     }
/// }
/// ```
public struct AsyncWrapper<Base> {
    public var wrapper: Base
    init(_ wrapper: Base) {
        self.wrapper = wrapper
    }
}

public extension AsyncWrapper {
    func make(_ closure: (Base) -> Void) -> Self {
        closure(wrapper)
        return self
    }
    
    var print: Self {
        Swift.print(self)
        return self
    }
    
    var printWrapper: Self {
        Swift.print(wrapper)
        return self
    }
    
    var debugPrint: Self {
        Swift.debugPrint("⛓⛓⛓⛓⛓⛓⛓ Async DebugPrint", self)
        Swift.debugPrint("⛓⛓⛓⛓⛓⛓⛓ Async Wrapper Value", wrapper)
        return self
    }
    
    var debugPrintWrapper: Self {
        Swift.debugPrint("⛓⛓⛓⛓⛓⛓⛓ Async Wrapper Value", wrapper)
        return self
    }
}

public protocol AsyncCompatible {}
public extension AsyncCompatible {
    var async: AsyncWrapper<Self> { return AsyncWrapper(self) }
    static var async: AsyncWrapper<Self>.Type { AsyncWrapper<Self>.self }
}
