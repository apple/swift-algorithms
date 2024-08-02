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
// MARK: MutableCollection.mergeSortedPartitions(across:sortedBy:)
//-------------------------------------------------------------------------===//

extension MutableCollection {
  /// Given a partition point,
  /// where each side is sorted according to the given predicate,
  /// rearrange the elements until a single sorted run is formed.
  ///
  /// Equivalent elements from a given partition have stable ordering in
  /// the unified sequence.
  ///
  /// - Precondition: The `pivot` must be a valid index of this collection.
  ///   The partitions of `startIndex..<pivot` and `pivot..<endIndex` must be
  ///   sorted according to `areInIncreasingOrder`,
  ///   and said predicate must be a strict weak ordering.
  ///
  /// - Parameters:
  ///   - pivot: The index of the first element of the second partition,
  ///     or `endIndex` if said partition is empty.
  ///   - areInIncreasingOrder: The criteria for sorting.
  ///
  /// - Complexity: O(*n*) in space and time, where `n` is the length of
  ///   the collection.
  public mutating func mergeSortedPartitions(
    across pivot: Index,
    sortedBy areInIncreasingOrder: (Element, Element) throws -> Bool
  ) rethrows {
    var duplicate = self
    try withoutActuallyEscaping(areInIncreasingOrder) {
      let sequence = MergeSortedSetsSequence(merging: self[startIndex..<pivot],
                     and: self[pivot..<endIndex], retaining: .sum, sortedBy: $0)
      var iterator = sequence.makeIterator()
      var duplicateIndex = duplicate.startIndex
      while let current = try iterator.throwingNext() {
        defer { duplicate.formIndex(after: &duplicateIndex) }

        duplicate[duplicateIndex] = current
      }
      assert(duplicateIndex == duplicate.endIndex)
    }
    self = duplicate
  }
}

extension MutableCollection where Element: Comparable {
  /// Given a partition point, where each side is sorted,
  /// rearrange the elements until a single sorted run is formed.
  ///
  /// Equal elements from a given partition have stable ordering in
  /// the unified sequence.
  ///
  /// - Precondition: The `pivot` must be a valid index of this collection,
  ///   where the partitions of `startIndex..<pivot` and
  ///   `pivot..<endIndex` must be sorted.
  ///
  /// - Parameter pivot: The index of the first element of the second partition,
  ///   or `endIndex` if said partition is empty.
  ///
  /// - Complexity: O(*n*) in space and time, where `n` is the length of
  ///   the collection.
  @inlinable
  public mutating func mergeSortedPartitions(across pivot: Index) {
    return mergeSortedPartitions(across: pivot, sortedBy: <)
  }
}

//===----------------------------------------------------------------------===//
// MARK: - MutableCollection.mergeSortedPartitionsInPlace(across:sortedBy:)
//-------------------------------------------------------------------------===//

