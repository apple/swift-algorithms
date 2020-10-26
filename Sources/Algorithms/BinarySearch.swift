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
// someSortedPosition(of: by:)
//===----------------------------------------------------------------------===//

extension Collection {
  /// Returns where the given value may appear in the collection, assuming the
  /// collection is (at least) partitioned along the given predicate used for
  /// comparing between elements.
  ///
  /// A fully sorted sequence meets the criteria of the partitioning implied in
  /// the precondition.
  ///
  /// If the return value flags a non-match, the emitted index is the best
  /// position where `target` may be inserted and let the collection maintain
  /// its values' (semi-)sort.
  ///
  /// - Precondition:
  ///   - All of the elements equivalent to `target` are in a contiguous
  ///     subsequence.
  ///   - All of the elements ordered less than `target` form a (possibly empty)
  ///     prefix of the collection.  These elements are not necessarily sorted
  ///     within this subsequence.
  ///   - All of the elements ordered greater than `target` form a (possibly
  ///     empty) suffix of the collection.  These elements are not necessarily
  ///     sorted within this subsequence.
  ///
  /// - Parameters:
  ///   - target: An element to search for in the collection.
  ///   - areInIncreasingOrder: A predicate that returns `true` if its first
  ///     argument should be ordered before its second argument; otherwise,
  ///     `false`.
  /// - Returns: A two-element tuple.  The first member is the first possible of
  ///   the following: an index into this collection for an element that is
  ///   equivalent to `target`, the index for the first element that is ordered
  ///   greater than `target`, or `endIndex`.  The second member indicates
  ///   whether the first member points to an equivalent element.
  ///
  /// - Complexity: O(log *n*), where *n* is the length of this collection if
  ///   the collection conforms to `RandomAccessCollection`, otherwise O(*n*).
  public func someSortedPosition(
    of target: Element,
    by areInIncreasingOrder: (Element, Element) throws -> Bool
  ) rethrows -> (index: Index, isMatch: Bool) {
    var span = count, start = startIndex, end = endIndex
    while start < end {
      let semispan = span / 2, pivot = index(start, offsetBy: semispan)
      let candidate = self[pivot]
      if try areInIncreasingOrder(candidate, target) {
        // Too small; check the larger values in the suffix.
        start = index(after: pivot)
        span -= semispan + 1
      } else if try areInIncreasingOrder(target, candidate) {
        // Too large; check the smaller values in the prefix.
        end = pivot
        span = semispan
      } else {
        // Just right!
        return (pivot, true)
      }
    }
    assert(span == 0)
    return (end, false)
  }
}

//===----------------------------------------------------------------------===//
// lowerSortedBound(around: by:)
//===----------------------------------------------------------------------===//

extension Collection {
  /// Assuming the collection is (at least) partitioned along the given
  /// predicate used for comparing between elements, returns the starting index
  /// for the contiguous subsequence containing the elements equivalent to the
  /// one at the given index.
  ///
  /// A fully sorted sequence meets the criteria of the partitioning implied
  /// within the precondition.
  ///
  /// - Precondition:
  ///   - `match` is a valid index of the collection, but less than `endIndex`.
  ///   - All of the elements equivalent to `self[match]` are in a contiguous
  ///     subsequence.
  ///   - All of the elements ordered less than `self[match]` form a (possibly
  ///     empty) prefix of the collection.  These elements are not necessarily
  ///     sorted within this subsequence.
  ///   - All of the elements ordered greater than `self[match]` form a
  ///     (possibly empty) suffix of the collection.  These elements are not
  ///     necessarily sorted within this subsequence.
  ///
  /// - Parameters:
  ///   - match: An index for the value to be bound within the collection.
  ///   - areInIncreasingOrder: A predicate that returns `true` if its first
  ///     argument should be ordered before its second argument; otherwise,
  ///     `false`.
  /// - Returns: The index for the first element of the collection equivalent to
  ///   `self[match]`.  May be `match` itself.
  ///
  /// - Complexity: O(log *m*), where *m* is the distance between `startIndex`
  ///   and `match` if the collection conforms to `RandomAccessCollection`,
  ///   otherwise O(*m*).
  @inlinable
  public func lowerSortedBound(
    around match: Index,
    by areInIncreasingOrder: (Element, Element) throws -> Bool
  ) rethrows -> Index {
    let target = self[match]
    return try self[...match].partitioningIndex { try !areInIncreasingOrder($0, target) }
  }
}

//===----------------------------------------------------------------------===//
// upperSortedBound(around: by:)
//===----------------------------------------------------------------------===//

