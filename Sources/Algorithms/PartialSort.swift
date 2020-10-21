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

extension Sequence {
  /// Returns the first k elements of this collection when it's sorted using
  /// the given predicate as the comparison between elements.
  ///
  /// This example partially sorts an array of integers to retrieve its three
  /// smallest values:
  ///
  ///     let numbers = [7,1,6,2,8,3,9]
  ///     let smallestThree = numbers.sortedPrefix(3, <)
  ///     // [1, 2, 3]
  ///
  /// If you need to sort a collection but only need access to a prefix of its
  /// elements, using this method can give you a performance boost over sorting
  /// the entire collection. The order of equal elements is guaranteed to be
  /// preserved.
  ///
  /// - Parameter count: The k number of elements to partially sort.
  /// - Parameter areInIncreasingOrder: A predicate that returns true if its
  /// first argument should be ordered before its second argument;
  /// otherwise, false.
  ///
  /// - Complexity: O(k log k + nk)
  public func partiallySorted(
    _ count: Int,
    by areInIncreasingOrder: (Element, Element) throws -> Bool
  ) rethrows -> [Element] {
    var result = ContiguousArray(self)
    try result.partiallySort(count, by: areInIncreasingOrder)
    return Array(result)
  }
}

extension Sequence where Element: Comparable {
  /// Returns the first k elements of this collection when it's sorted.
  ///
  /// This example partially sorts an array of integers to retrieve its three
  /// smallest values:
  ///
  ///     let numbers = [7,1,6,2,8,3,9]
  ///     let smallestThree = numbers.sortedPrefix(<)
  ///     // [1, 2, 3]
  ///
  /// If you need to sort a sequence but only need access to a prefix of its
  /// elements, using this method can give you a performance boost over sorting
  /// the entire collection. The order of equal elements is guaranteed to be
  /// preserved.
  ///
  /// - Parameter count: The k number of elements to partially sort
  /// in ascending order.
  ///
  /// - Complexity: O(k log k + nk)
  public func partiallySorted(_ count: Int) -> [Element] {
    return partiallySorted(count, by: <)
  }
}