extension MutableCollection where Self: BidirectionalCollection {
  /// Given a partition point,
  /// where each side is sorted according to the given predicate,
  /// rearrange the elements until a single sorted run is formed,
  /// using minimal scratch memory.
  ///
  /// Equivalent elements from a given partition have stable ordering in
  /// the unified sequence.
  ///
  /// - Precondition: The `pivot` must be a valid index of this collection.
  ///   The partitions of `startIndex..<pivot` and `pivot..<endIndex` must be
  ///   sorted according to `areInIncreasingOrder`,
  ///   and said predicate must be a strict weak ordering.
  ///
  /// - Parameters:
  ///   - pivot: The index of the first element of the second partition,
  ///     or `endIndex` if said partition is empty.
  ///   - areInIncreasingOrder: The criteria for sorting.
  /// - Postcondition: The entire run of the receiver's elements are sorted
  ///   according to `areInIncreasingOrder`. If a comparison throws mid-run,
  ///   this collection will be unchanged.
  ///
  /// - Complexity: ??? (2 cases: bidirectional vs random-access)
  public mutating func mergeSortedPartitionsInPlace(
    across pivot: Index,
    sortedBy areInIncreasingOrder: (Element, Element) throws -> Bool
  ) rethrows {
    // The pivot needs to be an interior element.
    // (This therefore requires `self` to have a length of at least 2.)
    guard pivot > startIndex, pivot < endIndex else { return }

    // Since each major partition is already sorted, we only need to swap the
    // highest ranks of the starting partition with the lowest ranks of the
    // trailing partition.
    //
    // - Zones:  |--[1]--|--------[2]--------|------[3]------|---[4]---|
    // - Before: ...[<=p], [x > p],... [>= x]; [p],... [<= x], [> x],...
    // - After:  ...[<=p], [p],... [<= x]; [x > p],... [>= x], [> x],...
    // - Zones:  |--[1]--|------[3]------|--------[2]--------|---[4]---|
    //
    // In other words: we're swapping the positions of zones [2] and [3].
    //
    // Afterwards, the new starting partition of [1] and [3] ends up naturally
    // sorted. However, the highest ranked element of [2] may rank higher than
    // the lowest ranked element of [4], so the trailing partition ends up
    // needing to call this function itself.

    // Find starting index of [2].
    let lowPivot: Index
    do {
      // Among the elements before the pivot, find the reverse-earliest that has
      // at most an equivalent rank as the pivot element.
      let pivotValue = self[pivot], searchSpace = self[..<pivot].reversed()
      if case let beforeLowPivot = try searchSpace.partitioningIndex(where: {
        // $0 <= pivotValue → !($0 > pivotValue) → !(pivotValue < $0)
        return try !areInIncreasingOrder(pivotValue, $0)
      }),
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
      highPivot = try self[pivot...].partitioningIndex {
        try areInIncreasingOrder(lowPivotValue, $0)
      }
    }
    // [3] starts with the pivot element, so it can never be empty.

    // Actually swap [2] and [3], then compare [2] and [4].
    let exLowPivot = rotate(subrange: lowPivot..<highPivot, toStartAt: pivot)
    do {
      try self[exLowPivot...].mergeSortedPartitionsInPlace(
          across: highPivot,
        sortedBy: areInIncreasingOrder
      )
    } catch {
      // Undo the mutations applied earlier in the current call.
      let pivotAgain = rotate( subrange: lowPivot..<highPivot,
                              toStartAt: exLowPivot)
      assert(pivotAgain == pivot)
      throw error
    }
  }
}

extension MutableCollection
where Element: Comparable, Self: BidirectionalCollection {
  /// Given a partition point, where each side is sorted,
  /// rearrange the elements until a single sorted run is formed,
  /// using minimal scratch memory.
  ///
  /// Equal elements from a given partition have stable ordering in
  /// the unified sequence.
  ///
  /// - Precondition: The `pivot` must be a valid index of this collection,
  ///   where the partitions of `startIndex..<pivot` and
  ///   `pivot..<endIndex` must be sorted.
  ///
  /// - Parameter pivot: The index of the first element of the second partition,
  ///   or `endIndex` if said partition is empty.
  ///
  /// - Complexity: ???
  @inlinable
  public mutating func mergeSortedPartitionsInPlace(across pivot: Index) {
    return mergeSortedPartitionsInPlace(across: pivot, sortedBy: <)
  }
}

//===----------------------------------------------------------------------===//
// MARK: - RangeReplaceableCollection.init(mergeSorted:and:sortedBy:)
//-------------------------------------------------------------------------===//

