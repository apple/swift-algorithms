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
      let sequence = MergeSortedSequence(merging: self[startIndex..<pivot],
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
// MARK: - MergerSubset
//-------------------------------------------------------------------------===//

/// Description of which elements of a merger will be retained.
public enum MergerSubset: UInt, CaseIterable {
  /// Keep no elements.
  case none
  /// Keep the elements of the first source that are not also in the second.
  case firstWithoutSecond
  /// Keep the elements of the second source that are not also in the first.
  case secondWithoutFirst
  /// Keep the elements of both sources that are not present in the other.
  case symmetricDifference
  /// Keep the elements that are present in both sorces.
  case intersection
  /// Keep only the elements from the first source.
  case first
  /// Keep only the elements from the second source.
  case second
  /// Keep all of the elements from both sources, consolidating shared ones.
  case union
  /// Keep all elements from both sources, including duplicates.
  case sum = 0b1111  // `union` with an extra bit to distinguish.
}

extension MergerSubset {
  /// Whether the elements exclusive to the first source are emitted.
  @inlinable
  public var emitsExclusivesToFirst: Bool { rawValue & 0b001 != 0 }
  /// Whether the elements exclusive to the second source are emitted.
  @inlinable
  public var emitsExclusivesToSecond: Bool { rawValue & 0b010 != 0 }
  /// Whether the elements shared by both sources are emitted.
  @inlinable
  public var emitsSharedElements: Bool { rawValue & 0b100 != 0 }
}

extension MergerSubset {
  /// Create a filter specifying a full merge (duplicating the shared elements).
  @inlinable
  public init() { self = .sum }
  /// Create a filter specifying which categories of elements are included in
  /// the merger, with shared elements consolidated.
  public init(keepExclusivesToFirst: Bool, keepExclusivesToSecond: Bool, keepSharedElements: Bool) {
    self = switch (keepSharedElements, keepExclusivesToSecond, keepExclusivesToFirst) {
    case (false, false, false): .none
    case (false, false,  true): .firstWithoutSecond
    case (false,  true, false): .secondWithoutFirst
    case (false,  true,  true): .symmetricDifference
    case ( true, false, false): .intersection
    case ( true, false,  true): .first
    case ( true,  true, false): .second
    case ( true,  true,  true): .union
    }
  }
}

extension MergerSubset {
  /// Return the worst-case bounds with the given source lengths.
  ///
  /// These non-necessarily exclusive conditions can affect the result:
  ///
  /// - One or both of the sources is empty.
  /// - The sources are identical.
  /// - The sources have no elements in common.
  /// - The shorter source is a subset of the longer one.
  /// - The sources have just partial overlap.
  ///
  /// Both inputs must be nonnegative.
  fileprivate
  func expectedCountRange(given firstLength: Int, and secondLength: Int) -> ClosedRange<Int> {
    /// Generate a range for a single value without repeating its expression.
    func singleValueRange(_ v: Int) -> ClosedRange<Int> { return v...v }

    return switch self {
    case .none:
      singleValueRange(0)
    case .firstWithoutSecond:
      max(firstLength - secondLength, 0)...firstLength
    case .secondWithoutFirst:
      max(secondLength - firstLength, 0)...secondLength
    case .symmetricDifference:
      abs(firstLength - secondLength)...(firstLength + secondLength)
    case .intersection:
      0...min(firstLength, secondLength)
    case .first:
      singleValueRange(firstLength)
    case .second:
      singleValueRange(secondLength)
    case .union:
      max(firstLength, secondLength)...(firstLength + secondLength)
    case .sum:
      singleValueRange(firstLength + secondLength)
    }
  }
}

//===----------------------------------------------------------------------===//
// MARK: - RangeReplaceableCollection.init(mergeSorted:and:retaining:sortedBy:)
//-------------------------------------------------------------------------===//

extension RangeReplaceableCollection {
  /// Given two sequences that are both sorted according to the given predicate,
  /// treat them as sets, and create the sorted result of the given set
  /// operation.
  ///
  /// For simply merging the sequences, use `.sum` as the operation.
  ///
  /// - Precondition: Both `first` and `second` must be sorted according to
  ///   `areInIncreasingOrder`, and said predicate must be a strict weak ordering
  ///   over its arguments. Both `first` and `second` must be finite.
  ///
  /// - Parameters:
  ///   - first: The first sequence spliced.
  ///   - second: The second sequence spliced.
  ///   - filter: The subset of the merged sequence to keep. If not given,
  ///     defaults to `.sum`.
  ///   - areInIncreasingOrder: The criteria for sorting.
  ///
  /// - Complexity: O(`n` + `m`) in space and time, where `n` and `m` are the
  ///   lengths of the sequence arguments.
  public init<T: Sequence, U: Sequence>(
    mergeSorted first: T,
    and second: U,
    retaining filter: MergerSubset = .sum,
    sortedBy areInIncreasingOrder: (Element, Element) throws -> Bool
  ) rethrows
  where T.Element == Element, U.Element == Element
  {
    self.init()
    try withoutActuallyEscaping(areInIncreasingOrder) {
      let sequence = MergeSortedSequence(merging: first, and: second,
                                         retaining: filter, sortedBy: $0)
      self.reserveCapacity(sequence.underestimatedCount)

      var iterator = sequence.makeIterator()
      while let current = try iterator.throwingNext() {
        self.append(current)
      }
    }
  }
}

extension RangeReplaceableCollection where Element: Comparable {
  /// Given two sorted sequences, treat them as sets, and create the sorted
  /// result of the given set operation.
  ///
  /// For simply merging the sequences, use `.sum` as the operation.
  ///
  /// - Precondition: Both `first` and `second` must be sorted, and both
  ///   must be finite.
  ///
  /// - Parameters:
  ///   - first: The first sequence spliced.
  ///   - second: The second sequence spliced.
  ///   - filter: The subset of the merged sequence to keep. If not given,
  ///     defaults to `.sum`.
  ///
  /// - Complexity: O(`n` + `m`) in space and time, where `n` and `m` are the
  ///   lengths of the sequence arguments.
  @inlinable
  public init<T: Sequence, U: Sequence>(
    mergeSorted first: T,
    and second: U,
    retaining filter: MergerSubset = .sum
  ) where T.Element == Element, U.Element == Element
  {
    self.init(mergeSorted: first, and: second, retaining: filter, sortedBy: <)
  }
}

//===----------------------------------------------------------------------===//
// MARK: - mergeSorted(_:_:retaining:sortedBy:)
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
public func mergeSorted<T: Sequence, U: Sequence>(
  _ first: T,
  _ second: U,
  retaining filter: MergerSubset = .sum,
  sortedBy areInIncreasingOrder: @escaping (T.Element, U.Element) -> Bool
) -> MergeSortedSequence<LazySequence<T>, LazySequence<U>>
where T.Element == U.Element {
  return MergeSortedSequence(
    merging: first.lazy,
    and: second.lazy,
    retaining: filter,
    sortedBy: areInIncreasingOrder
  )
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
  _ first: T, _ second: U, retaining filter: MergerSubset = .sum
) -> MergeSortedSequence<LazySequence<T>, LazySequence<U>>
where T.Element == U.Element, T.Element: Comparable {
  return mergeSorted(first, second, retaining: filter, sortedBy: <)
}

//===----------------------------------------------------------------------===//
// MARK: - MergeSortedSequence
//-------------------------------------------------------------------------===//

/// A sequence that lazily vends the sorted result of a set operation upon
/// two sorted sequences treated as sets spliced together, using a predicate as
/// the sorting criteria for all three sequences involved.
public struct MergeSortedSequence<First: Sequence, Second: Sequence>
where First.Element == Second.Element
{
  /// The first source sequence.
  let first: First
  /// The second source sequence.
  let second: Second
  /// The subset of elements to retain.
  let filter: MergerSubset
  /// The sorting predicate.
  let areInIncreasingOrder: (Element, Element) throws -> Bool

  /// Create a sequence using the two given sequences that are sorted according
  /// to the given predicate, to vend the sources' elements combined while still
  /// sorted according to the predicate, but keeping only the elements that
  /// match the given set operation.
  fileprivate init(
    merging first: First,
    and second: Second,
    retaining filter: MergerSubset,
    sortedBy areInIncreasingOrder: @escaping (Element, Element) throws -> Bool
  ) {
    self.first = first
    self.second = second
    self.filter = filter
    self.areInIncreasingOrder = areInIncreasingOrder
  }
}

extension MergeSortedSequence: Sequence {
  public func makeIterator()
  -> MergeSortedIterator<First.Iterator, Second.Iterator> {
    return .init(first.makeIterator(), second.makeIterator(), filter: filter,
                 predicate: areInIncreasingOrder)
  }

  public var underestimatedCount: Int {
    filter.expectedCountRange(
      given: first.underestimatedCount,
      and: second.underestimatedCount
    ).lowerBound
  }
}

extension MergeSortedSequence: LazySequenceProtocol {}

//===----------------------------------------------------------------------===//
// MARK: - MergeSortedIterator
//-------------------------------------------------------------------------===//

/// An iterator that applies a set operation on two virtual sequences,
/// both treated as sets sorted according a predicate, spliced together to
/// vend a virtual sequence that is also sorted.
public struct MergeSortedIterator<
   First: IteratorProtocol,
  Second: IteratorProtocol
> where First.Element == Second.Element
{
  /// The first source of elements.
  var firstSource: First?
  /// The second source of elements.
  var secondSource: Second?
  /// The subset of elements to emit.
  let filter: MergerSubset
  /// The sorting predicate.
  let areInIncreasingOrder: (Element, Element) throws -> Bool

  /// The latest element read from the first source.
  fileprivate var first: First.Element?
  /// The latest element read from the second source.
  fileprivate var second: Second.Element?
  /// Whether to keep on iterating.
  fileprivate var isFinished = false

  /// Create an iterator reading from two sources, comparing their respective
  /// elements with the predicate, and emitting the given subset of the merged
  /// sequence.
  fileprivate init(
    _ firstSource: First,
    _ secondSource: Second,
    filter: MergerSubset,
    predicate: @escaping (Element, Element) throws -> Bool
  ) {
    // Only load the sources that are actually needed.
    switch filter {
    case .none:
      break
    case .first:
      self.firstSource = firstSource
    case .second:
      self.secondSource = secondSource
    default:
      self.firstSource = firstSource
      self.secondSource = secondSource
    }

    // Other member initialization
    self.filter = filter
    self.areInIncreasingOrder = predicate
  }
}

extension MergeSortedIterator: IteratorProtocol {
  /// Advance to the next element, if any. May throw.
  fileprivate mutating func throwingNext() throws -> First.Element? {
    while !isFinished {
      // Extract another element from a source if the previous one was purged.
      first = first ?? firstSource?.next()
      second = second ?? secondSource?.next()

      // Of the latest valid elements, purge the smaller (or both when they are
      // equivalent). Return said element if the filter permits, search again
      // otherwise.
      switch (first, second) {
      case let (latestFirst?, latestSecond?) where try areInIncreasingOrder(latestFirst, latestSecond):
        defer { first = nil }
        guard filter.emitsExclusivesToFirst else { continue }

        return latestFirst
      case let (latestFirst?, latestSecond?) where try areInIncreasingOrder(latestSecond, latestFirst):
        defer { second = nil }
        guard filter.emitsExclusivesToSecond else { continue }

        return latestSecond
      case (let latestFirst?, _?):
        // Purge both of the equivalent elements...
        defer {
          first = nil

          // ...except when the second source's element is only deferred.
          if filter != .sum { second = nil }
        }
        guard filter.emitsSharedElements else { continue }

        // This will not cause mixed-source emmission when only the second
        // source is being vended, because this case won't ever be reached.
        return latestFirst
      case (nil, let latestSecond?) where filter.emitsExclusivesToSecond:
        second = nil
        return latestSecond
      case (let latestFirst?, nil) where filter.emitsExclusivesToFirst:
        first = nil
        return latestFirst
      default:
        // Either both sources are exhausted, or just one is while the remainder
        // of the other won't be emitted.
        isFinished = true
      }
    }
    return nil
  }

  public mutating func next() -> Second.Element? {
    return try! throwingNext()
  }
}
