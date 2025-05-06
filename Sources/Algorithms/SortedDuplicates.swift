//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift Algorithms open source project
//
// Copyright (c) 2025 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

extension Sequence {
  /// Assuming this sequence is already sorted along the given predicate,
  /// return a collection of the given type,
  /// storing the first occurance of each unique element value in
  /// this sequence paired with its total number of occurances.
  ///
  /// - Precondition: This sequence must be finite,
  ///   and be sorted according to the given predicate.
  ///
  /// - Parameter type: A reference to the returned collection's type.
  /// - Parameter areInIncreasingOrder: The sorting predicate.
  /// - Returns: A collection of pairs,
  ///   one for each element equivalence class present in this sequence,
  ///   in order of appearance.
  ///   The first member is the value of the earliest element for
  ///   an equivalence class.
  ///   The second member is the number of occurances of that
  ///   equivalence class.
  ///
  /// - Complexity: O(`n`), where *n* is the length of this sequence.
  @usableFromInline
  func countSortedDuplicates<T>(
    storingIn type: T.Type,
    by areInIncreasingOrder: (Element, Element) throws -> Bool
  ) rethrows -> T
  where T: RangeReplaceableCollection, T.Element == (value: Element, count: Int)
  {
    try withoutActuallyEscaping(areInIncreasingOrder) {
      let sequence = LazyCountDuplicatesSequence(self, by: $0)
      var iterator = sequence.makeIterator()
      var result = T()
      result.reserveCapacity(sequence.underestimatedCount)
      while let element = try iterator.throwingNext() {
        result.append(element)
      }
      return result
    }
  }

  /// Assuming this sequence is already sorted along the given predicate,
  /// return an array of each unique element paired with its number of
  /// occurances.
  ///
  /// - Precondition: This sequence must be finite,
  ///   and be sorted according to the given predicate.
  ///
  /// - Parameter areInIncreasingOrder: The sorting predicate.
  /// - Returns: An array of pairs,
  ///   one for each element equivalence class present in this sequence,
  ///   in order of appearance.
  ///   The first member is the value of the earliest element for
  ///   an equivalence class.
  ///   The second member is the number of occurances of that
  ///   equivalence class.
  ///
  /// - Complexity: O(`n`), where *n* is the length of this sequence.
  @inlinable
  public func countSortedDuplicates(
    by areInIncreasingOrder: (Element, Element) throws -> Bool
  ) rethrows -> [(value: Element, count: Int)] {
    try countSortedDuplicates(storingIn: Array.self, by: areInIncreasingOrder)
  }

  /// Assuming this sequence is already sorted along the given predicate,
  /// return an array of each unique element, by equivalence class.
  ///
  /// - Precondition: This sequence must be finite,
  ///   and be sorted according to the given predicate.
  ///
  /// - Parameter areInIncreasingOrder: The sorting predicate.
  ///
  /// - Returns: An array with the earliest element in this sequence for
  ///   each equivalence class.
  ///
  /// - Complexity: O(`n`), where *n* is the length of this sequence.
  @inlinable
  public func deduplicateSorted(
    by areInIncreasingOrder: (Element, Element) throws -> Bool
  ) rethrows -> [Element] {
    try countSortedDuplicates(by: areInIncreasingOrder).map(\.value)
  }
}

extension Sequence where Element: Comparable {
  /// Assuming this sequence is already sorted,
  /// return an array of each unique value paired with its number of
  /// occurances.
  ///
  /// - Precondition: This sequence must be finite and sorted.
  ///
  /// - Returns: An array of pairs,
  ///   one for each unique element value in this sequence,
  ///   in order of appearance.
  ///   The first member is the earliest element for a value.
  ///   The second member is the count of that value's occurances.
  ///
  /// - Complexity: O(`n`), where *n* is the length of this sequence.
  @inlinable
  public func countSortedDuplicates() -> [(value: Element, count: Int)] {
    countSortedDuplicates(by: <)
  }

  /// Assuming this sequence is already sorted,
  /// return an array of the first elements of each unique value.
  ///
  /// - Precondition: This sequence must be finite and sorted.
  ///
  /// - Returns: An array with the earliest element in this sequence for
  ///   each value.
  ///
  /// - Complexity: O(`n`), where *n* is the length of this sequence.
  @inlinable
  public func deduplicateSorted() -> [Element] {
    deduplicateSorted(by: <)
  }
}

extension LazySequenceProtocol {
  /// Assuming this sequence is already sorted along the given predicate,
  /// return a sequence that will lazily generate each unique
  /// element paired with its number of occurances.
  ///
  /// - Precondition: This squence is sorted according to the given predicate,
  ///   and cannot end with an infinite run of a single equivalence class.
  ///
  /// - Parameter areInIncreasingOrder: The sorting predicate.
  ///
  /// - Returns: A sequence that lazily generates the first element of
  ///   each equivalence class present in this sequence paired with
  ///   the number of occurances for that class.
  @inlinable
  public func countSortedDuplicates(
    by areInIncreasingOrder: @escaping (Element, Element) -> Bool
  ) -> LazyCountDuplicatesSequence<Elements> {
    .init(elements, by: areInIncreasingOrder)
  }

