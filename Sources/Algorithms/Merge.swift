//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift Algorithms open source project
//
// Copyright (c) 2022 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

//==============================================================================
// MARK: SetOperation
//==============================================================================

/// Binary (multi-)set operations, using combinations of keeping or removing
/// shared and/or disjoint elements.
public enum SetOperation: UInt, CaseIterable {

  /// No elements from either set are preserved.
  case none
  /// The elements from the first set that are not shared with the second.
  case firstWithoutSecond
  /// The elements from the second set that are not shared with the first.
  case secondWithoutFirst
  /// The elements from either set that are not shared with the other.
  case symmetricDifference
  /// The elements shared by both sets.
  case intersection
  /// The elements of the first set.
  case first
  /// The elements of the second set.
  case second
  /// The elements of both sets, consolidating shared ones.
  case union
  /// The elements of both sets, preserving both copies of shared ones.
  case sum = 0b1111

}

extension SetOperation {

  /// Whether elements only in the first set are included in the operation.
  @inlinable public var usesExclusivesFromFirst: Bool { rawValue & 0b0001 != 0 }
  /// Whether elements only in the second set are included in the operation.
  @inlinable public var usesExclusivesFromSecond: Bool {rawValue & 0b0010 != 0}
  /// Whether elements that are shared between both sets are included in the
  /// operation.
  @inlinable public var usesShared: Bool { rawValue & 0b0100 != 0 }
  /// Whether both copies of elements shared between both sets are included in
  /// the operation.
  @inlinable public var duplicatesShared: Bool { rawValue & 0b1000 != 0 }

  /// Creates an operation with the given combination of keeping or removing
  /// shared and/or disjoint elements.
  ///
  /// - Warning: Keeping everything always results in `.union`, not `.sum`. The
  ///   latter is not reachable from this initializer.
  ///
  /// - Parameters:
  ///   - keepExclusivesToFirst: whether elements that are only in the first set
  ///     are preserved.
  ///   - keepExclusivesToSecond: whether elements that are only in the second
  ///     set are preserved.
  ///   - keepShared: whether elements that are shared between the sets are
  ///     preserved.
  /// - Postcondition: `.usesExclusivesFromFirst == keepExclusivesToFirst`,
  ///   `.usesExclusivesFromSecond == keepExclusivesToSecond`,
  ///   `.usesShared == keepShared`, `.duplicatesShared == false`.
  @inlinable
  public init(
    keepExclusivesToFirst: Bool, keepExclusivesToSecond: Bool, keepShared: Bool
  ) {
    let k1, k2, ks: UInt
    k1 = keepExclusivesToFirst ? 0b0001 : 0
    k2 = keepExclusivesToSecond ? 0b0010 : 0
    ks = keepShared ? 0b0100 : 0
    self.init(rawValue: k1 | k2 | ks)!
  }

}

//==============================================================================
// MARK: - merge
//==============================================================================

/// Merges the two given sorted sequences into a sorted array, but retaining
/// only the given subset of elements from the merger.
///
/// When shared elements are copied, the source sequence depends on `operation`.
///
/// - For `.intersection`, `.first`, or `.union`; `first` is the source.
/// - For `.second`,`second` is the source.
/// - For `.sum`, all of the elements from `first` are used first, followed by
///   the ones from `second`.
///
/// Elements from the same source preserve their relative order.
///
/// - Precondition: Both `first` and `second` are finite. And they are both
///   considered sorted.
///
/// - Parameters:
///   - first: The first sequence to be spliced together.
///   - second: The second sequence to be spliced together.
///   - operation: Which set operation to apply when generating the returned
///     object, treating the source sequences as multi-sets. If omitted, `.sum`
///     is used as the default, resulting in a conventional full merger.
/// - Returns: A sorted array of the merger, excluding the elements banned by
///   the set operation.
///
/// - Complexity: O(*m* + *n*), where *m* and *n* are the lengths of the two
///   sequences.
@inlinable
public func merge<Base1: Sequence, Base2: Sequence>(
  _ first: Base1, _ second: Base2, keeping operation: SetOperation = .sum
) -> [Base1.Element]
where Base1.Element == Base2.Element, Base2.Element: Comparable {
  merge(first, second, keeping: operation, along: <)
}

