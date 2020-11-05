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
// SetCombination
//===----------------------------------------------------------------------===//

/// The manners two (multi)sets may be combined.
public enum SetCombination: CaseIterable {
  /// Retain no elements.
  case nothing
  /// Retain the elements from the first source that do not have a counterpart
  /// in the second.
  case firstMinusSecond
  /// Retain the elements from the second source that do not have a counterpart
  /// in the first.
  case secondMinusFirst
  /// Retain the elements from both sources that do not have counterparts in the other.
  case symmetricDifference
  /// Retain one copy of each element that appears in both sources.
  case intersection
  /// Retain only the elements from the first source.
  case first
  /// Retain only the elements from the second source.
  case second
  /// Retain all the elements, collapsing shared elements to one copy.
  case union
  /// Retain all the elements, but keep both copies of each shared element.
  case sum
}

fileprivate extension SetCombination {
  /// Determines which parts of the operands' merger need to be retained.
  var vendsOut: (unshared1: Bool, unshared2: Bool, shared1: Bool, shared2: Bool)
  {
    switch self {
    case .nothing:
      return (false, false, false, false)
    case .firstMinusSecond:
      return (true, false, false, false)
    case .secondMinusFirst:
      return (false, true, false, false)
    case .symmetricDifference:
      return (true, true, false, false)
    case .intersection:
      return (false, false, true, false)
    case .first:
      return (true, false, true, false)
    case .second:
      return (false, true, false, true)
    case .union:
      return (true, true, true, false)
    case .sum:
      return (true, true, true, true)
    }
  }

  /// Determines if an operand needs to be read at all.
  var readsFrom: (first: Bool, second: Bool) {
    switch self {
    case .nothing:
      return (false, false)
    case .first:
      return (true, false)
    case .second:
      return (false, true)
    default:
      return (true, true)
    }
  }
}

//===----------------------------------------------------------------------===//
// MergedSequence, MergedIterator
//===----------------------------------------------------------------------===//

/// A lazy sorted sequence of a set combination of two sorted source sequences.
public struct MergedSequence<Base1: Sequence, Base2: Sequence>
where Base1.Element == Base2.Element {
  /// The base sequence for the first operand.
  public let firstBase: Base1
  /// The base sequence for the second operand.
  public let secondBase: Base2
  /// The blend of the merger to vend.
  public let selection: SetCombination
  /// The element-ordering predicate.
  @usableFromInline
  let areInIncreasingOrder: (Element, Element) throws -> Bool

  /// Creates a sorted sequence that merges the two given sorted sequences, all
  /// using the given predicate to determine order, but keeping only the elements
  /// indicated by the given status.
  @usableFromInline
  internal init(
    _ base1: Base1,
    _ base2: Base2,
    keeping selection: SetCombination,
    by areInIncreasingOrder: @escaping (Element, Element) throws -> Bool
  ) {
    firstBase = base1
    secondBase = base2
    self.selection = selection
    self.areInIncreasingOrder = areInIncreasingOrder
  }
}

/// An iterator vending the sorted selection from a merger of two sorted source
/// virtual sequences.
public struct MergedIterator<Base1: IteratorProtocol, Base2: IteratorProtocol>
where Base1.Element == Base2.Element {
  /// The base iterator for the first operand.
  var firstBase: Base1
  /// The base iterator for the second operand.
  var secondBase: Base2
  /// The element-ordering predicate.
  let areInIncreasingOrder: (Element, Element) throws -> Bool

  /// Whether elements from `firstBase` that do not have a counterpart from
  /// `secondBase` will be vended.
  let exclusivesFromFirst: Bool
  /// Whether elements from `secondBase` that do not have a counterpart from
  /// `firstBase` will be vended.
  let exclusivesFromSecond: Bool
  /// Whether elements from `firstBase` that have a counterpart in `secondBase`
  /// will be vended.
  let sharedFromFirst: Bool
  /// Whether elements from `secondBase` that have a counterpart in `firstBase`
  /// will be vended.
  let sharedFromSecond: Bool

  /// Whether to read from `firstBase` each round.
  let extractFromFirst: Bool
  /// Whether to read from `secondBase` each round.
  let extractFromSecond: Bool

  /// The last elements extracted.
  var cache: (Element?, Element?)
  /// Whether there is still a need to read elements.
  var isDone: Bool

  /// Creates an iterator merging the elements from the given iterators, keeping
  /// only the ones for the given selection, using the given predicate for the
  /// sort order.
  @usableFromInline
  internal init(
    _ base1: Base1, _ base2: Base2, keeping selection: SetCombination,
    by areInIncreasingOrder: @escaping (Element, Element) throws -> Bool
  ) {
    firstBase = base1
    secondBase = base2
    self.areInIncreasingOrder = areInIncreasingOrder
    (exclusivesFromFirst, exclusivesFromSecond, sharedFromFirst,
     sharedFromSecond) = selection.vendsOut
    (extractFromFirst, extractFromSecond) = selection.readsFrom
    isDone = selection == .nothing
  }
}

