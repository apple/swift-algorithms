//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift Algorithms open source project
//
// Copyright (c) 2024 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// MARK: Sequence.includes(sorted:sortedBy:)
//-------------------------------------------------------------------------===//

extension Sequence {
  /// Assuming that this sequence and the given sequence are sorted according
  /// to the given predicate, determine whether the given sequence is contained
  /// within this one.
  ///
  ///     let base = [9, 8, 7, 6, 6, 3, 2, 1, 0]
  ///     assert(base.includes(sorted: [8, 7, 6, 2, 1], sortedBy: >))
  ///     assert(!base.includes(sorted: [8, 7, 5, 2, 1], sortedBy: >))
  ///
  /// The elements of the argument need not be contiguous in the receiver.
  ///
  /// - Precondition: Both the receiver and `other` must be sorted according to
  ///   `areInIncreasingOrder`, which must be a strict weak ordering over
  ///   its arguments. Either the receiver, `other`, or both must be finite.
  ///
  /// - Parameters:
  ///   - other: The sequence that is compared against the receiver.
  ///   - areInIncreasingOrder: The sorting criteria.
  /// - Returns: Whether the entirety of `other` is contained within this
  ///   sequence.
  ///
  /// - Complexity: O(*n*), where `n` is the length of the shorter sequence.
  public func includes<T: Sequence>(
    sorted other: T,
    sortedBy areInIncreasingOrder: (Element, Element) throws -> Bool
  ) rethrows -> Bool
  where T.Element == Element {
    // Originally, there was a function that evaluated the two sequences'
    // elements with respect to having elements exclusive to the receiver,
    // elements exclusive to `other`, and shared elements. But this function
    // only needs to know when an element that is exclusive to the `other` is
    // found. So, that function's guts were ripped out and repurposed.
    var firstElement, secondElement: Element?
    var iterator = makeIterator(), otherIterator = other.makeIterator()
    while true {
      firstElement = firstElement ?? iterator.next()
      secondElement = secondElement ?? otherIterator.next()
      switch (firstElement, secondElement) {
      case let (first?, second?) where try areInIncreasingOrder(first, second):
        // Found an element exclusive to `self`, move on.
        firstElement = nil
      case let (first?, second?) where try areInIncreasingOrder(second, first):
        // Found an element exclusive to `other`.
        return false
      case (_?, _?):
        // Found a shared element, move on.
        firstElement = nil
        secondElement = nil
      case (nil, _?):
        // Found an element exclusive to `other`, and any remaining elements
        // will be exclusive to `other`.
        return false
      default:
        // The elements from `other` (and possibly `self` too) have been
        // exhausted without disproving inclusion.
        return true
      }
    }
  }
}

extension Sequence where Element: Comparable {
  /// Assuming that this sequence and the given sequence are sorted,
  /// determine whether the given sequence is contained within this one.
  ///
  ///     let base = [0, 1, 2, 3, 6, 6, 7, 8, 9]
  ///     assert(base.includes(sorted: [1, 2, 6, 7, 8]))
  ///     assert(!base.includes(sorted: [1, 2, 5, 7, 8]))
  ///
  /// The elements of the argument need not be contiguous in the receiver.
  ///
  /// - Precondition: Both the receiver and `other` must be sorted.
  ///   At least one of the involved sequences must be finite.
  ///
  /// - Parameter other: The sequence that is compared against the receiver.
  /// - Returns: Whether the entirety of `other` is contained within this
  ///   sequence.
  ///
  /// - Complexity: O(*n*), where `n` is the length of the shorter sequence.
  @inlinable
  public func includes<T: Sequence>(sorted other: T) -> Bool
  where T.Element == Element {
    return includes(sorted: other, sortedBy: <)
  }
}