/// Merges the two given sorted collections into a new sorted collection, but
/// retaining only the given subset of elements from the merger.
///
/// When shared elements are copied, the source sequence depends on `operation`.
///
/// - For `.intersection`, `.first`, or `.union`; `first` is the source.
/// - For `.second`,`second` is the source.
/// - For `.sum`, all of the elements from `first` are used first, followed by
///   the ones from `second`.
///
/// Elements from the same source preserve their relative order.
///
/// - Precondition: Both `first` and `second` are considered sorted.
///
/// - Parameters:
///   - first: The first collection to be spliced together.
///   - second: The second collection to be spliced together.
///   - operation: Which set operation to apply when generating the returned
///     object, treating the source collections as multi-sets. If omitted,
///     `.sum` is used as the default, resulting in a conventional full merger.
/// - Returns: A sorted collection of the merger, excluding the elements banned
///   by the set operation.
///
/// - Complexity: O(*m* + *n*), where *m* and *n* are the lengths of the two
///   collections.
@inlinable
public func merge<Base: RangeReplaceableCollection>(
    _ first: Base, _ second: Base, keeping operation: SetOperation = .sum
) -> Base where Base.Element: Comparable {
  merge(first, second, keeping: operation, along: <)
}

/// Merges the two given sequences, each sorted using the given predicate as the
/// comparison between elements, into a sorted array, but retaining only the
/// given subset of elements from the merger.
///
/// The predicate must be a *strict weak ordering* over the elements. That is,
/// for any elements `a`, `b`, and `c`, the following conditions must hold:
///
/// - `areInIncreasingOrder(a, a)` is always `false`. (Irreflexivity)
/// - If `areInIncreasingOrder(a, b)` and `areInIncreasingOrder(b, c)` are both
///   `true`, then `areInIncreasingOrder(a, c)` is also `true`. (Transitive
///   comparability)
/// - Two elements are *incomparable* if neither is ordered before the other
///   according to the predicate. If `a` and `b` are incomparable, and `b` and
///   `c` are incomparable, then `a` and `c` are also incomparable. (Transitive
///   incomparability)
///
/// When shared elements are copied, the source sequence depends on `operation`.
///
/// - For `.intersection`, `.first`, or `.union`; `first` is the source.
/// - For `.second`,`second` is the source.
/// - For `.sum`, all of the elements from `first` are used first, followed by
///   the ones from `second`.
///
/// Elements from the same source preserve their relative order.
///
/// - Precondition: Both `first` and `second` are finite. And they are both
///   considered sorted according to `areInIncreasingOrder`.
///
/// - Parameters:
///   - first: The first sequence to be spliced together.
///   - second: The second sequence to be spliced together.
///   - operation: Which set operation to apply when generating the returned
///     object, treating the source sequences as multi-sets. If omitted, `.sum`
///     is used as the default, resulting in a conventional full merger.
///   - areInIncreasingOrder: A predicate that returns `true` if its first
///     argument should be ordered before its second argument; otherwise,
///     `false`.
/// - Returns: A sorted array of the merger, excluding the elements banned by
///   the set operation.
///
/// - Complexity: O(*m* + *n*), where *m* and *n* are the lengths of the two
///   sequences.
@inlinable
public func merge<Base1: Sequence, Base2: Sequence>(
  _ first: Base1, _ second: Base2, keeping operation: SetOperation = .sum,
  along areInIncreasingOrder: (Base1.Element, Base2.Element) throws -> Bool
) rethrows -> [Base1.Element] where Base1.Element == Base2.Element {
  try merge(first, second, into: Array.self, keeping: operation,
            along: areInIncreasingOrder)
}

