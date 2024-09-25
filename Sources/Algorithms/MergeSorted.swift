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
// MARK: RangeReplaceableCollection.init(mergeSorted:and:sortedBy:)
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

/// Given two sequences that are both sorted according to the given predicate,
/// return their merger that is sorted by the predicate and vended lazily.
///
/// - Precondition: Both `first` and `second` must be sorted according to
///   `areInIncreasingOrder`, and said predicate must be a strict weak ordering
///   over its arguments.
///
/// - Parameters:
///   - first: The first sequence spliced.
///   - second: The second sequence spliced.
///   - areInIncreasingOrder: The criteria for sorting.
/// - Returns: The merged sequence.
///
/// - Complexity: O(1). The actual iteration takes place in O(`n` + `m`),
///   where `n` and `m` are the lengths of the sequence arguments.
@inlinable
public func mergeSorted<T: Sequence, U: Sequence>(
  _ first: T,
  _ second: U,
  sortedBy areInIncreasingOrder: @escaping (T.Element, U.Element) -> Bool
) -> MergeSortedSetsSequence<T, U>
where T.Element == U.Element {
  return mergeSortedSets(first, second, retaining: .sum, sortedBy: areInIncreasingOrder)
}

/// Given two sorted sequences, return their still-sorted merger, vended lazily.
///
/// - Precondition: Both `first` and `second` must be sorted.
///
/// - Parameters:
///   - first: The first sequence spliced.
///   - second: The second sequence spliced.
/// - Returns: The merged sequence.
///
/// - Complexity: O(1). The actual iteration takes place in O(`n` + `m`),
///   where `n` and `m` are the lengths of the sequence arguments.
@inlinable
public func mergeSorted<T: Sequence, U: Sequence>(
  _ first: T, _ second: U
) -> MergeSortedSetsSequence<T, U>
where T.Element == U.Element, T.Element: Comparable {
  return mergeSorted(first, second, sortedBy: <)
}

//===----------------------------------------------------------------------===//
// MARK: - MergeSortedSequence
//-------------------------------------------------------------------------===//

/// A sequence taking some sequences,
/// all sorted along a predicate,
/// that vends the spliced-together merged sequence,
/// where said sequence is also sorted.
///
/// - TODO: When Swift supports same-element requirements for
///   variadic generics, change this type's generic pattern to
///   accept any number of source iterators.
@available(macOS 13.0.0, *)
public struct MergeSortedSequence<First: Sequence, Second: Sequence>
where First.Element == Second.Element
{
  /// The sorting criterion.
  let areInIncreasingOrder: (Element, Element) throws -> Bool
  /// The first source sequence.
  let first: First
  /// The second source sequence.
  let second: Second

  public
  init(
    _ first: First,
    _ second: Second,
    sortedBy areInIncreasingOrder: @escaping (Element, Element) throws -> Bool
  ) {
    self.first = first
    self.second = second
    self.areInIncreasingOrder = areInIncreasingOrder
  }
}

@available(macOS 13.0.0, *)
extension MergeSortedSequence: Sequence {
  public func makeIterator() -> MergeSortedIterator<First.Element> {
    return .init(first.makeIterator(), second.makeIterator(),
                 areInIncreasingOrder: areInIncreasingOrder)
  }

  public var underestimatedCount: Int {
    let result = first.underestimatedCount
      .addingReportingOverflow(second.underestimatedCount)
    return result.overflow ? .max : result.partialValue
  }
}

@available(macOS 13.0.0, *)
extension MergeSortedSequence: LazySequenceProtocol
where First: LazySequenceProtocol, Second: LazySequenceProtocol
{
  public var elements: MergeSortedSequence<First.Elements, Second.Elements> {
    .init(first.elements, second.elements, sortedBy: areInIncreasingOrder)
  }
}

//===----------------------------------------------------------------------===//
// MARK: - MergeSortedIterator
//-------------------------------------------------------------------------===//

/// An iterator taking some virtual sequences,
/// all sorted along a predicate,
/// that vends the spliced-together virtual sequence merger,
/// where said sequence is also sorted.
@available(macOS 13.0.0, *)
public struct MergeSortedIterator<Element> {
  /// The sorting criterion.
  let areInIncreasingOrder: (Element, Element) throws -> Bool
  /// The sources to splice together.
  var sources: [(latest: Element?, source: any IteratorProtocol<Element>)]

  /// Create an iterator that reads from the two given sources and
  /// vends their merger,
  /// assuming all three virtual sequences are sorted according to
  /// the given predicate.
  ///
  /// - TODO: When Swift supports same-element requirements for
  ///   variadic generics, change this initializer to accept any number of
  ///   source iterators.
  init<T: IteratorProtocol<Element>, U: IteratorProtocol<Element>>(
    _ first: T,
    _ second: U,
    areInIncreasingOrder: @escaping (Element, Element) throws -> Bool
  ) {
    self.areInIncreasingOrder = areInIncreasingOrder
    self.sources = [(nil, first), (nil, second)]
  }
}

@available(macOS 13.0.0, *)
extension MergeSortedIterator: IteratorProtocol {
  /// Advance to the next element, if any. May throw.
  @usableFromInline
  mutating func throwingNext() throws -> Element? {
    for index in sources.indices {
      sources[index].latest = sources[index].latest
      ?? sources[index].source.next()
    }
    sources.removeAll { $0.latest == nil }
    guard let indexOfSmallest = try sources.indices.min(by: {
      try areInIncreasingOrder(sources[$0].latest!, sources[$1].latest!)
    }) else { return nil }
    defer { sources[indexOfSmallest].latest = nil }

    return sources[indexOfSmallest].latest
  }

  @inlinable
  public mutating func next() -> Element? {
    return try! throwingNext()
  }
}
