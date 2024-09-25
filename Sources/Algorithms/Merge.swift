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
// MARK: MergerSubset
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
  public init(keepExclusivesToFirst: Bool, keepExclusivesToSecond: Bool,
              keepSharedElements: Bool) {
    self = switch (keepSharedElements, keepExclusivesToSecond,
                   keepExclusivesToFirst) {
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
  func expectedCountRange(given firstLength: Int, and secondLength: Int)
  -> ClosedRange<Int> {
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
// MARK: - Merging functions
//-------------------------------------------------------------------------===//

/// Given two sequences treated as (multi)sets, both sorted according to
/// a given predicate,
/// return a sequence that lazily vends the also-sorted result of applying a
/// given set operation to the sequence operands.
///
/// For simply merging the sequences, use `.sum` as the operation.
///
/// - Precondition: Both `first` and `second` must be sorted according to
///   `areInIncreasingOrder`.
///   Said predicate must model a strict weak ordering over its arguments.
///
/// - Parameters:
///   - first: The first sequence to merge.
///   - second: The second sequence to merge.
///   - filter: The subset of the merged sequence to keep.
///   - areInIncreasingOrder: The function expressing the sorting criterion.
/// - Returns: A lazy sequence for the resulting merge.
///
/// - Complexity: O(1).
public func lazilyMerge<First: Sequence, Second: Sequence>(
  _ first: First,
  _ second: Second,
  keeping filter: MergerSubset,
  sortedBy areInIncreasingOrder: @escaping (First.Element, Second.Element)
                                           -> Bool
) -> MergedSequence<First, Second, Never>
where First.Element == Second.Element {
  return .init(first, second, keeping: filter, sortedBy: areInIncreasingOrder)
}

/// Given two sorted sequences treated as (multi)sets,
/// return a sequence that lazily vends the also-sorted result of applying a
/// given set operation to the sequence operands.
///
/// For simply merging the sequences, use `.sum` as the operation.
///
/// - Precondition: Both `first` and `second` must be sorted.
///
/// - Parameters:
///   - first: The first sequence to merge.
///   - second: The second sequence to merge.
///   - filter: The subset of the merged sequence to keep.
/// - Returns: A lazy sequence for the resulting merge.
///
/// - Complexity: O(1).
@inlinable
public func lazilyMerge<First: Sequence, Second: Sequence>(
  _ first: First,
  _ second: Second,
  keeping filter: MergerSubset
) -> MergedSequence<First, Second, Never>
where First.Element == Second.Element, Second.Element: Comparable {
  return lazilyMerge(first, second, keeping: filter, sortedBy: <)
}

/// Given two sequences treated as (multi)sets, both sorted according to
/// a given predicate,
/// eagerly apply a given set operation to the sequences then copy the
/// also-sorted result into a collection of a given type.
///
/// For simply merging the sequences, use `.sum` as the operation.
///
/// - Precondition: Both `first` and `second` must be sorted according to
///   `areInIncreasingOrder`.
///   Said predicate must model a strict weak ordering over its arguments.
///   Both `first` and `second` must be finite.
///
/// - Parameters:
///   - first: The first sequence to merge.
///   - second: The second sequence to merge.
///   - type: A marker specifying the type of collection for
///     storing the result.
///   - filter: The subset of the merged sequence to keep.
///   - areInIncreasingOrder: The function expressing the sorting criterion.
/// - Returns: The resulting merge stored in a collection of the given `type`.
///
/// - Complexity:O(`n` + `m`),
///   where *n* and *m* are the lengths of `first` and `second`.
@usableFromInline
func merge<First: Sequence, Second: Sequence,
           Result: RangeReplaceableCollection, Fault: Error>(
  _ first: First,
  _ second: Second,
  into type: Result.Type,
  keeping filter: MergerSubset,
  sortedBy areInIncreasingOrder: (First.Element, Second.Element) throws(Fault)
                                 -> Bool
) throws(Fault) -> Result
where First.Element == Second.Element, Second.Element == Result.Element {
  func makeResult(
    compare: @escaping (First.Element, Second.Element) throws(Fault) -> Bool
  ) throws(Fault) -> Result {
    var result = Result()
    let sequence = MergedSequence(first, second, keeping: filter,
                                  sortedBy: compare)
    var iterator = sequence.makeIterator()
    result.reserveCapacity(sequence.underestimatedCount)
    while let element = try iterator.throwingNext() {
      result.append(element)
    }
    return result
  }

  return try withoutActuallyEscaping(areInIncreasingOrder,
                                     do: makeResult(compare:))
}

/// Returns a sorted array containing the result of the given set operation
/// applied to the given sorted sequences,
/// where sorting is determined by the given predicate.
///
/// For simply merging the sequences, use `.sum` as the operation.
///
/// - Precondition: Both `first` and `second` must be sorted according to
///   `areInIncreasingOrder`.
///   Said predicate must model a strict weak ordering over its arguments.
///   Both `first` and `second` must be finite.
///
/// - Parameters:
///   - first: The first sequence to merge.
///   - second: The second sequence to merge.
///   - filter: The subset of the merged sequence to keep.
///   - areInIncreasingOrder: The function expressing the sorting criterion.
/// - Returns: The resulting merge stored in an array.
///
/// - Complexity:O(`n` + `m`),
///   where *n* and *m* are the lengths of `first` and `second`.
@inlinable
public func merge<First: Sequence, Second: Sequence, Fault: Error>(
  _ first: First,
  _ second: Second,
  keeping filter: MergerSubset,
  sortedBy areInIncreasingOrder: (First.Element, Second.Element) throws(Fault)
                                 -> Bool
) throws(Fault) -> [Second.Element]
where First.Element == Second.Element {
  return try merge(first, second, into: Array.self, keeping: filter,
                   sortedBy: areInIncreasingOrder)
}

/// Returns a sorted array containing the result of the given set operation
/// applied to the given sorted sequences.
///
/// For simply merging the sequences, use `.sum` as the operation.
///
/// - Precondition: Both `first` and `second` must be sorted.
///   Both `first` and `second` must be finite.
///
/// - Parameters:
///   - first: The first sequence to merge.
///   - second: The second sequence to merge.
///   - filter: The subset of the merged sequence to keep.
/// - Returns: The resulting merge stored in an array.
///
/// - Complexity:O(`n` + `m`),
///   where *n* and *m* are the lengths of `first` and `second`.
@inlinable
public func merge<First: Sequence, Second: Sequence>(
  _ first: First,
  _ second: Second,
  keeping filter: MergerSubset
) -> [Second.Element]
where First.Element == Second.Element, First.Element: Comparable {
  return merge(first, second, keeping: filter, sortedBy: <)
}

//===----------------------------------------------------------------------===//
// MARK: - MergedSequence
//-------------------------------------------------------------------------===//

/// A sequence that reads from two sequences treated as (multi)sets,
/// where both sequences' elements are sorted according to some predicate,
/// and emits a sorted merger,
/// excluding any elements barred by a set operation.
public struct MergedSequence<
  First: Sequence,
  Second: Sequence,
  Fault: Error
> where First.Element == Second.Element {
  /// The elements for the first operand.
  let base1: First
  /// The elements for the second operand.
  let base2: Second
  /// The set operation to apply to the operands.
  let filter: MergerSubset
  /// The predicate with the sorting criterion.
  let areInIncreasingOrder: (Element, Element) throws(Fault) -> Bool

  /// Create a sequence that reads from the two given sequences,
  /// which will vend their merger after applying the given set operation,
  /// where both the base sequences and this sequence emit their
  /// elements sorted according to the given predicate.
  init(
    _ base1: First,
    _ base2: Second,
    keeping filter: MergerSubset,
    sortedBy areInIncreasingOrder: @escaping (Element, Element)
     throws(Fault) -> Bool
  ) {
    self.base1 = base1
    self.base2 = base2
    self.filter = filter
    self.areInIncreasingOrder = areInIncreasingOrder
  }
}

extension MergedSequence: Sequence {
  public func makeIterator(
  ) -> MergingIterator<First.Iterator, Second.Iterator, Fault> {
    return .init(base1.makeIterator(), base2.makeIterator(),
                 keeping: filter, sortedBy: areInIncreasingOrder)
  }

  public var underestimatedCount: Int {
    filter.expectedCountRange(
      given: base1.underestimatedCount,
        and: base2.underestimatedCount
    ).lowerBound
  }
}

extension MergedSequence: LazySequenceProtocol {}

//===----------------------------------------------------------------------===//
// MARK: - MergingIterator
//-------------------------------------------------------------------------===//

/// An iterator that reads from two virtual sequences treated as (multi)sets,
/// where both sequences' elements are sorted according to some predicate,
/// and emits a sorted merger,
/// excluding any elements barred by a set operation.
public struct MergingIterator<
  First: IteratorProtocol,
  Second: IteratorProtocol,
  Fault: Error
> where First.Element == Second.Element {
  /// The elements for the first operand.
  var base1: First?
  /// The elements for the second operand.
  var base2: Second?
  /// The set operation to apply to the operands.
  let filter: MergerSubset
  /// The predicate with the sorting criterion.
  let areInIncreasingOrder: (Element, Element) throws(Fault) -> Bool

  /// The latest element read from `base1`.
  fileprivate var latest1: First.Element?
  /// The latest element read from `base2`.
  fileprivate var latest2: Second.Element?
  /// Whether to continue iterating.
  fileprivate var isFinished = false

  /// Create an iterator that reads from the two given iterators,
  /// which will vend their merger after applying the given set operation,
  /// where both the base iterators and this iterator emit their
  /// elements sorted according to the given predicate.
  init(
    _ base1: First,
    _ base2: Second,
    keeping filter: MergerSubset,
    sortedBy areInIncreasingOrder: @escaping (Element, Element)
     throws(Fault) -> Bool
  ) {
    // Don't keep operand iterators that aren't needed.
    switch filter {
    case .none:
      break
    case .first:
      self.base1 = base1
    case .second:
      self.base2 = base2
    default:
      self.base1 = base1
      self.base2 = base2
    }

    // The other members.
    self.filter = filter
    self.areInIncreasingOrder = areInIncreasingOrder
  }
}

extension MergingIterator: IteratorProtocol {
  /// Advance to the next element, if any. May throw.
  fileprivate mutating func throwingNext() throws(Fault) -> First.Element? {
    while !isFinished {
      // Extract another element from a source if the previous one was purged.
      latest1 = latest1 ?? base1?.next()
      latest2 = latest2 ?? base2?.next()

      // Of the latest valid elements, purge the smaller (or both when they are
      // equivalent). Return said element if the filter permits, search again
      // otherwise.
      switch (latest1, latest2) {
      case let (latestFirst?, latestSecond?)
        where try areInIncreasingOrder(latestFirst, latestSecond):
        defer { latest1 = nil }
        guard filter.emitsExclusivesToFirst else { continue }

        return latestFirst
      case let (latestFirst?, latestSecond?)
        where try areInIncreasingOrder(latestSecond, latestFirst):
        defer { latest2 = nil }
        guard filter.emitsExclusivesToSecond else { continue }

        return latestSecond
      case (let latestFirst?, _?):
        // Purge both of the equivalent elements...
        defer {
          latest1 = nil

          // ...except when the second source's element is only deferred.
          if filter != .sum { latest2 = nil }
        }
        guard filter.emitsSharedElements else { continue }

        // This will not cause mixed-source emission when only the second
        // source is being vended, because this case won't ever be reached.
        return latestFirst
      case (nil, let latestSecond?) where filter.emitsExclusivesToSecond:
        latest2 = nil
        return latestSecond
      case (let latestFirst?, nil) where filter.emitsExclusivesToFirst:
        latest1 = nil
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