  /// Assuming this sequence is already sorted along the given predicate,
  /// return a sequence that will lazily vend each unique element.
  ///
  /// - Precondition: This squence is sorted according to the given predicate,
  ///   and cannot end with an infinite run of a single equivalence class.
  ///
  /// - Parameter areInIncreasingOrder: The sorting predicate.
  ///
  /// - Returns: A sequence that lazily generates the first element of
  ///   each equivalence class present in this sequence.
  @inlinable
  public func deduplicateSorted(
    by areInIncreasingOrder: @escaping (Element, Element) -> Bool
  ) -> some (Sequence<Element> & LazySequenceProtocol) {
    countSortedDuplicates(by: areInIncreasingOrder).lazy.map(\.value)
  }
}

extension LazySequenceProtocol where Element: Comparable {
  /// Assuming this sequence is already sorted,
  /// return an array of each unique value paired with its number of
  /// occurances.
  ///
  /// - Precondition: This sequence is sorted,
  ///   and cannot end with an infinite run of a single value.
  ///
  /// - Returns: A sequence that lazily generates the first element of
  ///   each value paired with the count of that value's occurances.
  @inlinable
  public func countSortedDuplicates() -> LazyCountDuplicatesSequence<Elements> {
    countSortedDuplicates(by: <)
  }

  /// Assuming this sequence is already sorted,
  /// return a sequence that will lazily vend each unique value.
  ///
  /// - Precondition: This sequence is sorted,
  ///   and cannot end with an infinite run of a single value.
  ///
  /// - Returns: A sequence that lazily generates the first element of
  ///   each value.
  @inlinable
  public func deduplicateSorted() -> some (
    Sequence<Element> & LazySequenceProtocol
  ) {
    deduplicateSorted(by: <)
  }
}

// MARK: - Sequence

/// Lazily vends the count of each run of duplicate values from
/// a sorted source.
public struct LazyCountDuplicatesSequence<Base: Sequence> {
  /// The predicate for which `base` is sorted by.
  let areInIncreasingOrder: (Base.Element, Base.Element) throws -> Bool
  /// The source of elements, which must be sorted by `areInIncreasingOrder`.
  var base: Base

  /// Creates a sequence based on the given sequence,
  /// which must be sorted by the given predicate,
  /// that'll vend each unique element value and that value's appearance count.
  @usableFromInline
  init(
    _ base: Base,
    by areInIncreasingOrder: @escaping (Base.Element, Base.Element) throws ->
      Bool
  ) {
    self.base = base
    self.areInIncreasingOrder = areInIncreasingOrder
  }
}

extension LazyCountDuplicatesSequence: LazySequenceProtocol {
  public var underestimatedCount: Int {
    base.underestimatedCount.signum()
  }

  public func makeIterator() -> CountDuplicatesIterator<Base.Iterator> {
    .init(base.makeIterator(), by: areInIncreasingOrder)
  }
}

// MARK: - Iterator

/// Vends the count of each run of duplicate values from a sorted source.
public struct CountDuplicatesIterator<Base: IteratorProtocol> {
  /// The predicate for which `base` is sorted by.
  let areInIncreasingOrder: (Base.Element, Base.Element) throws -> Bool
  /// The source of elements, which must be sorted by `areInIncreasingOrder`.
  var base: Base
  /// The last element read, for comparisons.
  var mostRecent: Base.Element?

  /// Creates an iterator based on the given iterator,
  /// whose virtual sequence must be sorted by the given predicate,
  /// which counts the length of each run of duplicate values.
  init(
    _ base: Base,
    by areInIncreasingOrder: @escaping (Base.Element, Base.Element) throws ->
      Bool
  ) {
    self.base = base
    self.areInIncreasingOrder = areInIncreasingOrder
  }
}

extension CountDuplicatesIterator: IteratorProtocol {
  public mutating func next() -> (value: Base.Element, count: Int)? {
    // NOTE: This method is called only when the predicate isn't `throw`-ing,
    // so the forced `try` is OK.
    try! throwingNext()
  }

  /// Extracts the next element that isn't equivalent to
  /// the last unique one extracted.
  mutating func throwingNext() throws -> Element? {
    mostRecent = mostRecent ?? base.next()
    guard let last = mostRecent else { return nil }

    var count = 1
    while let current = base.next() {
      if try areInIncreasingOrder(last, current) {
        mostRecent = current
        return (last, count)
      } else {
        count += 1
      }
    }
    mostRecent = nil
    return (last, count)
  }
}
