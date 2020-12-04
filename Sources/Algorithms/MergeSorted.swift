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
  case matching(Element, Element)
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
          case (true, false), (false, true):
            // The second case above is never actually reached, because it'll
            // look like an exclusive-to-second by access time.
            return .matching(first, second)
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
    case let .nonMatching(first, second, useFirst):
      return useFirst ? first : second
    case let .matching(first, _):
      return first
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
// MergedCollectionSteps, MergedCollectionStepIterator,
// MergedCollectionIterationStep
//===----------------------------------------------------------------------===//

/// An iteration step within a `MergedSequence` when both sorted sources are
/// collections.
public struct MergedCollectionIterationStep<Base1: Comparable,
                                            Base2: Comparable> {
  /// Index to the current or upcoming element in the first source.
  public let first: Base1
  /// Index to the current or upcoming element in the second source.
  public let second: Base2
  /// Whether `first` points to a current element.
  public let useFirst: Bool
  /// Whether `second` points to a current element.
  public let useSecond: Bool

  /// Creates an index from the given source indices, and caching their
  /// dereferencing statuses.
  @usableFromInline
  init(_ base1: Base1, _ base2: Base2, useFirst: Bool, useSecond: Bool) {
    first = base1
    second = base2
    self.useFirst = useFirst
    self.useSecond = useSecond
  }
}

extension MergedCollectionIterationStep: Equatable {}

extension MergedCollectionIterationStep: Hashable
where Base1: Hashable, Base2: Hashable {}

extension MergedCollectionIterationStep: Comparable {
  public static func < (lhs: Self, rhs: Self) -> Bool {
    // The expression assumes that a failed comparison represents that its
    // terms are equal.  If we get one less-than and one greater-than, then this
    // setup is inconsistent.  That shouldn't happen and we won't waste time
    // looking for it.
    return lhs.first < rhs.first || lhs.second < rhs.second
  }
}

/// Enables instances of one of two types be considered under a single type.
fileprivate enum Either<First, Second> {
  /// Stores an instance of the first type.
  case first(First)
  /// Stores an instance of the second type.
  case second(Second)
}

/// An iterator over of the steps taken to generate a `MergedSequence`, but only
/// when both sorted sources are collections.
public struct MergedCollectionStepIterator<Base1: Collection, Base2: Collection>
where Base1.Element == Base2.Element {
  /// The element type for each operand.
  @usableFromInline
  typealias InnerElement = Base1.Element
  /// The first operand expressed as elements and indices.
  typealias FirstIndexed = Indexed<Base1>
  /// The second operand expressed as elements and indices.
  typealias SecondIndexed = Indexed<Base2>
  /// The consolidation of operands' elements and indices.
  fileprivate typealias EitherElement = Either<FirstIndexed.Element,
                                               SecondIndexed.Element>
  /// The converter for the first operand.
  fileprivate typealias FirstAsEither = LazyMapCollection<FirstIndexed,
                                                          EitherElement>
  /// The converter for the second operand.
  fileprivate typealias SecondAsEither = LazyMapCollection<SecondIndexed,
                                                           EitherElement>
  /// An iterator for generating the raw stepping data.
  fileprivate typealias Core = MergedIterator<FirstAsEither.Iterator,
                                              SecondAsEither.Iterator>

  /// The iterator generating the raw stepping data.
  fileprivate var core: Core
  /// The past-the-end index for the first operand, to be used when the current
  /// marker exhausted that collection.
  let firstEndIndex: Base1.Index
  /// The past-the-end index for the second operand, to be used when the current
  /// marker exhuasted that collection.
  let secondEndIndex: Base2.Index

  /// Creates an iterator showing how two sorted collections' elements are
  /// visited to generate the sorted merger of those collections, all using the
  /// given predicate to determine order, but keeping only the elements
  /// indicated by the given status.
  @usableFromInline
  init(_ base1: Base1, _ base2: Base2, keeping selection: SetCombination,
    by areInIncreasingOrder: @escaping (InnerElement, InnerElement) -> Bool
  ) {
    let firstMarkers = base1.indexed().lazy.map(EitherElement.first)
    let secondMarkers = base2.indexed().lazy.map(EitherElement.second)
    let eitherCompare: (EitherElement, EitherElement) -> Bool = {
      switch ($0, $1) {
      case let (.first(indexed1), .first(indexed2)):
        return areInIncreasingOrder(indexed1.element, indexed2.element)
      case let (.first(indexed1), .second(indexed2)):
        return areInIncreasingOrder(indexed1.element, indexed2.element)
      case let (.second(indexed1), .first(indexed2)):
        return areInIncreasingOrder(indexed1.element, indexed2.element)
      case let (.second(indexed1), .second(indexed2)):
        return areInIncreasingOrder(indexed1.element, indexed2.element)
      }
    }
    core = Core(firstMarkers.makeIterator(), secondMarkers.makeIterator(),
                keeping: selection, by: eitherCompare)
    firstEndIndex = base1.endIndex
    secondEndIndex = base2.endIndex
  }
}

