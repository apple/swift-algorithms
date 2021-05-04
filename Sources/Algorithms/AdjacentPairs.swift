//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift Algorithms open source project
//
// Copyright (c) 2021 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

extension Sequence {
  /// Creates a sequence of adjacent pairs of elements from this sequence.
  ///
  /// In the `AdjacentPairsSequence` returned by this method, the elements of
  /// the *i*th pair are the *i*th and *(i+1)*th elements of the underlying
  /// sequence.
  /// The following example uses the `adjacentPairs()` method to iterate over
  /// adjacent pairs of integers:
  ///
  ///    for pair in (1...5).adjacentPairs() {
  ///        print(pair)
  ///    }
  ///    // Prints "(1, 2)"
  ///    // Prints "(2, 3)"
  ///    // Prints "(3, 4)"
  ///    // Prints "(4, 5)"
  @inlinable
  public func adjacentPairs() -> AdjacentPairsSequence<Self> {
    AdjacentPairsSequence(base: self)
  }
}

extension Collection {
  /// A collection of adjacent pairs of elements built from an underlying collection.
  ///
  /// In an `AdjacentPairsCollection`, the elements of the *i*th pair are the *i*th
  /// and *(i+1)*th elements of the underlying sequence. The following example
  /// uses the `adjacentPairs()` method to iterate over adjacent pairs of
  /// integers:
  /// ```
  /// for pair in (1...5).adjacentPairs() {
  ///     print(pair)
  /// }
  /// // Prints "(1, 2)"
  /// // Prints "(2, 3)"
  /// // Prints "(3, 4)"
  /// // Prints "(4, 5)"
  /// ```
  @inlinable
  public func adjacentPairs() -> AdjacentPairsCollection<Self> {
    AdjacentPairsCollection(base: self)
  }
}

/// A sequence of adjacent pairs of elements built from an underlying sequence.
///
/// In an `AdjacentPairsSequence`, the elements of the *i*th pair are the *i*th
/// and *(i+1)*th elements of the underlying sequence. The following example
/// uses the `adjacentPairs()` method to iterate over adjacent pairs of
/// integers:
/// ```
/// for pair in (1...5).adjacentPairs() {
///     print(pair)
/// }
/// // Prints "(1, 2)"
/// // Prints "(2, 3)"
/// // Prints "(3, 4)"
/// // Prints "(4, 5)"
/// ```
public struct AdjacentPairsSequence<Base: Sequence> {
  @usableFromInline
  internal let base: Base

  /// Creates an instance that makes pairs of adjacent elements from `base`.
  @inlinable
  internal init(base: Base) {
    self.base = base
  }
}

extension AdjacentPairsSequence {
  public struct Iterator {
    @usableFromInline
    internal var base: Base.Iterator

    @usableFromInline
    internal var previousElement: Base.Element?

    @inlinable
    internal init(base: Base.Iterator) {
      self.base = base
    }
  }
}

extension AdjacentPairsSequence.Iterator: IteratorProtocol {
  public typealias Element = (Base.Element, Base.Element)

  @inlinable
  public mutating func next() -> Element? {
    if previousElement == nil {
      previousElement = base.next()
    }

    guard let previous = previousElement, let next = base.next() else {
      return nil
    }

    previousElement = next
    return (previous, next)
  }
}

extension AdjacentPairsSequence: Sequence {
  @inlinable
  public func makeIterator() -> Iterator {
    Iterator(base: base.makeIterator())
  }

  @inlinable
  public var underestimatedCount: Int {
    Swift.max(0, base.underestimatedCount - 1)
  }
}

/// A collection of adjacent pairs of elements built from an underlying collection.
///
/// In an `AdjacentPairsCollection`, the elements of the *i*th pair are the *i*th
/// and *(i+1)*th elements of the underlying sequence. The following example
/// uses the `adjacentPairs()` method to iterate over adjacent pairs of
/// integers:
/// ```
/// for pair in (1...5).adjacentPairs() {
///     print(pair)
/// }
/// // Prints "(1, 2)"
/// // Prints "(2, 3)"
/// // Prints "(3, 4)"
/// // Prints "(4, 5)"
/// ```
public struct AdjacentPairsCollection<Base: Collection> {
  @usableFromInline
  internal let base: Base

  public let startIndex: Index

  @inlinable
  internal init(base: Base) {
    self.base = base

    // Precompute `startIndex` to ensure O(1) behavior,
    // avoiding indexing past `endIndex`
    let start = base.startIndex
    let end = base.endIndex
    let second = start == end ? start : base.index(after: start)
    self.startIndex = Index(first: start, second: second)
  }
}

extension AdjacentPairsCollection {
  public typealias Iterator = AdjacentPairsSequence<Base>.Iterator

  @inlinable
  public func makeIterator() -> Iterator {
    Iterator(base: base.makeIterator())
  }
}

extension AdjacentPairsCollection {
  public struct Index: Comparable {
    @usableFromInline
    internal var first: Base.Index
    
    @usableFromInline
    internal var second: Base.Index

    @inlinable
    internal init(first: Base.Index, second: Base.Index) {
      self.first = first
      self.second = second
    }

    @inlinable
    public static func < (lhs: Index, rhs: Index) -> Bool {
      (lhs.first, lhs.second) < (rhs.first, rhs.second)
    }
  }
}

extension AdjacentPairsCollection: Collection {
  @inlinable
  public var endIndex: Index {
    switch base.endIndex {
    case startIndex.first, startIndex.second:
      return startIndex
    case let end:
      return Index(first: end, second: end)
    }
  }

  @inlinable
  public subscript(position: Index) -> (Base.Element, Base.Element) {
    (base[position.first], base[position.second])
  }

  @inlinable
  public func index(after i: Index) -> Index {
    let next = base.index(after: i.second)
    return next == base.endIndex
      ? endIndex
      : Index(first: i.second, second: next)
  }

  @inlinable
  public func index(_ i: Index, offsetBy distance: Int) -> Index {
    if distance == 0 {
      return i
    } else if distance > 0 {
      let firstOffsetIndex = base.index(i.first, offsetBy: distance)
      let secondOffsetIndex = base.index(after: firstOffsetIndex)
      return secondOffsetIndex == base.endIndex
        ? endIndex
        : Index(first: firstOffsetIndex, second: secondOffsetIndex)
    } else {
      return i == endIndex
        ? Index(first: base.index(i.first, offsetBy: distance - 1),
                second: base.index(i.first, offsetBy: distance))
        : Index(first: base.index(i.first, offsetBy: distance),
                second: i.first)
    }
  }

  @inlinable
  public func distance(from start: Index, to end: Index) -> Int {
    let offset: Int
    switch (start.first, end.first) {
    case (base.endIndex, base.endIndex):
      return 0
    case (base.endIndex, _):
      offset = +1
    case (_, base.endIndex):
      offset = -1
    default:
      offset = 0
    }

    return base.distance(from: start.first, to: end.first) + offset
  }

  @inlinable
  public var count: Int {
    Swift.max(0, base.count - 1)
  }
}

extension AdjacentPairsCollection: BidirectionalCollection
  where Base: BidirectionalCollection
{
  @inlinable
  public func index(before i: Index) -> Index {
    i == endIndex
      ? Index(first: base.index(i.first, offsetBy: -2),
              second: base.index(before: i.first))
      : Index(first: base.index(before: i.first),
              second: i.first)
  }
}

extension AdjacentPairsCollection: RandomAccessCollection
  where Base: RandomAccessCollection {}
