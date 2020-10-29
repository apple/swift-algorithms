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
// sortedEndIndex(by:)
//===----------------------------------------------------------------------===//

extension Collection {
  /// Returns the past-the-end index for the longest prefix of the collection
  /// that is sorted according to the given predicate used for comparisons
  /// between elements.
  ///
  /// If `endIndex` is returned, then the entire collection is sorted.
  /// Sequences shorter than two elements in length are always completely
  /// sorted.
  ///
  /// - Parameter areInIncreasingOrder: A predicate that returns `true` if its
  ///   first argument should be ordered before its second argument; otherwise,
  ///   `false`.
  /// - Returns: The index of the first element that is in decreasing order
  ///   relative to its predecessor.  If there is no such element, `endIndex` is
  ///   returned instead.
  ///
  /// - Complexity: O(*n*), where *n* is the length of the collection.
  public func sortedEndIndex(
    by areInIncreasingOrder: (Element, Element) throws -> Bool
  ) rethrows -> Index {
    let end = endIndex
    guard var previousValue = first else { return end }

    var currentIndex = index(after: startIndex)
    while currentIndex < end,
          case let currentValue = self[currentIndex],
          try !areInIncreasingOrder(currentValue, previousValue) {
      previousValue = currentValue
      formIndex(after: &currentIndex)
    }
    return currentIndex
  }
}

//===----------------------------------------------------------------------===//
// rampedEndIndex(by:)
//===----------------------------------------------------------------------===//

extension Collection {
  /// Returns the past-the-end index for the longest prefix of the collection
  /// with strictly increasing values according to the given predicate used for
  /// comparisons between elements.
  ///
  /// If `endIndex` is returned, then the entire collection is strictly
  /// increasing (and sorted).  Sequences shorter than two elements in length
  /// always have complete coverage in being strictly increasing.
  ///
  /// - Parameter areInIncreasingOrder: A predicate that returns `true` if its
  ///   first argument should be ordered before its second argument; otherwise,
  ///   `false`.
  /// - Returns: The index of the first element that is not in increasing order
  ///   relative to its predecessor.  If there is no such element, `endIndex` is
  ///   returned instead.
  ///
  /// - Complexity: O(*n*), where *n* is the length of the collection.
  public func rampedEndIndex(
    by areInIncreasingOrder: (Element, Element) throws -> Bool
  ) rethrows -> Index {
    let end = endIndex
    guard var previousValue = first else { return end }

    var currentIndex = index(after: startIndex)
    while currentIndex < end,
          case let currentValue = self[currentIndex],
          try areInIncreasingOrder(previousValue, currentValue) {
      previousValue = currentValue
      formIndex(after: &currentIndex)
    }
    return currentIndex
  }
}

//===----------------------------------------------------------------------===//
// firstVariance(by:)
//===----------------------------------------------------------------------===//

extension Collection {
  /// Returns the index of the earliest element not equivalent to the first
  /// element, using the given predicate as the equivalence test.
  ///
  /// The predicate must be a *equivalence relation* over the elements. That
  /// is, for any elements `a`, `b`, and `c`, the following conditions must
  /// hold:
  ///
  /// - `areEquivalent(a, a)` is always `true`. (Reflexivity)
  /// - `areEquivalent(a, b)` implies `areEquivalent(b, a)`. (Symmetry)
  /// - If `areEquivalent(a, b)` and `areEquivalent(b, c)` are both `true`, then
  ///   `areEquivalent(a, c)` is also `true`. (Transitivity)
  ///
  /// Returns `endIndex` if the collection is shorter than two elements.
  ///
  /// - Parameter areEquivalent: A predicate that returns `true` if its two
  ///   arguments are equivalent; otherwise, `false`.
  /// - Returns: The index for the first element *x* in `dropFirst()` such that
  ///   `areEquivalent(first!, x)` is `false`.  If there is no such element,
  ///   `endIndex` is returned instead.
  ///
  /// - Complexity: O(*n*), where *n* is the length of the collection.
  @inlinable
  public func firstVariance(
    by areEquivalent: (Element, Element) throws -> Bool
  ) rethrows -> Index {
    guard let target = first else { return endIndex }

    return try dropFirst().indexed().first(where: {
      try !areEquivalent(target, $0.element)
    })?.index ?? endIndex
  }
}

//===----------------------------------------------------------------------===//
// sortedEndIndex()
// rampedEndIndex()
//===----------------------------------------------------------------------===//

extension Collection where Element: Comparable {
  /// Returns the past-the-end index for the longest prefix of the collection
  /// that is sorted.
  ///
  /// If `endIndex` is returned, then the entire collection is sorted.
  /// Sequences shorter than two elements in length are always completely
  /// sorted.
  ///
  /// - Returns: The index of the first element that is less than its
  ///   predecessor.  If there is no such element, `endIndex` is returned
  ///   instead.
  ///
  /// - Complexity: O(*n*), where *n* is the length of the collection.
  @inlinable
  public func sortedEndIndex() -> Index { return sortedEndIndex(by: <) }

  /// Returns the past-the-end index for the longest prefix of the collection
  /// with strictly increasing elements.
  ///
  /// If `endIndex` is returned, then the entire collection is strictly
  /// increasing (and sorted).  Sequences shorter than two elements in length
  /// always have complete coverage in being strictly increasing.
  ///
  /// - Returns: The index of the first element that is less than or equal to
  ///   its predecessor.  If there is no such element, `endIndex` is returned
  ///   instead.
  ///
  /// - Complexity: O(*n*), where *n* is the length of the collection.
  @inlinable
  public func rampedEndIndex() -> Index { return rampedEndIndex(by: <) }
}

//===----------------------------------------------------------------------===//
// firstVariance()
//===----------------------------------------------------------------------===//

extension Collection where Element: Equatable {
  /// Returns the index of the earliest element not equal to the first one.
  ///
  /// Returns `endIndex` if the collection is shorter than two elements.
  ///
  /// - Returns: The index for the first element *x* in `dropFirst()` such that
  ///   `first! == x` is `false`.  If there is no such element, `endIndex` is
  ///   returned instead.
  ///
  /// - Complexity: O(*n*), where *n* is the length of the collection.
  @inlinable
  public func firstVariance() -> Index { return firstVariance(by: ==) }
}