/// Merges the two given collections, each sorted using the given predicate as
/// the comparison between elements, into a sorted collection, but retaining
/// only the given subset of elements from the merger.
///
/// The predicate must be a *strict weak ordering* over the elements. That is,
/// for any elements `a`, `b`, and `c`, the following conditions must hold:
///
/// - `areInIncreasingOrder(a, a)` is always `false`. (Irreflexivity)
/// - If `areInIncreasingOrder(a, b)` and `areInIncreasingOrder(b, c)` are both
///   `true`, then `areInIncreasingOrder(a, c)` is also `true`. (Transitive
///   comparability)
/// - Two elements are *incomparable* if neither is ordered before the other
///   according to the predicate. If `a` and `b` are incomparable, and `b` and
///   `c` are incomparable, then `a` and `c` are also incomparable. (Transitive
///   incomparability)
///
/// When shared elements are copied, the source sequence depends on `operation`.
///
/// - For `.intersection`, `.first`, or `.union`; `first` is the source.
/// - For `.second`,`second` is the source.
/// - For `.sum`, all of the elements from `first` are used first, followed by
///   the ones from `second`.
///
/// Elements from the same source preserve their relative order.
///
/// - Precondition: Both `first` and `second` are considered sorted according to
///   `areInIncreasingOrder`.
///
/// - Parameters:
///   - first: The first collection to be spliced together.
///   - second: The second collection to be spliced together.
///   - operation: Which set operation to apply when generating the returned
///     object, treating the source collections as multi-sets. If omitted,
///     `.sum` is used as the default, resulting in a conventional full merger.
///   - areInIncreasingOrder: A predicate that returns `true` if its first
///     argument should be ordered before its second argument; otherwise,
///     `false`.
/// - Returns: A sorted collection of the merger, excluding the elements banned
///   by the set operation.
///
/// - Complexity: O(*m* + *n*), where *m* and *n* are the lengths of the two
///   collections.
@inlinable
public func merge<Base: RangeReplaceableCollection>(
    _ first: Base, _ second: Base, keeping operation: SetOperation = .sum,
    along areInIncreasingOrder: (Base.Element, Base.Element) throws -> Bool
) rethrows -> Base {
  try merge(first, second, into: Base.self, keeping: operation,
            along: areInIncreasingOrder)
}

//==============================================================================
// MARK: merge, Implementation
//==============================================================================

/// Merges the two given sequences, each sorted using the given predicate as the
/// comparison between elements, into a sorted collection of the given type, but
/// retaining only the given subset of elements from the merger.
///
/// The predicate must be a *strict weak ordering* over the elements. That is,
/// for any elements `a`, `b`, and `c`, the following conditions must hold:
///
/// - `areInIncreasingOrder(a, a)` is always `false`. (Irreflexivity)
/// - If `areInIncreasingOrder(a, b)` and `areInIncreasingOrder(b, c)` are both
///   `true`, then `areInIncreasingOrder(a, c)` is also `true`. (Transitive
///   comparability)
/// - Two elements are *incomparable* if neither is ordered before the other
///   according to the predicate. If `a` and `b` are incomparable, and `b` and
///   `c` are incomparable, then `a` and `c` are also incomparable. (Transitive
///   incomparability)
///
/// When shared elements are copied, the source sequence depends on `operation`.
///
/// - For `.intersection`, `.first`, or `.union`; `first` is the source.
/// - For `.second`,`second` is the source.
/// - For `.sum`, all of the elements from `first` are used first, followed by
///   the ones from `second`.
///
/// Elements from the same source preserve their relative order.
///
/// - Precondition: Both `first` and `second` are finite. And they are both
///   considered sorted according to `areInIncreasingOrder`.
///
/// - Parameters:
///   - first: The first sequence to be spliced together.
///   - second: The second sequence to be spliced together.
///   - type: A metatype specifier for the returned object's type.
///   - operation: Which set operation to apply when generating the returned
///     object, treating the source sequences as multi-sets. Use `.sum` for a
///     conventional merger.
///   - areInIncreasingOrder: A predicate that returns `true` if its first
///     argument should be ordered before its second argument; otherwise,
///     `false`.
/// - Returns: A sorted collection of the merger, excluding the elements banned
///   by the set operation.
///
/// - Complexity: O(*m* + *n*), where *m* and *n* are the lengths of the two
///   sequences.
@usableFromInline
internal func merge<
  Base1: Sequence, Base2: Sequence, Result: RangeReplaceableCollection
>(
  _ first: Base1, _ second: Base2, into type: Result.Type,
  keeping operation: SetOperation,
  along areInIncreasingOrder: (Base1.Element, Base2.Element) throws -> Bool
) rethrows -> Result
where Base1.Element == Base2.Element, Base2.Element == Result.Element {
  var result = Result()
  result.reserveCapacity(combinedUnderestimatedCount(first.underestimatedCount,
                                                     second.underestimatedCount,
                                                     keeping: operation))
  try withoutActuallyEscaping(areInIncreasingOrder) { predicate in
    var iterator = Merged2Iterator(with: first.makeIterator(),
                                   and: second.makeIterator(),
                                   keeping: operation, along: predicate)
    while let element = try iterator.throwingNext() {
      result.append(element)
    }
  }
  return result
}