/// Storage for a matching pair of elements, acknowledging the smaller.
fileprivate enum MergedIteratorMarker<Element> {
  /// Only the first source has any more elements.
  case first(Element)
  /// Only the second source has any more elements.
  case second(Element)
  /// A matching pair of elements, but not equivalent.
  case nonMatching(Element, Element, firstIsLower: Bool)
  /// A matching pair of equivalent elements.
  case matching(Element, Element, useFirst: Bool)
}

private extension MergedIterator {
  /// Advances and returns the next corresponding pair of elements, or `nil` if
  /// no more exist.
  mutating func dualNext() throws -> MergedIteratorMarker<Element>? {
    while !isDone {
      // Read in the next element(s), when required.
      if extractFromFirst {
        cache.0 = cache.0 ?? firstBase.next()
      }
      if extractFromSecond {
        cache.1 = cache.1 ?? secondBase.next()
      }

      // The marker depends on the cached values' relative ranking.
      switch cache {
      case (nil, nil):
        // No more elements to read.
        isDone = true
      case (let first?, nil):
        // Only the first source has any more elements.
        if exclusivesFromFirst {
          cache.0 = nil
          return .first(first)
        } else {
          // Don't unnecessarily read from a now-unused source.
          isDone = true
        }
      case (nil, let second?):
        // Only the second source has any more elements.
        if exclusivesFromSecond {
          cache.1 = nil
          return .second(second)
        } else {
          // Don't unnecessarily read from a now-unused source.
          isDone = true
        }
      case let (first?, second?):
        // Return the smaller element, if allowed by the exclusive/shared flags.
        if try areInIncreasingOrder(first, second) {
          cache.0 = nil
          if exclusivesFromFirst {
            return .nonMatching(first, second, firstIsLower: true)
          }
        } else if try areInIncreasingOrder(second, first) {
          cache.1 = nil
          if exclusivesFromSecond {
            return .nonMatching(first, second, firstIsLower: false)
          }
        } else {
          cache = (nil, nil)
          switch (sharedFromFirst, sharedFromSecond) {
          case (true, true):
            // Keep the second source's element in the cache, so it can be
            // retrieved during `.sum`.  At that point, it would look like an
            // exclusive-to-second, but that's OK because the only selection
            // with both shared statuses as `true` also has exclusive-to-second
            // as `true`.
            cache.1 = second
            fallthrough
          case (true, false):
            return .matching(first, second, useFirst: true)
          case (false, true):
            // Never reached because the selections that would trigger it make
            // the sequence look like an exclusive-to-second instead.
            return .matching(first, second, useFirst: false)
          case (false, false):
            break
          }
        }
      }
    }
    return nil
  }
}

internal extension MergedIterator {
  /// Advances to the next element and returns it, or `nil` if no next element
  /// exists; possibly throwing during the attempt.
  @usableFromInline
  mutating func throwingNext() throws -> Base2.Element? {
    switch try dualNext() {
    case .first(let element), .second(let element):
      return element
    case let .nonMatching(first, second, useFirst),
         let .matching(first, second, useFirst):
      return useFirst ? first : second
    case .none:
      return nil
    }
  }
}

extension MergedIterator: IteratorProtocol {
  @inlinable
  public mutating func next() -> Base1.Element? { return try! throwingNext() }
}

