//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift Algorithms open source project
//
// Copyright (c) 2021 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// suffix(while:)
//===----------------------------------------------------------------------===//

extension BidirectionalCollection {
  /// Returns a subsequence containing the elements from the end until
  /// `predicate` returns `false` and skipping the remaining elements.
  ///
  /// - Parameter predicate: A closure that takes an element of the
  ///   sequence as its argument and returns `true` if the element should
  ///   be included or `false` if it should be excluded. Once the predicate
  ///   returns `false` it will not be called again.
  ///
  /// - Complexity: O(*n*), where *n* is the length of the collection.
  public func suffix(
    while predicate: (Element) throws -> Bool
  ) rethrows -> SubSequence {
    let start = startIndex
    var result = endIndex
    while result != start {
      let previous = index(before: result)
      guard try predicate(self[previous]) else { break }
      result = previous
    }
    return self[result...]
  }
}