/// Returns the worst case `underestimatedCount` for the given sequence counts
/// and the set operation combining them.
///
/// Since the actual elements cannot be read, operations that would require
/// reading the elements first will report the worst-case count instead.
fileprivate func combinedUnderestimatedCount(
  _ first: Int, _ second: Int, keeping operation: SetOperation
) -> Int {
  switch operation {
  case .none:
    return 0
  case .firstWithoutSecond:
    return max(first - second, 0)
  case .secondWithoutFirst:
    return max(second - first, 0)
  case .symmetricDifference:
    return abs(first - second)
  case .intersection:
    return 0
  case .first:
    return first
  case .second:
    return second
  case .union:
    return max(first, second)
  case .sum:
    let (sum, didOverflow) = first.addingReportingOverflow(second)
    return didOverflow ? .max : sum
  }
}

//==============================================================================
// MARK: - lazilyMerge
//==============================================================================

/// Lazily merges the two given sorted lazy sequences into a new sorted lazy
/// sequence, where only the given subset of merged elements is retained.
///
/// When shared elements are copied, the source sequence depends on `operation`.
///
/// - For `.intersection`, `.first`, or `.union`; `first` is the source.
/// - For `.second`,`second` is the source.
/// - For `.sum`, all of the elements from `first` are used first, followed by
///   the ones from `second`.
///
/// Elements from the same source preserve their relative order.
///
/// - Precondition: Both `first` and `second` are considered sorted.
///
/// - Parameters:
///   - first: The first sequence to be spliced together.
///   - second: The second sequence to be spliced together.
///   - operation: Which set operation to apply when generating the returned
///     object, treating the source sequences as multi-sets. If omitted, `.sum`
///     is used as the default, resulting in a conventional full merger.
/// - Returns: A lazy sequence of the sorted merger, excluding the elements
///   banned by the set operation.
///
/// - Complexity: O(1), but generating the actual sequence will work in O(*m* +
///   *n*) time, where *m* and *n* are the lengths of the two sequences.
@inlinable
public func lazilyMerge<
  Base1: LazySequenceProtocol, Base2: LazySequenceProtocol
>(
  _ first: Base1, _ second: Base2, keeping operation: SetOperation = .sum
) -> Merged2Sequence<Base1.Elements, Base2.Elements>
where Base1.Element == Base2.Element, Base2.Element: Comparable {
  lazilyMerge(first, second, keeping: operation, along: <)
}

/// Lazily merges the two given lazy sequences, each sorted using the given
/// predicate as the comparison between elements, into a new sorted lazy
/// sequence, where only the given subset of merged elements is retained.
///
/// The predicate must be a *strict weak ordering* over the elements. That is,
/// for any elements `a`, `b`, and `c`, the following conditions must hold:
///
/// - `areInIncreasingOrder(a, a)` is always `false`. (Irreflexivity)
/// - If `areInIncreasingOrder(a, b)` and `areInIncreasingOrder(b, c)` are both
///   `true`, then `areInIncreasingOrder(a, c)` is also `true`. (Transitive
///   comparability)
/// - Two elements are *incomparable* if neither is ordered before the other
///   according to the predicate. If `a` and `b` are incomparable, and `b` and
///   `c` are incomparable, then `a` and `c` are also incomparable. (Transitive
///   incomparability)
///
/// When shared elements are copied, the source sequence depends on `operation`.
///
/// - For `.intersection`, `.first`, or `.union`; `first` is the source.
/// - For `.second`,`second` is the source.
/// - For `.sum`, all of the elements from `first` are used first, followed by
///   the ones from `second`.
///
/// Elements from the same source preserve their relative order.
///
/// - Precondition: Both `first` and `second` are considered sorted according to
///   `areInIncreasingOrder`.
///
/// - Parameters:
///   - first: The first sequence to be spliced together.
///   - second: The second sequence to be spliced together.
///   - operation: Which set operation to apply when generating the returned
///     object, treating the source sequences as multi-sets. If omitted, `.sum`
///     is used as the default, resulting in a conventional full merger.
///   - areInIncreasingOrder: A predicate that returns `true` if its first
///     argument should be ordered before its second argument; otherwise,
///     `false`.
/// - Returns: A lazy sequence of the sorted merger, excluding the elements
///   banned by the set operation.
///
/// - Complexity: O(1), but generating the actual sequence will work in O(*m* +
///   *n*) time, where *m* and *n* are the lengths of the two sequences.
@inlinable
public func lazilyMerge<
  Base1: LazySequenceProtocol, Base2: LazySequenceProtocol
