//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift Algorithms open source project
//
// Copyright (c) 2020 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// isSorted()
//===----------------------------------------------------------------------===//


extension Sequence where Element: Comparable {
    public func isSorted() -> Bool {
        /// Returns Bool, indicating whether a sequence is sorted
        /// into non-descending order.
        ///
        /// - Complexity: O(*n*), where *n* is the length of the sequence.
        
        isSorted(by: <)
    }
    
    public func isSorted(by areInIncreasingOrder: (Element, Element) -> Bool) -> Bool {
        /// Returns Bool, indicating whether a sequence is sorted using
        /// the given predicate as the comparison between elements.
        ///
        /// - Complexity: O(*n*), where *n* is the length of the sequence.
        
        var prev: Element?
        for element in self {
            if let p = prev, !areInIncreasingOrder(p, element) {
                return false
            }
            prev = element
        }
        return true
    }
    
    public func allEqual() -> Bool {
        /// Returns Bool, indicating whether all the
        /// elements in sequence are equal to each other.
        ///
        /// - Complexity: O(*n*), where *n* is the length of the sequence.

        isSorted(by: ==)
    }
}