extension Collection {
  /// Assuming the collection is (at least) partitioned along the given
  /// predicate used for comparing between elements, returns the past-the-end
  /// index for the contiguous subsequence containing the elements equivalent to
  /// the one at the given index.
  ///
  /// A fully sorted sequence meets the criteria of the partitioning implied
  /// within the precondition.
  ///
  /// - Precondition:
  ///   - `match` is a valid index of the collection, but less than `endIndex`.
  ///   - All of the elements equivalent to `self[match]` are in a contiguous
  ///     subsequence.
  ///   - All of the elements ordered less than `self[match]` form a (possibly
  ///     empty) prefix of the collection.  These elements are not necessarily
  ///     sorted within this subsequence.
  ///   - All of the elements ordered greater than `self[match]` form a
  ///     (possibly empty) suffix of the collection.  These elements are not
  ///     necessarily sorted within this subsequence.
  ///
  /// - Parameters:
  ///   - match: An index for the value to be bound within the collection.
  ///   - areInIncreasingOrder: A predicate that returns `true` if its first
  ///     argument should be ordered before its second argument; otherwise,
  ///     `false`.
  /// - Returns: The index for the first element that is ordered greater than
  ///   `self[match]`.  If there is no such element, `endIndex` is returned
  ///   instead.
  ///
  /// - Complexity: O(log *m*), where *m* is the distance between `match` and
  ///   `endIndex` if the collection conforms to `RandomAccessCollection`,
  ///   otherwise O(*m*).
  @inlinable
  public func upperSortedBound(
    around match: Index,
    by areInIncreasingOrder: (Element, Element) throws -> Bool
  ) rethrows -> Index {
    let target = self[match]
    return try self[match...].partitioningIndex { try areInIncreasingOrder(target, $0) }
  }
}

//===----------------------------------------------------------------------===//
// sortedRange(for: by:)
//===----------------------------------------------------------------------===//

extension Collection {
  /// Returns the bounds for the contiguous subsequence of all the elements
  /// equivalent to the given value, assuming the collection is (at least)
  /// partitioned along the given predicate used for comparing between elements.
  ///
  /// A fully sorted sequence meets the criteria of the partitioning implied in
  /// the precondition.
  ///
  /// If no matches are found, the returned empty range hovers over the best
  /// position where `target` may be inserted and let the collection maintain
  /// its values' (semi-)sort.
  ///
  /// - Precondition:
  ///   - All of the elements equivalent to `target` are in a contiguous
  ///     subsequence.
  ///   - All of the elements ordered less than `target` form a (possibly empty)
  ///     prefix of the collection.  These elements are not necessarily sorted
  ///     within this subsequence.
  ///   - All of the elements ordered greater than `target` form a (possibly
  ///     empty) suffix of the collection.  These elements are not necessarily
  ///     sorted within this subsequence.
  ///
  /// - Parameters:
  ///   - target: An element to search for in the collection.
  ///   - areInIncreasingOrder: A predicate that returns `true` if its first
  ///     argument should be ordered before its second argument; otherwise,
  ///     `false`.
  /// - Returns: A range for the shortest subsequence containing all the
  ///   elements equivalent to `target`.  The range always ends at the first
  ///   possible of the following: the first element ordered greater than
  ///   `target`, or `endIndex`.  The returned range will be empty if there are
  ///   no matches.
  ///
  /// - Complexity: O(log *n*), where *n* is the length of this collection if
  ///   the collection conforms to `RandomAccessCollection`, otherwise O(*n*).
  public func sortedRange(
    for target: Element,
    by areInIncreasingOrder: (Element, Element) throws -> Bool
  ) rethrows -> Range<Index> {
    let (match, success) = try someSortedPosition(of: target, by: areInIncreasingOrder)
    guard success else { return match..<match }

    let low = try lowerSortedBound(around: match, by: areInIncreasingOrder),
        high = try upperSortedBound(around: match, by: areInIncreasingOrder)
    return low..<high
  }
}

//===----------------------------------------------------------------------===//
// someSortedPosition(of:)
// lowerSortedBound(around:)
// upperSortedBound(around:)
// sortedRange(for:)
//===----------------------------------------------------------------------===//

extension Collection where Element: Comparable {
  /// Returns where the given value may appear in the collection, assuming the
  /// collection is (at least) partitioned along the relative order each element
  /// has to that value.
  ///
  /// A fully sorted sequence meets the criteria of the partitioning implied in
  /// the precondition.
  ///
  /// If the return value flags a non-match, the emitted index is the best
  /// position where `target` may be inserted and let the collection maintain
  /// its values' (semi-)sort.
  ///
  /// - Precondition:
  ///   - All of the elements equal to `target` are in a contiguous subsequence.
  ///   - All of the elements less than `target` form a (possibly empty) prefix
  ///     of the collection.  These elements are not necessarily sorted within
  ///     this subsequence.
  ///   - All of the elements greater than `target` form a (possibly empty)
  ///     suffix of the collection.  These elements are not necessarily sorted
  ///     within this subsequence.
  ///
  /// - Parameters:
  ///   - target: An element to search for in the collection.
  /// - Returns: A two-element tuple.  The first member is the first possible of
  ///   the following: an index into this collection for an element that is
  ///   equal to `target`, the index for the first element that is greater than
  ///   `target`, or `endIndex`.  The second member indicates whether the first
  ///   member points to an equal element.
  ///
  /// - Complexity: O(log *n*), where *n* is the length of this collection if
  ///   the collection conforms to `RandomAccessCollection`, otherwise O(*n*).
  @inlinable
  public func someSortedPosition(
    of target: Element
  ) -> (index: Index, isMatch: Bool) {
    return someSortedPosition(of: target, by: <)
  }

