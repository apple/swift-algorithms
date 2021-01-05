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
// lastIndexAsRange(where:)
//===----------------------------------------------------------------------===//

extension BidirectionalCollection {

  /// Returns an optional range, containing the last index where an element
  /// matches the given predicate; or returns `nil` if no elements match.
  ///
  /// This is equivalent to calling `lastIndex(where:)` for the lower bound,
  /// but it avoids an extra call to `index(after:)` for the upper bound.
  ///
  /// - Parameter predicate: A closure that returns a Boolean value,
  ///   indicating whether a given element represents a match.
  ///
  /// - Complexity: O(*n*), where *n* is the length of the collection.
  @inlinable
  public func lastIndexAsRange(
    where predicate: (Element) throws -> Bool
  ) rethrows -> Range<Index>? {
    var upperBound = endIndex
    while upperBound != startIndex {
      let lowerBound = index(before: upperBound)
      if try predicate(self[lowerBound]) {
        return lowerBound..<upperBound
      }
      upperBound = lowerBound
    }
    return nil
  }
}

//===----------------------------------------------------------------------===//
// lastIndexAsRange(of:)
//===----------------------------------------------------------------------===//

extension BidirectionalCollection where Element: Equatable {

  /// Returns an optional range, containing the last index of the given element;
  /// or returns `nil` if the element is not found in the collection.
  ///
  /// This is equivalent to calling `lastIndex(of:)` for the lower bound,
  /// but it avoids an extra call to `index(after:)` for the upper bound.
  ///
  /// - Parameter element: An element to search for in the collection.
  ///
  /// - Complexity: O(*n*), where *n* is the length of the collection.
  @inlinable
  public func lastIndexAsRange(
    of element: Element
  ) -> Range<Index>? {
    lastIndexAsRange(where: { $0 == element })
  }
}
