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
  /// In the `AdjacentPairs` instance returned by this method, the elements of
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
  public func adjacentPairs() -> AdjacentPairs<Self> {
    AdjacentPairs(_base: self)
  }
}

/// A sequence of adjacent pairs of elements built from an underlying sequence.
///
/// In an `AdjacentPairs` sequence, the elements of the *i*th pair are the *i*th
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
public struct AdjacentPairs<Base: Sequence> {
  internal let _base: Base

  /// Creates an instance that makes pairs of adjacent elements from `base`.
  internal init(_base: Base) {
    self._base = _base
  }
}

// MARK: - Sequence

extension AdjacentPairs {
  public struct Iterator {
    internal var _base: Base.Iterator
    internal var _previousElement: Base.Element?

    internal init(_base: Base.Iterator) {
      self._base = _base
      self._previousElement = self._base.next()
    }
  }
}

extension AdjacentPairs.Iterator: IteratorProtocol {
  public typealias Element = (Base.Element, Base.Element)

  public mutating func next() -> Element? {
    guard let previous = _previousElement, let next = _base.next() else {
      return nil
    }
    _previousElement = next
    return (previous, next)
  }
}

extension AdjacentPairs: Sequence {
  public func makeIterator() -> Iterator {
    Iterator(_base: _base.makeIterator())
  }

  public var underestimatedCount: Int {
    Swift.max(0, _base.underestimatedCount - 1)
  }
}

// MARK: - Collection

extension AdjacentPairs where Base: Collection {
  public struct Index: Comparable {
    internal var _base: Base.Index

    internal init(_base: Base.Index) {
      self._base = _base
    }

    public static func < (lhs: Index, rhs: Index) -> Bool {
      lhs._base < rhs._base
    }
  }
}

extension AdjacentPairs: Collection where Base: Collection {
  public var startIndex: Index { Index(_base: _base.startIndex) }

  public var endIndex: Index {
    switch _base.endIndex {
    case _base.startIndex, _base.index(after: _base.startIndex):
      return Index(_base: _base.startIndex)
    case let endIndex:
      return Index(_base: endIndex)
    }
  }

  public subscript(position: Index) -> (Base.Element, Base.Element) {
    (_base[position._base], _base[_base.index(after: position._base)])
  }

  public func index(after i: Index) -> Index {
    let next = _base.index(after: i._base)
    return _base.index(after: next) == _base.endIndex
      ? endIndex
      : Index(_base: next)
  }

  public func index(_ i: Index, offsetBy distance: Int) -> Index {
    if distance == 0 {
      return i
    } else if distance > 0 {
      let offsetIndex = _base.index(i._base, offsetBy: distance)
      return _base.index(after: offsetIndex) == _base.endIndex
        ? endIndex
        : Index(_base: offsetIndex)
    } else {
      return i == endIndex
        ? Index(_base: _base.index(i._base, offsetBy: distance - 1))
        : Index(_base: _base.index(i._base, offsetBy: distance))
    }
  }

  public func distance(from start: Index, to end: Index) -> Int {
    let offset: Int
    switch (start._base, end._base) {
    case (_base.endIndex, _base.endIndex):
      return 0
    case (_base.endIndex, _):
      offset = +1
    case (_, _base.endIndex):
      offset = -1
    default:
      offset = 0
    }

    return _base.distance(from: start._base, to: end._base) + offset
  }

  public var count: Int {
    Swift.max(0, _base.count - 1)
  }
}

extension AdjacentPairs: BidirectionalCollection
  where Base: BidirectionalCollection
{
  public func index(before i: Index) -> Index {
    i == endIndex
      ? Index(_base: _base.index(i._base, offsetBy: -2))
      : Index(_base: _base.index(before: i._base))
  }
}

extension AdjacentPairs: RandomAccessCollection
  where Base: RandomAccessCollection {}