  /// Assuming the collection is (at least) partitioned along the relative order
  /// each element has to the value at the given index, returns the starting
  /// index for the contiguous subsequence containing the elements equal to that
  /// value.
  ///
  /// A fully sorted sequence meets the criteria of the partitioning implied
  /// within the precondition.
  ///
  /// - Precondition:
  ///   - `match` is a valid index of the collection, but less than `endIndex`.
  ///   - All of the elements equal to `self[match]` are in a contiguous
  ///     subsequence.
  ///   - All of the elements less than `self[match]` form a (possibly empty)
  ///     prefix of the collection.  These elements are not necessarily sorted
  ///     within this subsequence.
  ///   - All of the elements greater than `self[match]` form a (possible empty)
  ///     suffix of the collection.  These elements are not necessarily sorted
  ///     within this subsequence.
  ///
  /// - Parameters:
  ///   - match: An index for the value to be bound within the collection.
  /// - Returns: The index for the first element of the collection equal to
  ///   `self[match]`.  May be `match` itself.
  ///
  /// - Complexity: O(log *m*), where *m* is the distance between `startIndex`
  ///   and `match` if the collection conforms to `RandomAccessCollection`,
  ///   otherwise O(*m*).
  @inlinable public func lowerSortedBound(around match: Index) -> Index {
    return lowerSortedBound(around: match, by: <)
  }

  /// Assuming the collection is (at least) partitioned along the relative order
  /// each element has to the value at the given index, returns the past-the-end
  /// index for the contiguous subsequence containing the elements equal to that
  /// value.
  ///
  /// A fully sorted sequence meets the criteria of the partitioning implied
  /// within the precondition.
  ///
  /// - Precondition:
  ///   - `match` is a valid index of the collection, but less than `endIndex`.
  ///   - All of the elements equal to `self[match]` are in a contiguous
  ///     subsequence.
  ///   - All of the elements less than `self[match]` form a (possibly empty)
  ///     prefix of the collection.  These elements are not necessarily sorted
  ///     within this subsequence.
  ///   - All of the elements greater than `self[match]` form a (possibly empty)
  ///     suffix of the collection.  These elements are not necessarily sorted
  ///     within this subsequence.
  ///
  /// - Parameters:
  ///   - match: An index for the value to be bound within the collection.
  /// - Returns: The index for the first element greater than `self[match]`.  If
  ///   there is no such element, `endIndex` is returned instead.
  ///
  /// - Complexity: O(log *m*), where *m* is the distance between `match` and
  ///   `endIndex` if the collection conforms to `RandomAccessCollection`,
  ///   otherwise O(*m*).
  @inlinable public func upperSortedBound(around match: Index) -> Index {
    return upperSortedBound(around: match, by: <)
  }

  /// Returns the bounds for the contiguous subsequence of all the elements
  /// equal to the given value, assuming the collection is (at least)
  /// partitioned along the relative order each element has to that value.
  ///
  /// A fully sorted sequence meets the criteria of the partitioning implied in
  /// the precondition.
  ///
  /// If no matches are found, the returned empty range hovers over the best
  /// position where `target` may be inserted and let the collection maintain
  /// its values' (semi-)sort.
  ///
  /// - Precondition:
  ///   - All of the elements equal to `target` are in a contiguous subsequence.
  ///   - All of the elements less than `target` form a (possibly empty) prefix
  ///     of the collection.  These elements are not necessarily sorted within
  ///     this subsequence.
  ///   - All of the elements greater than `target` form a (possibly empty)
  ///     suffix of the collection.  These elements are not necessarily sorted
  ///     within this subsequence.
  ///
  /// - Parameters:
  ///   - target: An element to search for in the collection.
  /// - Returns: A range for the shortest subsequence containing all the
  ///   elements equal to `target`.  The range always ends at the first possible
  ///   of the following: the first element greater than `target`, or
  ///   `endIndex`.  The returned range will be empty if there are no matches.
  ///
  /// - Complexity: O(log *n*), where *n* is the length of this collection if
  ///   the collection conforms to `RandomAccessCollection`, otherwise O(*n*).
  @inlinable public func sortedRange(for target: Element) -> Range<Index> {
    return sortedRange(for: target, by: <)
  }
}