extension MergedSequence: Sequence, LazySequenceProtocol {
  public typealias Iterator = MergedIterator<Base1.Iterator, Base2.Iterator>
  public typealias Element = Iterator.Element

  @inlinable
  public func makeIterator() -> Iterator {
    return MergedIterator(firstBase.makeIterator(), secondBase.makeIterator(),
                          keeping: selection, by: areInIncreasingOrder)
  }

  @inlinable
  public var underestimatedCount: Int {
    switch selection {
    case .firstMinusSecond, .secondMinusFirst, .symmetricDifference,
         .intersection:
      // Can't even guesstimate these without reading elements.
      fallthrough
    case .nothing:
      return 0
    case .first:
      return firstBase.underestimatedCount
    case .second:
      return secondBase.underestimatedCount
    case .union:
      return Swift.max(firstBase.underestimatedCount,
                       secondBase.underestimatedCount)
    case .sum:
      return firstBase.underestimatedCount + secondBase.underestimatedCount
    }
  }

  @inlinable
  public func withContiguousStorageIfAvailable<R>(
    _ body: (UnsafeBufferPointer<Element>) throws -> R
  ) rethrows -> R? {
    switch selection {
    case .nothing:
      return try body(UnsafeBufferPointer(start: nil, count: 0))
    case .first:
      return try firstBase.withContiguousStorageIfAvailable(body)
    case .second:
      return try secondBase.withContiguousStorageIfAvailable(body)
    default:
      return nil
    }
  }

  @inlinable
  public func _customContainsEquatableElement(_ element: Element) -> Bool? {
    switch (selection, firstBase._customContainsEquatableElement(element),
            secondBase._customContainsEquatableElement(element)) {
    case (.nothing, _, _):
      return false
    case let (.intersection, contains1?, contains2?):
      return contains1 && contains2
    case let (.first, possiblyContains1, _):
      return possiblyContains1
    case let (.second, _, possiblyContains2):
      return possiblyContains2
    case let (.union, contains1?, contains2?),
         let (.sum, contains1?, contains2?):
      return contains1 || contains2
    case (.union, true, _), (.union, _, true), (.sum, true, _), (.sum, _, true):
      return true
    default:
      // - .intersection can't work if at least one is NIL.
      // - .union and .sum can't work with dual NIL or one NIL and one FALSE.
      // - .firstMinusSecond, .secondMinusFirst, and .symmetricDifference can't
      //   work with just existence; they need the full counts.
      return nil
    }
  }
}

//===----------------------------------------------------------------------===//
// mergeSorted(with: keeping: into: by:)
//===----------------------------------------------------------------------===//

internal extension Sequence {
  /// Returns an instance of the given type whose elements are the merger of
  /// this sequence and the given sequence, but keeping only the selected subset
  /// of elements, assuming both sources are sorted according to the given
  /// predicate that can compare elements.
  ///
  /// The predicate must be a *strict weak ordering* over the elements. That
  /// is, for any elements `a`, `b`, and `c`, the following conditions must
  /// hold:
  ///
  /// - `areInIncreasingOrder(a, a)` is always `false`. (Irreflexivity)
  /// - If `areInIncreasingOrder(a, b)` and `areInIncreasingOrder(b, c)` are
  ///   both `true`, then `areInIncreasingOrder(a, c)` is also
  ///   `true`. (Transitive comparability)
  /// - Two elements are *incomparable* if neither is ordered before the other
  ///   according to the predicate. If `a` and `b` are incomparable, and `b`
  ///   and `c` are incomparable, then `a` and `c` are also incomparable.
  ///   (Transitive incomparability)
  ///
  /// - Precondition:
  ///   - Both the receiver and `second` must be sorted according to
  ///     `areInIncreasingOrder`.
  ///   - If `selection` is neither `.nothing` nor `.second`, the receiver must
  ///     be finite.
  ///   - If `selection` is neither `.nothing` nor `.first`, `second` must be
  ///     finite.
  ///
  /// - Parameters:
  ///   - second: A sequence to merge with this sequence, as the second operand.
  ///   - selection: The subset of the merged multiset to return.
  ///   - type: A specifier for the returned instance's type.
  ///   - areInIncreasingOrder:  A predicate that returns `true` if its first
  ///     argument should be ordered before its second argument; otherwise,
  ///     `false`.
  /// - Returns: A collection with the elements of both this sequence and
  ///   `second`, still sorted, but instances banned by `selection` filtered
  ///   out.  If the selection allows a given value from both sequences, the
  ///   instances from the receiver will precede the instances from `second`.
  ///
  /// - Complexity: O(*n* + *m*), where *n* and *m* are the lengths of this
  ///   sequence and `second`, respectively.
  @usableFromInline
  func mergeSorted<S: Sequence, T: RangeReplaceableCollection>(
    with second: S,
    keeping selection: SetCombination,
    into type: T.Type,
    by areInIncreasingOrder: (Element, Element) throws -> Bool
  ) rethrows -> T where S.Element == Element, T.Element == Element {
    var destination = T()
    try withoutActuallyEscaping(areInIncreasingOrder) {
      let source = MergedSequence(self, second, keeping: selection, by: $0)
      var iterator = source.makeIterator()
      destination.reserveCapacity(source.underestimatedCount)
      while let element = try iterator.throwingNext() {
        // `iterator` above would flag an error if the call wasn't wrapped in a
        // closure, due to SR-680.
        destination.append(element)
      }
    }
    return destination
  }
}

