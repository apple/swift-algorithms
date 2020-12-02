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

extension Collection {
  /// Returns the first k elements of this collection when it's sorted using
  /// the given predicate as the comparison between elements.
  ///
  /// This example partially sorts an array of integers to retrieve its three
  /// smallest values:
  ///
  ///     let numbers = [7,1,6,2,8,3,9]
  ///     let smallestThree = numbers.sortedPrefix(3, by: <)
  ///     // [1, 2, 3]
  ///
  /// If you need to sort a collection but only need access to a prefix of its
  /// elements, using this method can give you a performance boost over sorting
  /// the entire collection. The order of equal elements is guaranteed to be
  /// preserved.
  ///
  /// - Parameter count: The k number of elements to prefix.
  /// - Parameter areInIncreasingOrder: A predicate that returns true if its
  /// first argument should be ordered before its second argument;
  /// otherwise, false.
  ///
  /// - Complexity: O(k log k + nk)
  public func sortedPrefix(
    _ count: Int,
    by areInIncreasingOrder: (Element, Element) throws -> Bool
  ) rethrows -> [Self.Element] {
    assert(count >= 0, """
      Cannot prefix with a negative amount of elements!
      """
    )

    // Do nothing if we're prefixing nothing.
    guard count > 0 else {
      return []
    }

    // Make sure we are within bounds.
    let prefixCount = Swift.min(count, self.count)

    // If we're attempting to prefix more than 10% of the collection, it's
    // faster to sort everything.
    guard prefixCount < (self.count / 10) else {
      return Array(try sorted(by: areInIncreasingOrder).prefix(prefixCount))
    }

    var result = try self.prefix(prefixCount).sorted(by: areInIncreasingOrder)
    for e in self.dropFirst(prefixCount) {
      if let last = result.last, try areInIncreasingOrder(last, e) {
        continue
      }
      let insertionIndex =
        try result.partitioningIndex { try areInIncreasingOrder(e, $0) }
      result.removeLast()
      result.insert(e, at: insertionIndex)
    }

    return result
  }
}

extension Collection where Element: Comparable {
  /// Returns the first k elements of this collection when it's sorted in
  /// ascending order.
  ///
  /// This example partially sorts an array of integers to retrieve its three
  /// smallest values:
  ///
  ///     let numbers = [7,1,6,2,8,3,9]
  ///     let smallestThree = numbers.sortedPrefix(3)
  ///     // [1, 2, 3]
  ///
  /// If you need to sort a collection but only need access to a prefix of its
  /// elements, using this method can give you a performance boost over sorting
  /// the entire collection. The order of equal elements is guaranteed to be
  /// preserved.
  ///
  /// - Parameter count: The k number of elements to prefix.
  ///
  /// - Complexity: O(k log k + nk)
  public func sortedPrefix(_ count: Int) -> [Element] {
    return sortedPrefix(count, by: <)
  }
}