extension RangeReplaceableCollection {
  /// Given two sequences that are both sorted according to the given predicate,
  /// create their sorted merger.
  ///
  /// - Precondition: Both `first` and `second` must be sorted according to
  ///   `areInIncreasingOrder`, and said predicate must be a strict weak ordering
  ///   over its arguments. Both `first` and `second` must be finite.
  ///
  /// - Parameters:
  ///   - first: The first sequence spliced.
  ///   - second: The second sequence spliced.
  ///   - areInIncreasingOrder: The criteria for sorting.
  ///
  /// - Complexity: O(`n` + `m`) in space and time, where `n` and `m` are the
  ///   lengths of the sequence arguments.
  @inlinable
  public init<T: Sequence, U: Sequence>(
    mergeSorted first: T,
    and second: U,
    sortedBy areInIncreasingOrder: (Element, Element) throws -> Bool
  ) rethrows
  where T.Element == Element, U.Element == Element
  {
    try self.init(mergeSorted: first, and: second, retaining: .sum, sortedBy: areInIncreasingOrder)
  }
}

extension RangeReplaceableCollection where Element: Comparable {
  /// Given two sorted sequences, create their sorted merger.
  ///
  /// - Precondition: Both `first` and `second` must be sorted, and both
  ///   must be finite.
  ///
  /// - Parameters:
  ///   - first: The first sequence spliced.
  ///   - second: The second sequence spliced.
  ///
  /// - Complexity: O(`n` + `m`) in space and time, where `n` and `m` are the
  ///   lengths of the sequence arguments.
  @inlinable
  public init<T: Sequence, U: Sequence>(
    mergeSorted first: T,
    and second: U
  ) where T.Element == Element, U.Element == Element
  {
    self.init(mergeSorted: first, and: second, sortedBy: <)
  }
}

//===----------------------------------------------------------------------===//
// MARK: - mergeSorted(_:_:sortedBy:)
//-------------------------------------------------------------------------===//

/// Given two sequences that are both sorted according to the given predicate
/// and treated as sets, apply the given set operation, returning the result as
/// a lazy sequence also sorted by the same predicate.
///
/// For simply merging the sequences, use `.sum` as the operation.
///
/// - Precondition: Both `first` and `second` must be sorted according to
///   `areInIncreasingOrder`, and said predicate must be a strict weak ordering
///   over its arguments.
///
/// - Parameters:
///   - first: The first sequence spliced.
///   - second: The second sequence spliced.
///   - filter: The subset of the merged sequence to keep. If not given,
///     defaults to `.sum`.
///   - areInIncreasingOrder: The criteria for sorting.
/// - Returns: A sequence that lazily generates the merged sequence subset.
///
/// - Complexity: O(1). The actual iteration takes place in O(`n` + `m`),
///   where `n` and `m` are the lengths of the sequence arguments.
@inlinable
public func mergeSorted<T: Sequence, U: Sequence>(
  _ first: T,
  _ second: U,
  sortedBy areInIncreasingOrder: @escaping (T.Element, U.Element) -> Bool
) -> MergeSortedSetsSequence<LazySequence<T>, LazySequence<U>>
where T.Element == U.Element {
  return mergeSortedSets(first, second, retaining: .sum, sortedBy: areInIncreasingOrder)
}

/// Given two sorted sequences treated as sets, apply the given set operation,
/// returning the result as a sorted lazy sequence.
///
/// For simply merging the sequences, use `.sum` as the operation.
///
/// - Precondition: Both `first` and `second` must be sorted.
///
/// - Parameters:
///   - first: The first sequence spliced.
///   - second: The second sequence spliced.
///   - filter: The subset of the merged sequence to keep. If not given,
///     defaults to `.sum`.
/// - Returns: A sequence that lazily generates the merged sequence subset.
///
/// - Complexity: O(1). The actual iteration takes place in O(`n` + `m`),
///   where `n` and `m` are the lengths of the sequence arguments.
@inlinable
public func mergeSorted<T: Sequence, U: Sequence>(
  _ first: T, _ second: U
) -> MergeSortedSetsSequence<LazySequence<T>, LazySequence<U>>
where T.Element == U.Element, T.Element: Comparable {
  return mergeSorted(first, second, sortedBy: <)
}