//===----------------------------------------------------------------------===//
// mergeSorted(with: keeping: by:)
//===----------------------------------------------------------------------===//

extension Sequence {
  /// Returns an array listing the merger of this sequence and the given
  /// sequence, but keeping only the selected subset, assuming both sources are
  /// sorted according to the given predicate that can compare elements.
  ///
  /// The predicate must be a *strict weak ordering* over the elements. That
  /// is, for any elements `a`, `b`, and `c`, the following conditions must
  /// hold:
  ///
  /// - `areInIncreasingOrder(a, a)` is always `false`. (Irreflexivity)
  /// - If `areInIncreasingOrder(a, b)` and `areInIncreasingOrder(b, c)` are
  ///   both `true`, then `areInIncreasingOrder(a, c)` is also
  ///   `true`. (Transitive comparability)
  /// - Two elements are *incomparable* if neither is ordered before the other
  ///   according to the predicate. If `a` and `b` are incomparable, and `b`
  ///   and `c` are incomparable, then `a` and `c` are also incomparable.
  ///   (Transitive incomparability)
  ///
  /// - Precondition:
  ///   - Both the receiver and `second` must be sorted according to
  ///     `areInIncreasingOrder`.
  ///   - If `selection` is neither `.nothing` nor `.second`, the receiver must
  ///     be finite.
  ///   - If `selection` is neither `.nothing` nor `.first`, `second` must be
  ///     finite.
  ///
  /// - Parameters:
  ///   - second: A sequence to merge with this sequence, as the second operand.
  ///   - selection: The subset of the merged multiset to return.
  ///   - areInIncreasingOrder:  A predicate that returns `true` if its first
  ///     argument should be ordered before its second argument; otherwise,
  ///     `false`.
  /// - Returns: An array with the elements of both this sequence and `second`,
  ///   still sorted, but instances banned by `selection` filtered out.  If the
  ///   selection allows a given value from both sequences, the instances from
  ///   the receiver will precede the instances from `second`.
  ///
  /// - Complexity: O(*n* + *m*), where *n* and *m* are the lengths of this
  ///   sequence and `second`, respectively.
  @inlinable
  public func mergeSorted<S: Sequence>(
    with second: S,
    keeping selection: SetCombination,
    by areInIncreasingOrder: (Element, Element) throws -> Bool
  ) rethrows -> [Element] where S.Element == Element {
    return try mergeSorted(with: second, keeping: selection, into: Array.self,
                           by: areInIncreasingOrder)
  }
}

