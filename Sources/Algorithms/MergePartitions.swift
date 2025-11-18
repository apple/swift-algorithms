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

extension MutableCollection where Self: BidirectionalCollection {
  /// Assuming that both this collection's slice before the given index and
  /// the slice at and past that index are both sorted according to
  /// the given predicate,
  /// rearrange the slices' elements until the collection as
  /// a whole is sorted according to the predicate.
  ///
  /// Equivalent elements retain their relative order.
  ///
  /// It may be faster to use a global `merge` function with the partitions and
  /// the sorting predicate as the arguments and then copy the
  /// sorted result back.
  ///
  /// - Precondition: The `pivot` must be a valid index of this collection.
  ///   The partitions of `startIndex..<pivot` and `pivot..<endIndex` must
  ///   be sorted according to `areInIncreasingOrder`,
  ///   which in turn must define a strict weak ordering.
  ///
  /// - Parameters:
  ///   - pivot: The index of the first element of the second partition,
  ///     or `endIndex` if said partition is empty.
  ///   - areInIncreasingOrder: A function that returns `true` only when its
  ///     first argument is ranked lower,
  ///     according to desired criteria,
  ///     than its second argument.
  /// - Postcondition: This collection is sorted,
  ///   according to the predicate's ordering criteria,
  ///   along its entire length.
  ///   If a comparison throws mid-run,
  ///   this collection will be unchanged.
  ///
  /// - Complexity: ???
  ///   (Bidirectional and random-access collections may have different values.)
  public mutating func mergePartitions<Fault>(
    across pivot: Index,
    sortedBy areInIncreasingOrder: (Element, Element) throws(Fault) -> Bool
  ) throws(Fault) {
    // The pivot needs to be an interior element.
    // (This therefore requires `self` to have a length of at least 2.)
    guard pivot > startIndex, pivot < endIndex else { return }

    // Since each major partition is already sorted, we only need to swap the
    // highest ranks of the leading partition with the lowest ranks of the
    // trailing partition.
    //
    // - Zones:  |--[1]--|--------[2]--------|------[3]------|---[4]---|
    // - Before: ...[<=p], [x > p],... [>= x]; [p],... [<= x], [> x],...
    // - After:  ...[<=p], [p],... [<= x]; [x > p],... [>= x], [> x],...
    // - Zones:  |--[1]--|------[3]------|--------[2]--------|---[4]---|
    //
    // In other words: we're swapping the positions of zones [2] and [3].
    //
    // Afterwards, the new leading partition of [1] and [3] ends up naturally
    // sorted. However, the highest ranked element of [2] may outrank
    // the lowest ranked element of [4], so the trailing partition ends up
    // needing to call this function itself.

    // Find starting index of [2].
    let lowPivot: Index
    do {
      // Among the elements before the pivot, find the reverse-earliest that has
      // at most an equivalent rank as the pivot element.
      let pivotValue = self[pivot], searchSpace = self[..<pivot].reversed()
      func atMostPivotValue(_ e: Element) throws(Fault) -> Bool {
        // e <= pivotValue → !(e > pivotValue) → !(pivotValue < e)
        return try !areInIncreasingOrder(pivotValue, e)
      }
      if case let beforeLowPivot = try searchSpace.pi(where: atMostPivotValue),
         beforeLowPivot < searchSpace.endIndex {
        // In forward space, the element after the one just found will rank
        // higher than the pivot element.
        lowPivot = beforeLowPivot.base

        // There may be no prefix elements that outrank the pivot element.
        // In other words, [2] is empty.
        // (Therefore this collection is already globally sorted.)
        guard lowPivot < pivot else { return }
      } else {
        // All the prefix elements rank higher than the pivot element.
        // In other words, [1] is empty.
        lowPivot = startIndex
      }
    }

    // Find the ending index of [3].
    let highPivot: Index
    do {
      // Find the earliest post-pivot element that ranks higher than the element
      // from the previous step. If there isn't a match, i.e. [4] is empty, the
      // entire post-pivot partition will be swapped.
      let lowPivotValue = self[lowPivot]
      func moreThanLowPivotValue(_ e: Element) throws(Fault) -> Bool {
        return try areInIncreasingOrder(lowPivotValue, e)
      }
      highPivot = try self[pivot...].pi(where: moreThanLowPivotValue)

      // [3] starts with the pivot element, so it can never be empty.
    }

    // Actually swap [2] and [3], then recur into [2] + [4].
    let exLowPivot = rotate(subrange: lowPivot..<highPivot, toStartAt: pivot)
    do {
      try self[exLowPivot...].mergePartitions(  across: highPivot,
                                              sortedBy: areInIncreasingOrder)
    } catch {
      // Undo any mutations.
      let p2 = rotate(subrange: lowPivot..<highPivot, toStartAt: exLowPivot)
      assert(p2 == pivot)
      throw error
    }
  }
}

extension MutableCollection
where Self: BidirectionalCollection, Element: Comparable {
  /// Assuming that both this collection's slice before the given index and
  /// the slice at and past that index are both sorted,
  /// rearrange the slices' elements until the collection as
  /// a whole is sorted.
  ///
  /// Equal elements retain their relative placement,
  /// *i.e.* the sorting is stable.
  ///
  /// It may be faster to use a global `merge` function with the partitions as
  /// the arguments and then copy the sorted result back.
  ///
  /// - Precondition: The `pivot` must be a valid index of this collection.
  ///   The partitions of `startIndex..<pivot` and `pivot..<endIndex` must
  ///   be sorted.
  ///
  /// - Parameters:
  ///   - pivot: The index of the first element of the second partition,
  ///     or `endIndex` if said partition is empty.
  /// - Postcondition: This collection is sorted along its entire length.
  ///
  /// - Complexity: ???
  ///   (Bidirectional and random-access collections may have different values.)
  @inlinable
  public mutating func mergePartitions(across pivot: Index) {
    mergePartitions(across: pivot, sortedBy: <)
  }
}

// - MARK: Implementation detail

extension Collection {
  /// A copy of `partitioningIndex(where:)` from "Partition.swift" that
  /// declares the exact thrown type.
  fileprivate func pi<Fault>(
    where in2nd: (Element) throws(Fault) -> Bool
  ) throws(Fault) -> Index {
    var n = count
    var l = startIndex

    while n > 0 {
      let half = n / 2
      let mid = index(l, offsetBy: half)
      if try in2nd(self[mid]) {
        n = half
      } else {
        l = index(after: mid)
        n -= half + 1
      }
    }
    return l
  }
}