extension MergedCollectionStepIterator: IteratorProtocol {
  public mutating func next() -> MergedCollectionIterationStep<Base1.Index,
                                                               Base2.Index>? {
    switch try! core.dualNext() {
    case let .first(.first((idx1, _))):
      return Element(idx1, secondEndIndex, useFirst: true, useSecond: false)
    case let .second(.second((idx2, _))):
      return Element(firstEndIndex, idx2, useFirst: false, useSecond: true)
    case let .nonMatching(.first((idx1, _)), .second((idx2, _)), firstIsLower):
      return Element(idx1, idx2, useFirst: firstIsLower,
                     useSecond: !firstIsLower)
    case let .matching(.first((idx1, _)), .second((idx2, _))):
      return Element(idx1, idx2, useFirst: true, useSecond: true)
    case .none:
      return nil
    case .first(.second), .second(.first), .nonMatching(.first, .first, _),
         .nonMatching(.second, _, _), .matching(.first, .first),
         .matching(.second, _):
      preconditionFailure("Illegal combination of inner indices")
    }
  }
}

/// A sequence over the steps taken to generate a `MergedSequence`, but only
/// when both sorted sources are collections.
///
/// - Warning: When an instance also conforms to `Collection`, generation of
///   `startIndex` will take O(*n* + *m*) time instead of O(1) time, where *n*
///   and *m* are the lengths of the source collections.  This also affects
///   anything implemented with `startIndex`, like `isEmpty`.
public struct MergedCollectionSteps<Base1: Collection, Base2: Collection>
where Base1.Element == Base2.Element {
  /// The element type for each operand.
  @usableFromInline
  typealias InnerElement = Base2.Element

  /// The base collection for the first operand.
  public let firstBase: Base1
  /// The base collection for the second operand.
  public let secondBase: Base2
  /// The blend of the merger to vend.
  public let selection: SetCombination
  /// The element-ordering predicate.
  @usableFromInline
  let areInIncreasingOrder: (InnerElement, InnerElement) -> Bool

  /// Creates a sorted sequence that merges the two given sorted sequences, all
  /// using the given predicate to determine order, but keeping only the elements
  /// indicated by the given status.
  @usableFromInline
  init(_ base1: Base1, _ base2: Base2, keeping selection: SetCombination,
    by areInIncreasingOrder: @escaping (InnerElement, InnerElement) -> Bool
  ) {
    firstBase = base1
    secondBase = base2
    self.selection = selection
    self.areInIncreasingOrder = areInIncreasingOrder
  }
}

extension MergedCollectionSteps: Sequence {
  @inlinable
  public var underestimatedCount: Int {
    // Reuse the code from MergedSequence.underestimatedCount.  This requires
    // somehow removing the Collection conformance from at least one of the
    // operands.  Otherwise, that sequence will also be a Collection, which may
    // use a version of this generic type as its Indices, leading to an
    // escalating infinite recursion.
    MergedSequence(AnySequence(firstBase), AnySequence(secondBase),
                   keeping: selection, by: areInIncreasingOrder)
      .underestimatedCount
  }