extension LazySequenceProtocol {
  /// Returns a lazy sequence listing the merger of this lazy sequence and the
  /// given lazy sequence, but keeping only the selected subset, assuming both
  /// sources are sorted according to the given predicate that can compare
  /// elements.
  ///
  /// The predicate must be a *strict weak ordering* over the elements. That
  /// is, for any elements `a`, `b`, and `c`, the following conditions must
  /// hold:
  ///
  /// - `areInIncreasingOrder(a, a)` is always `false`. (Irreflexivity)
  /// - If `areInIncreasingOrder(a, b)` and `areInIncreasingOrder(b, c)` are
  ///   both `true`, then `areInIncreasingOrder(a, c)` is also
  ///   `true`. (Transitive comparability)
  /// - Two elements are *incomparable* if neither is ordered before the other
  ///   according to the predicate. If `a` and `b` are incomparable, and `b`
  ///   and `c` are incomparable, then `a` and `c` are also incomparable.
  ///   (Transitive incomparability)
  ///
  /// The result sequence may be finite, even with a non-finite operand, if the
  /// `selection` indicates that the operand won't be used.  If a non-finite
  /// operand is used, an element extraction may soft-lock if the operand never
  /// emits a filtered-in value.
  ///
  /// - Precondition: Both the receiver and `second` must be sorted according to
  ///   `areInIncreasingOrder`.
  ///
  /// - Parameters:
  ///   - second: A lazy sequence to merge with this sequence, as the second
  ///     operand.
  ///   - selection: The subset of the merged multiset to return.
  ///   - areInIncreasingOrder:  A predicate that returns `true` if its first
  ///     argument should be ordered before its second argument; otherwise,
  ///     `false`.
  /// - Returns: A lazy sequence with the elements of both this sequence and
  ///   `second`, still sorted, but instances banned by `selection` filtered
  ///   out.  If the selection allows a given value from both sequences, the
  ///   instances from the receiver will precede the instances from `second`.
  @inlinable
  public func mergeSorted<S: LazySequenceProtocol>(
    with second: S,
    keeping selection: SetCombination,
    by areInIncreasingOrder: @escaping (Element, Element) -> Bool
  ) -> MergedSequence<Elements, S.Elements> where S.Element == Element {
    return MergedSequence(elements, second.elements, keeping: selection,
                          by: areInIncreasingOrder)
  }

  /// Returns a lazy sequence listing the merger of this lazy sequence and the
  /// given sequence, but keeping only the selected subset, assuming both
  /// sources are sorted according to the given predicate that can compare
  /// elements.
  ///
  /// The predicate must be a *strict weak ordering* over the elements. That
  /// is, for any elements `a`, `b`, and `c`, the following conditions must
  /// hold:
  ///
  /// - `areInIncreasingOrder(a, a)` is always `false`. (Irreflexivity)
  /// - If `areInIncreasingOrder(a, b)` and `areInIncreasingOrder(b, c)` are
  ///   both `true`, then `areInIncreasingOrder(a, c)` is also
  ///   `true`. (Transitive comparability)
  /// - Two elements are *incomparable* if neither is ordered before the other
  ///   according to the predicate. If `a` and `b` are incomparable, and `b`
  ///   and `c` are incomparable, then `a` and `c` are also incomparable.
  ///   (Transitive incomparability)
  ///
  /// The result sequence may be finite, even with a non-finite operand, if the
  /// `selection` indicates that the operand won't be used.  If a non-finite
  /// operand is used, an element extraction may soft-lock if the operand never
  /// emits a filtered-in value.
  ///
  /// - Precondition: Both the receiver and `second` must be sorted according to
  ///   `areInIncreasingOrder`.
  ///
  /// - Parameters:
  ///   - second: A sequence to merge with this sequence, as the second operand.
  ///   - selection: The subset of the merged multiset to return.
  ///   - areInIncreasingOrder:  A predicate that returns `true` if its first
  ///     argument should be ordered before its second argument; otherwise,
  ///     `false`.
  /// - Returns: A lazily-generated sequence using the elements of both this
  ///   sequence and `second`, still sorted, but instances banned by `selection`
  ///   are filtered out.  If the selection allows a given value from both
  ///   sequences, the instances from the receiver will precede the instances
  ///   from `second`.
  @inlinable
  public func mergeSorted<S: Sequence>(
    with second: S,
    keeping selection: SetCombination,
    by areInIncreasingOrder: @escaping (Element, Element) -> Bool
  ) -> MergedSequence<Elements, S> where S.Element == Element {
    return mergeSorted(with: second.lazy, keeping: selection,
                       by: areInIncreasingOrder)
  }
}