>(
  _ first: Base1, _ second: Base2, keeping operation: SetOperation = .sum,
  along areInIncreasingOrder: @escaping (Base1.Element, Base2.Element) -> Bool
) -> Merged2Sequence<Base1.Elements, Base2.Elements>
where Base1.Element == Base2.Element {
  Merged2Sequence(with: first.elements, and: second.elements,
                  keeping: operation, along: areInIncreasingOrder)
}

//==============================================================================
// MARK: - Merged2Sequence
//==============================================================================

/// A sequence vending the sorted merger of its source sequences.
public struct Merged2Sequence<Base1: Sequence, Base2: Sequence>
where Base1.Element == Base2.Element {

  /// The first sequence to merge.
  let base1: Base1
  /// The second sequence to merge.
  let base2: Base2
  /// The set operation filtering out elements from the merger.
  let operation: SetOperation
  /// The ordering predicate.
  let areInIncreasingOrder: (Base1.Element, Base2.Element) -> Bool

  /// Creates a sequence-merging sequence from the given parameters.
  @usableFromInline
  init(with base1: Base1, and base2: Base2, keeping operation: SetOperation,
       along areInIncreasingOrder: @escaping (Base1.Element, Base2.Element)
       -> Bool) {
    self.base1 = base1
    self.base2 = base2
    self.operation = operation
    self.areInIncreasingOrder = areInIncreasingOrder
  }

}

extension Merged2Sequence: LazySequenceProtocol {

  public typealias Element = Base1.Element
  public typealias Iterator = Merged2Iterator<Base1.Iterator, Base2.Iterator>

  public func makeIterator() -> Iterator {
    return Merged2Iterator(with: base1.makeIterator(),
                           and: base2.makeIterator(), keeping: operation,
                           along: areInIncreasingOrder)
  }
  public var underestimatedCount: Int {
    combinedUnderestimatedCount(base1.underestimatedCount,
                                base2.underestimatedCount, keeping: operation)
  }
  public func withContiguousStorageIfAvailable<R>(
    _ body: (UnsafeBufferPointer<Element>) throws -> R
  ) rethrows -> R? {
    switch operation {
    case .none:
      return try body(UnsafeBufferPointer(start: nil, count: 0))
    case .first:
      return try base1.withContiguousStorageIfAvailable(body)
    case .second:
      return try base2.withContiguousStorageIfAvailable(body)
    default:
      // The other cases may alternate elements from both sequences, take only
      // some elements from a given sequence, or both. These prevent using
      // either of the two potentially available memory blocks.
      return nil
    }
  }

  public func _customContainsEquatableElement(_ element: Element) -> Bool? {
    switch operation {
    case .none:
      return false
    case .first:
      return base1._customContainsEquatableElement(element)
    case .second:
      return base2._customContainsEquatableElement(element)
    case .sum:
      switch (base1._customContainsEquatableElement(element),
              base2._customContainsEquatableElement(element)) {
      case (_, .some(true)), (.some(true), _):
        return true
      case (.some(false), .some(false)):
        return false
      case (.none, _), (_, .none):
        return nil
      }
    default:
      // An element cannot be checked for inclusion without reading both
      // sequences; and also depends on the operation, the ordering predicate,
      // and if said predicate is compatible with `==`. All of these prevent
      // confirmation.
      return nil
    }
  }

}

//==============================================================================
// MARK: - Merged2Iterator
//==============================================================================