  @inlinable
  public func makeIterator() -> MergedCollectionStepIterator<Base1, Base2> {
    return Iterator(firstBase, secondBase, keeping: selection,
                    by: areInIncreasingOrder)
  }
}

extension MergedCollectionSteps: Collection
where Base1.SubSequence == Base1, Base2.SubSequence == Base2 {
  public typealias Index = Element
  public typealias SubSequence = Self

  @inlinable
  public var startIndex: Index {
    var iterator = makeIterator()
    return iterator.next() ?? endIndex
  }
  public var endIndex: Index {
    Index(firstBase.endIndex, secondBase.endIndex, useFirst: false,
          useSecond: false)
  }

  @inlinable public subscript(position: Index) -> Element { return position }
  @inlinable
  public subscript(bounds: Range<Index>) -> SubSequence {
    let subBase1 = firstBase[bounds.lowerBound.first..<bounds.upperBound.first]
    let subBase2 = secondBase[bounds.lowerBound.second ..<
                                bounds.upperBound.second]
    return SubSequence(subBase1, subBase2, keeping: selection,
                       by: areInIncreasingOrder)
  }

  public func index(after i: Index) -> Index {
    let suffix = self[i...]
    var iterator = suffix.makeIterator()
    if let firstSuffixElement = iterator.next() {
      assert(firstSuffixElement == i)
    } else {
      preconditionFailure("Attempt to increment past endIndex")
    }
    return iterator.next() ?? endIndex
  }
}

//===----------------------------------------------------------------------===//
// MergedCollection
//===----------------------------------------------------------------------===//

/// A lazy sorted collection of a set combination of two sorted source
/// collections.
///
/// - Warning: Calculation of `startIndex` will take O(*n* + *m*) time instead
///   of O(1) time, where *n* and *m* are the lengths of the source collections.
///   This also affects anything that needs to work with `startIndex`, like
///   `isEmpty`.
public typealias MergedCollection<T: Collection, U: Collection> =
  MergedSequence<T, U> where T.Element == U.Element

extension MergedCollection {
  /// A sequence of each iteration stop.
  public typealias IterationSteps = MergedCollectionSteps<Base1, Base2>

  /// Expresses the sequence the elements from both operand collections in
  /// formation are visited.
  @inlinable
  public var iterationSteps: IterationSteps {
    IterationSteps(firstBase, secondBase, keeping: selection) {
      try! areInIncreasingOrder($0, $1)
    }
  }
}

extension MergedSequence: Collection, LazyCollectionProtocol
where Base1: Collection, Base2: Collection {
  public typealias Index = MergedCollectionIterationStep<Base1.Index,
                                                         Base2.Index>
  public typealias SubSequence = MergedSequence<Base1.SubSequence,
                                                Base2.SubSequence>

  /// Expresses a quick-and-dirty reference to the entire collection, without
  /// risking infinite recursion.
  @usableFromInline
  var subSelf: SubSequence {
    SubSequence(firstBase[...], secondBase[...], keeping: selection,
                by: areInIncreasingOrder)
  }

  @inlinable
  public var indices: SubSequence.IterationSteps { subSelf.iterationSteps }
  @inlinable public var startIndex: Index { indices.startIndex }
  @inlinable public var endIndex: Index { indices.endIndex }

  @inlinable
  public subscript(position: Index) -> Element {
    if position.useFirst {
      return firstBase[position.first]
    } else if position.useSecond {
      return secondBase[position.second]
    } else {
      preconditionFailure("Attempt to dereference endIndex")
    }
  }
  @inlinable
  public subscript(bounds: Range<Index>) -> SubSequence {
    let subBase1 = firstBase[bounds.lowerBound.first..<bounds.upperBound.first]
    let subBase2 = secondBase[bounds.lowerBound.second ..<
                                bounds.upperBound.second]
    return SubSequence(subBase1, subBase2, keeping: selection,
                       by: areInIncreasingOrder)
  }

  @inlinable
  public func index(after i: Index) -> Index {
    return self[i...].indices.index(after: i)
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
