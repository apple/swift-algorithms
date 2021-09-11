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
// stablePartition(by:)
//===----------------------------------------------------------------------===//

extension MutableCollection {
  /// Moves all elements satisfying `belongsInSecondPartition` into a suffix of
  /// the collection, preserving their relative order, and returns the start of
  /// the resulting suffix.
  ///
  /// - Complexity: O(*n* log *n*), where *n* is the number of elements.
  /// - Precondition:
  ///   `n == distance(from: range.lowerBound, to: range.upperBound)`
  @inlinable
  internal mutating func stablePartition(
    count n: Int,
    subrange: Range<Index>,
    by belongsInSecondPartition: (Element) throws -> Bool
  ) rethrows -> Index {
    if n == 0 { return subrange.lowerBound }
    if n == 1 {
      return try belongsInSecondPartition(self[subrange.lowerBound])
        ? subrange.lowerBound
        : subrange.upperBound
    }
    
    let h = n / 2, i = index(subrange.lowerBound, offsetBy: h)
    let j = try stablePartition(
      count: h,
      subrange: subrange.lowerBound..<i,
      by: belongsInSecondPartition)
    let k = try stablePartition(
      count: n - h,
      subrange: i..<subrange.upperBound,
      by: belongsInSecondPartition)
    return rotate(subrange: j..<k, toStartAt: i)
  }
  
  /// Moves all elements satisfying the given predicate into a suffix of the
  /// given range, preserving the relative order of the elements in both
  /// partitions, and returns the start of the resulting suffix.
  ///
  /// - Parameters:
  ///   - subrange: The range of elements within this collection to partition.
  ///   - belongsInSecondPartition: A predicate used to partition the
  ///     collection. All elements satisfying this predicate are ordered after
  ///     all elements not satisfying it.
  ///
  /// - Complexity: O(*n* log *n*), where *n* is the length of this collection.
  @inlinable
  public mutating func stablePartition(
    subrange: Range<Index>,
    by belongsInSecondPartition: (Element) throws-> Bool
  ) rethrows -> Index {
    try stablePartition(
      count: distance(from: subrange.lowerBound, to: subrange.upperBound),
      subrange: subrange,
      by: belongsInSecondPartition)
  }
  
  /// Moves all elements satisfying the given predicate into a suffix of this
  /// collection, preserving the relative order of the elements in both
  /// partitions, and returns the start of the resulting suffix.
  ///
  /// - Parameter belongsInSecondPartition: A predicate used to partition the
  ///   collection. All elements satisfying this predicate are ordered after
  ///   all elements not satisfying it.
  ///
  /// - Complexity: O(*n* log *n*), where *n* is the length of this collection.
  @inlinable
  public mutating func stablePartition(
    by belongsInSecondPartition: (Element) throws-> Bool
  ) rethrows -> Index {
    try stablePartition(
      subrange: startIndex..<endIndex,
      by: belongsInSecondPartition)
  }
}

//===----------------------------------------------------------------------===//
// partition(by:)
//===----------------------------------------------------------------------===//

extension MutableCollection {
  /// Moves all elements satisfying `isSuffixElement` into a suffix of the
  /// collection, returning the start position of the resulting suffix.
  ///
  /// - Complexity: O(*n*) where n is the length of the collection.
  @inlinable
  public mutating func partition(
    subrange: Range<Index>,
    by belongsInSecondPartition: (Element) throws -> Bool
  ) rethrows -> Index {
    // This version of `partition(subrange:)` is half stable; the elements in
    // the first partition retain their original relative order.
    guard var i = try self[subrange].firstIndex(where: belongsInSecondPartition)
      else { return subrange.upperBound }
    
    var j = index(after: i)
    while j != subrange.upperBound {
      if try !belongsInSecondPartition(self[j]) {
        swapAt(i, j)
        formIndex(after: &i)
      }
      formIndex(after: &j)
    }
    
    return i
  }
}

extension MutableCollection where Self: BidirectionalCollection {
  /// Moves all elements satisfying `isSuffixElement` into a suffix of the
  /// collection, returning the start position of the resulting suffix.
  ///
  /// - Complexity: O(*n*) where n is the length of the collection.
  @inlinable
  public mutating func partition(
    subrange: Range<Index>,
    by belongsInSecondPartition: (Element) throws -> Bool
  ) rethrows -> Index {
    var lo = subrange.lowerBound
    var hi = subrange.upperBound

    // 'Loop' invariants (at start of Loop, all are true):
    // * lo < hi
    // * predicate(self[i]) == false, for i in startIndex ..< lo
    // * predicate(self[i]) == true, for i in hi ..< endIndex

    Loop: while true {
      FindLo: do {
        while lo < hi {
          if try belongsInSecondPartition(self[lo]) { break FindLo }
          formIndex(after: &lo)
        }
        break Loop
      }

      FindHi: do {
        formIndex(before: &hi)
        while lo < hi {
          if try !belongsInSecondPartition(self[hi]) { break FindHi }
          formIndex(before: &hi)
        }
        break Loop
      }

      swapAt(lo, hi)
      formIndex(after: &lo)
    }

    return lo
  }
}

//===----------------------------------------------------------------------===//
// partitioningIndex(where:)
//===----------------------------------------------------------------------===//

extension Collection {
  /// Returns the index of the first element in the collection that matches
  /// the predicate.
  ///
  /// The collection must already be partitioned according to the predicate.
  /// That is, there should be an index `i` where for every element in
  /// `collection[..<i]` the predicate is `false`, and for every element in
  /// `collection[i...]` the predicate is `true`.
  ///
  /// - Parameter belongsInSecondPartition: A predicate that partitions the
  ///   collection.
  /// - Returns: The index of the first element in the collection for which
  ///   `predicate` returns `true`.
  ///
  /// - Complexity: O(log *n*), where *n* is the length of this collection if
  ///   the collection conforms to `RandomAccessCollection`, otherwise O(*n*).
  @inlinable
  public func partitioningIndex(
    where belongsInSecondPartition: (Element) throws -> Bool
  ) rethrows -> Index {
    var n = count
    var l = startIndex
    
    while n > 0 {
      let half = n / 2
      let mid = index(l, offsetBy: half)
      if try belongsInSecondPartition(self[mid]) {
        n = half
      } else {
        l = index(after: mid)
        n -= half + 1
      }
    }
    return l
  }
}