/// An iterator vending the sorted merger of its source iterators.
public struct Merged2Iterator<Base1: IteratorProtocol, Base2: IteratorProtocol>
where Base1.Element == Base2.Element {

  /// The first Iterator to merge.
  var base1: Base1
  /// The second iterator to merge.
  var base2: Base2
  /// The ordering predicate.
  let areInIncreasingOrder: (Base1.Element, Base2.Element) throws -> Bool

  /// Whether to stop reading from `base1`.
  var didFinish1: Bool
  /// Whether to stop reading from `base2`.
  var didFinish2: Bool
  /// The last element read but unused from `base1`.
  var previous1: Base1.Element?
  /// The last element read but unused from `base2`.
  var previous2: Base2.Element?

  /// Handler for elements exclusive to `base1`, including any trailing ones.
  let exclusiveHandler1: (Base1.Element) -> Base1.Element?
  /// Handler for elements exclusive to `base2`, including any trailing ones.
  let exclusiveHandler2: (Base2.Element) -> Base2.Element?
  /// Copy handler for the shared elements.
  ///
  /// There's no `dequeue1` because it's always `true`. There's no parameter for
  /// the element from `base2` because the operations that need it (`.second`
  /// and `.sum`) end up on code paths that skip calls to this handler.
  let sharedHandler: (Base1.Element) -> (Base1.Element?, dequeue2: Bool)

  /// Creates an iterator-merging iterator from the given parameters.
  @usableFromInline
  init(with base1: Base1, and base2: Base2, keeping operation: SetOperation,
       along areInIncreasingOrder: @escaping (Base1.Element, Base2.Element)
       throws -> Bool) {
    // Retain sources and predicate.
    self.base1 = base1
    self.base2 = base2
    self.areInIncreasingOrder = areInIncreasingOrder

    // Pre-ignore certain sources.
    switch operation {
    case .none:
      didFinish1 = true
      didFinish2 = true
    case .first:
      didFinish1 = false
      didFinish2 = true
    case .second:
      didFinish1 = true
      didFinish2 = false
    default:
      didFinish1 = false
      didFinish2 = false
    }

    // Set policy for each grouping class.
    if operation.usesExclusivesFromFirst {
      exclusiveHandler1 = { e in return e }
    } else {
      exclusiveHandler1 = { _ in return nil }
    }
    if operation.usesExclusivesFromSecond {
      exclusiveHandler2 = { e in return e }
    } else {
      exclusiveHandler2 = { _ in return nil }
    }
    if operation.usesShared {
      sharedHandler = { e in return (e, !operation.duplicatesShared) }
    } else {
      sharedHandler = { _ in return (nil, true) }
    }
  }

}

extension Merged2Iterator: IteratorProtocol {

  public mutating func next() -> Base1.Element? {
    return try! throwingNext()
  }

  /// Advances to the next element and returns it, or `nil` if no next element
  /// exists, but could throw in the process.
  internal mutating func throwingNext() throws -> Base2.Element? {
    switch (didFinish1, didFinish2) {
    case (false, false):
      repeat {
        // Read the latest elements of each iterator as needed.
        previous1 = previous1 ?? base1.next()
        previous2 = previous2 ?? base2.next()

        // Remove any elements that actually got read or ignored to prepare for
        // the next loop.
        var didUse1 = false, didUse2 = false
        defer {
          didFinish1 = previous1 == nil
          didFinish2 = previous2 == nil
          if didUse1 {
            previous1 = nil
          }
          if didUse2 {
            previous2 = nil
          }
        }

        // Compare the latest elements for vending order (or skip).
      check: switch (previous1, previous2) {
        case let (first?, second?):
          var handledElement: Base2.Element?
          if try areInIncreasingOrder(first, second) {
            // Exclusive to first
            didUse1 = true
            handledElement = exclusiveHandler1(first)
          } else if try areInIncreasingOrder(second, first) {
            // Exclusive to second
            didUse2 = true
            handledElement = exclusiveHandler2(second)
          } else {
            // Shared
            didUse1 = true
            (handledElement, didUse2) = sharedHandler(first)
          }
          if let returnedElement = handledElement {
            return returnedElement
          } else {
            break check
          }
        case (let first?, nil):
          // Start draining the first iterator, or wrap up operations if
          // elements exclusive to that iterator aren't supported.
          didUse1 = true
          previous1 = exclusiveHandler1(first)
          return previous1
        case (nil, let second?):
          // Start draining the second iterator, or wrap up operations if
          // elements exclusive to that iterator aren't supported.
          didUse2 = true
          previous2 = exclusiveHandler2(second)
          return previous2
        case (nil, nil):
          return nil
        }
      } while !didFinish1 && !didFinish2

      // At least one of the iterators got exhausted or permanently skipped
      // while looking for a qualifying element. Shift to one of the other
      // top-level cases to handle it.
      return try throwingNext()
    case (false, true):
      // Drain the first iterator.
      previous1 = previous1 ?? base1.next()
      didFinish1 = previous1 == nil
      defer { previous1 = nil }
      return previous1
    case (true, false):
      // Drain the second iterator.
      previous2 = previous2 ?? base2.next()
      didFinish2 = previous2 == nil
      defer { previous2 = nil }
      return previous2
    case (true, true):
      // Both iterators exhausted/ignored
      return nil
    }
  }

}
