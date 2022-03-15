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
  /// - Parameter predicate: A closure that takes an element of the sequence as
  ///   its argument and returns `true` if the element should be included or
  ///   `false` if it should be excluded. Once the predicate returns `false` it
  ///   will not be called again.
  ///
  /// - Complexity: O(*n*), where *n* is the length of the collection.
  @inlinable
  public func suffix(
    while predicate: (Element) throws -> Bool
  ) rethrows -> SubSequence {
    try self[startOfSuffix(while: predicate)...]
  }
}

//===----------------------------------------------------------------------===//
// endOfPrefix(while:)
//===----------------------------------------------------------------------===//

extension Collection {
  /// Returns the exclusive upper bound of the prefix of elements that satisfy
  /// the predicate.
  ///
  /// - Parameter predicate: A closure that takes an element of the collection
  ///   as its argument and returns `true` if the element is part of the prefix
  ///   or `false` if it is not. Once the predicate returns `false` it will not
  ///   be called again.
  ///
  /// - Complexity: O(*n*), where *n* is the length of the collection.
  @inlinable
  internal func endOfPrefix(
    while predicate: (Element) throws -> Bool
  ) rethrows -> Index {
    var index = startIndex
    while try index != endIndex && predicate(self[index]) {
      formIndex(after: &index)
    }
    return index
  }
}

//===----------------------------------------------------------------------===//
// startOfSuffix(while:)
//===----------------------------------------------------------------------===//

extension BidirectionalCollection {
  /// Returns the inclusive lower bound of the suffix of elements that satisfy
  /// the predicate.
  ///
  /// - Parameter predicate: A closure that takes an element of the collection
  ///   as its argument and returns `true` if the element is part of the suffix
  ///   or `false` if it is not. Once the predicate returns `false` it will not
  ///   be called again.
  ///
  /// - Complexity: O(*n*), where *n* is the length of the collection.
  @inlinable
  internal func startOfSuffix(
    while predicate: (Element) throws -> Bool
  ) rethrows -> Index {
    var index = endIndex
    while index != startIndex {
      let after = index
      formIndex(before: &index)
      if try !predicate(self[index]) {
        return after
      }
    }
    return index
  }
}