//===----------------------------------------------------------------------===//
// mergeSorted(with: keeping:)
//===----------------------------------------------------------------------===//

extension Sequence where Element: Comparable {
  /// Returns an array listing the merger of this sequence and the given
  /// sequence, but keeping only the selected subset, and assuming both sources
  /// are sorted.
  ///
  /// - Precondition:
  ///   - Both the receiver and `second` must be sorted.
  ///   - If `selection` is neither `.nothing` nor `.second`, the receiver must
  ///     be finite.
  ///   - If `selection` is neither `.nothing` nor `.first`, `second` must be
  ///     finite.
  ///
  /// - Parameters:
  ///   - second: A sequence to merge with this sequence, as the second operand.
  ///   - selection: The subset of the merged multiset to return.
  /// - Returns: An array with the elements of both this sequence and `second`,
  ///   still sorted, but instances banned by `selection` filtered out.  If the
  ///   selection allows a given value from both sequences, the instances from
  ///   the receiver will precede the instances from `second`.
  ///
  /// - Complexity: O(*n* + *m*), where *n* and *m* are the lengths of this
  ///   sequence and `second`, respectively.
  @inlinable
  public func mergeSorted<S: Sequence>(
    with second: S,
    keeping selection: SetCombination
  ) -> [Element] where S.Element == Element {
    return mergeSorted(with: second, keeping: selection, by: <)
  }
}

extension LazySequenceProtocol where Element: Comparable {
  /// Returns a lazy sequence listing the merger of this lazy sequence and the
  /// given lazy sequence, but keeping only the selected subset, and assuming
  /// both sources are sorted.
  ///
  /// The result sequence may be finite, even with a non-finite operand, if the
  /// `selection` indicates that the operand won't be used.  If a non-finite
  /// operand is used, an element extraction may soft-lock if the operand never
  /// emits a filtered-in value.
  ///
  /// - Precondition: Both the receiver and `second` must be sorted.
  ///
  /// - Parameters:
  ///   - second: A lazy sequence to merge with this sequence, as the second
  ///     operand.
  ///   - selection: The subset of the merged multiset to return.
  /// - Returns: A lazy sequence with the elements of both this sequence and
  ///   `second`, still sorted, but instances banned by `selection` filtered
  ///   out.  If the selection allows a given value from both sequences, the
  ///   instances from the receiver will precede the instances from `second`.
  @inlinable
  public func mergeSorted<S: LazySequenceProtocol>(
    with second: S,
    keeping selection: SetCombination
  ) -> MergedSequence<Elements, S.Elements> where S.Element == Element {
    return mergeSorted(with: second, keeping: selection, by: <)
  }

  /// Returns a lazy sequence listing the merger of this lazy sequence and the
  /// given sequence, but keeping only the selected subset, and assuming both
  /// sources are sorted.
  ///
  /// The result sequence may be finite, even with a non-finite operand, if the
  /// `selection` indicates that the operand won't be used.  If a non-finite
  /// operand is used, an element extraction may soft-lock if the operand never
  /// emits a filtered-in value.
  ///
  /// - Precondition: Both the receiver and `second` must be sorted.
  ///
  /// - Parameters:
  ///   - second: A sequence to merge with this sequence, as the second operand.
  ///   - selection: The subset of the merged multiset to return.
  /// - Returns: A lazily-generated sequence using the elements of both this
  ///   sequence and `second`, still sorted, but instances banned by `selection`
  ///   are filtered out.  If the selection allows a given value from both
  ///   sequences, the instances from the receiver will precede the instances
  ///   from `second`.
  @inlinable
  public func mergeSorted<S: Sequence>(
    with second: S,
    keeping selection: SetCombination
  ) -> MergedSequence<Elements, S> where S.Element == Element {
    return mergeSorted(with: second, keeping: selection, by: <)
  }
}
