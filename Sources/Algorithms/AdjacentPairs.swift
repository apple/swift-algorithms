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
  /// sequence. The following example uses the `adjacentPairs()` method to
  /// iterate over adjacent pairs of integers:
  ///
  ///     for pair in (1...).prefix(5).adjacentPairs() {
  ///         print(pair)
  ///     }
  ///     // Prints "(1, 2)"
  ///     // Prints "(2, 3)"
  ///     // Prints "(3, 4)"
  ///     // Prints "(4, 5)"
  @inlinable
  public func adjacentPairs() -> AdjacentPairsSequence<Self> {
    AdjacentPairsSequence(base: self)
  }
}

extension Collection {
  /// A collection of adjacent pairs of elements built from an underlying
  /// collection.
  ///
  /// In an `AdjacentPairsCollection`, the elements of the *i*th pair are the
  /// *i*th and *(i+1)*th elements of the underlying sequence. The following
  /// example uses the `adjacentPairs()` method to iterate over adjacent pairs
  /// of integers:
  ///
  ///     for pair in (1...5).adjacentPairs() {
  ///         print(pair)
  ///     }
  ///     // Prints "(1, 2)"
  ///     // Prints "(2, 3)"
  ///     // Prints "(3, 4)"
  ///     // Prints "(4, 5)"
  @inlinable
  public func adjacentPairs() -> AdjacentPairsCollection<Self> {
    AdjacentPairsCollection(base: self)
  }
}

/// A sequence of adjacent pairs of elements built from an underlying sequence.
///
/// Use the `adjacentPairs()` method on a sequence to create an
/// `AdjacentPairsSequence` instance.
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
  /// The iterator for an `AdjacentPairsSequence` or `AdjacentPairsCollection`
  /// instance.
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

extension AdjacentPairsSequence: LazySequenceProtocol
  where Base: LazySequenceProtocol {}

/// A collection of adjacent pairs of elements built from an underlying
/// collection.
///
/// Use the `adjacentPairs()` method on a collection to create an
/// `AdjacentPairsCollection` instance.
public struct AdjacentPairsCollection<Base: Collection> {
  @usableFromInline
  internal let base: Base

  @usableFromInline
  internal let secondBaseIndex: Base.Index

  @inlinable
  internal init(base: Base) {
    self.base = base
    self.secondBaseIndex = base.isEmpty
      ? base.endIndex
      : base.index(after: base.startIndex)
  }
}

extension AdjacentPairsCollection {
  /// A position in an `AdjacentPairsCollection` instance.
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
    public static func == (lhs: Index, rhs: Index) -> Bool {
      lhs.first == rhs.first
    }
    
    @inlinable
    public static func < (lhs: Index, rhs: Index) -> Bool {
      lhs.first < rhs.first
    }
  }
}

extension AdjacentPairsCollection: Collection {
  @inlinable
  public var startIndex: Index {
    Index(
      first: secondBaseIndex == base.endIndex ? base.endIndex : base.startIndex,
      second: secondBaseIndex)
  }
  
  @inlinable
  public var endIndex: Index {
    Index(first: base.endIndex, second: base.endIndex)
  }

  @inlinable
  public subscript(position: Index) -> (Base.Element, Base.Element) {
    (base[position.first], base[position.second])
  }

  @inlinable
  public func index(after i: Index) -> Index {
    precondition(i != endIndex, "Can't advance beyond endIndex")
    let next = base.index(after: i.second)
    return next == base.endIndex
      ? endIndex
      : Index(first: i.second, second: next)
  }

  @inlinable
  public func index(_ i: Index, offsetBy distance: Int) -> Index {
    guard distance != 0 else { return i }

    guard let result = distance > 0
      ? offsetForward(i, by: distance, limitedBy: endIndex)
      : offsetBackward(i, by: -distance, limitedBy: startIndex)
    else { fatalError("Index out of bounds") }
    return result
  }

  @inlinable
  public func index(
    _ i: Index, offsetBy distance: Int, limitedBy limit: Index
  ) -> Index? {
    guard distance != 0 else { return i }
    guard limit != i else { return nil }
    
    if distance > 0 {
      let limit = limit > i ? limit : endIndex
      return offsetForward(i, by: distance, limitedBy: limit)
    } else {
      let limit = limit < i ? limit : startIndex
      return offsetBackward(i, by: -distance, limitedBy: limit)
    }
  }
  
  @inlinable
  internal func offsetForward(
    _ i: Index, by distance: Int, limitedBy limit: Index
  ) -> Index? {
    assert(distance > 0)
    assert(limit > i)
    
    guard let newFirst = base.index(i.second, offsetBy: distance - 1, limitedBy: limit.first),
          newFirst != base.endIndex
    else { return nil }
    let newSecond = base.index(after: newFirst)
    
    precondition(newSecond <= base.endIndex, "Can't advance beyond endIndex")
    return newSecond == base.endIndex
      ? endIndex
      : Index(first: newFirst, second: newSecond)
  }
  
  @inlinable
  internal func offsetBackward(
    _ i: Index, by distance: Int, limitedBy limit: Index
  ) -> Index? {
    assert(distance > 0)
    assert(limit < i)
        
    let offset = i == endIndex ? 0 : 1
    guard let newSecond = base.index(
      i.first,
      offsetBy: -(distance - offset),
      limitedBy: limit.second)
    else { return nil }
    let newFirst = base.index(newSecond, offsetBy: -1)
    precondition(newFirst >= base.startIndex, "Can't move before startIndex")
    return Index(first: newFirst, second: newSecond)
  }

  @inlinable
  public func distance(from start: Index, to end: Index) -> Int {
    // While there's a 2-step gap between the `first` base index values in
    // `endIndex` and the penultimate index of this collection, the `second`
    // base index values are consistently one step apart throughout the
    // entire collection.
    base.distance(from: start.second, to: end.second)
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
    precondition(i != startIndex, "Can't offset before startIndex")
    let second = i == endIndex
      ? base.index(before: base.endIndex)
      : i.first
    let first = base.index(before: second)
    return Index(first: first, second: second)
  }
}

extension AdjacentPairsCollection: RandomAccessCollection
  where Base: RandomAccessCollection {}

extension AdjacentPairsCollection: LazySequenceProtocol, LazyCollectionProtocol
  where Base: LazySequenceProtocol {}

extension AdjacentPairsCollection.Index: Hashable where Base.Index: Hashable {
  @inlinable
  public func hash(into hasher: inout Hasher) {
    hasher.combine(first)
  }
}
