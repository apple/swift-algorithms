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

/// A `Sequence` that iterates over every non-nil element from the original
/// `Sequence`.
public struct CompactedSequence<Base: Sequence, Element>: Sequence
where Base.Element == Element? {

  @usableFromInline
  let base: Base

  @inlinable
  init(base: Base) {
    self.base = base
  }

  public struct Iterator: IteratorProtocol {
    @usableFromInline
    var base: Base.Iterator

    @inlinable
    init(base: Base.Iterator) {
      self.base = base
    }

    @inlinable
    public mutating func next() -> Element? {
      while let wrapped = base.next() {
        guard let some = wrapped else { continue }
        return some
      }
      return nil
    }
  }

  @inlinable
  public func makeIterator() -> Iterator {
    Iterator(base: base.makeIterator())
  }
}

extension Sequence {
  /// Returns a new `Sequence` that iterates over every non-nil element from the
  /// original `Sequence`.
  ///
  /// Produces the same result as `c.compactMap { $0 }`.
  ///
  ///     let c = [1, nil, 2, 3, nil]
  ///     for num in c.compacted() {
  ///         print(num)
  ///     }
  ///     // 1
  ///     // 2
  ///     // 3
  ///
  /// - Returns: A `Sequence` where the element is the unwrapped original
  ///   element and iterates over every non-nil element from the original
  ///   `Sequence`.
  ///
  /// Complexity: O(1)
  @inlinable
  public func compacted<Unwrapped>() -> CompactedSequence<Self, Unwrapped>
  where Element == Unwrapped? {
    CompactedSequence(base: self)
  }
}

/// A `Collection` that iterates over every non-nil element from the original
/// `Collection`.
public struct CompactedCollection<Base: Collection, Element>: Collection
where Base.Element == Element? {

  @usableFromInline
  let base: Base

  @inlinable
  init(base: Base) {
    self.base = base
    let idx = base.firstIndex(where: { $0 != nil }) ?? base.endIndex
    self.startIndex = Index(base: idx)
  }

  public struct Index {
    @usableFromInline
    let base: Base.Index

    @inlinable
    init(base: Base.Index) {
      self.base = base
    }
  }

  public var startIndex: Index

  @inlinable
  public var endIndex: Index { Index(base: base.endIndex) }

  @inlinable
  public subscript(position: Index) -> Element {
    // swift-format-ignore: NeverForceUnwrap
    // All indices are only for non-`nil` elements.
    base[position.base]!
  }

  @inlinable
  public func index(after i: Index) -> Index {
    precondition(i != endIndex, "Index out of bounds")

    let baseIdx = base.index(after: i.base)
    guard let idx = base[baseIdx...].firstIndex(where: { $0 != nil })
    else { return endIndex }
    return Index(base: idx)
  }

  // `index(_:offsetBy:)`, `index(_:offsetBy:limitedBy:)` and
  // `distance(from:to:)` are implemented in the unconditional `Collection`
  // conformance so that these implementations are also used when the
  // collection is accessed generically as a `BidirectionalCollection`.
  // Otherwise the default `Collection` implementations are used there, and
  // they trap for negative offsets. Stepping backward uses
  // `base.index(_:offsetBy: -1)`, which still traps if `Base` is not
  // bidirectional.

  @inlinable
  internal func indexBefore(_ i: Index) -> Index {
    precondition(i != startIndex, "Index out of bounds")
    // `startIndex` is the first non-`nil` element, so this stops at or after it.
    var baseIdx = i.base
    repeat {
      baseIdx = base.index(baseIdx, offsetBy: -1)
    } while base[baseIdx] == nil
    return Index(base: baseIdx)
  }

  @inlinable
  public func index(_ i: Index, offsetBy distance: Int) -> Index {
    var i = i
    if distance >= 0 {
      for _ in 0..<distance { formIndex(after: &i) }
    } else {
      for _ in 0..<(-distance) { i = indexBefore(i) }
    }
    return i
  }

  @inlinable
  public func index(
    _ i: Index,
    offsetBy distance: Int,
    limitedBy limit: Index
  ) -> Index? {
    var i = i
    if distance >= 0 {
      for _ in 0..<distance {
        guard i != limit else { return nil }
        formIndex(after: &i)
      }
    } else {
      for _ in 0..<(-distance) {
        guard i != limit else { return nil }
        i = indexBefore(i)
      }
    }
    return i
  }

  @inlinable
  public func distance(from start: Index, to end: Index) -> Int {
    guard start <= end else { return -distance(from: end, to: start) }
    var i = start
    var count = 0
    while i != end {
      formIndex(after: &i)
      count += 1
    }
    return count
  }
}

extension CompactedCollection: BidirectionalCollection
where Base: BidirectionalCollection {
  @inlinable
  public func index(before i: Index) -> Index {
    indexBefore(i)
  }
}

extension CompactedCollection.Index: Comparable {
  @inlinable
  public static func < (
    lhs: CompactedCollection.Index,
    rhs: CompactedCollection.Index
  ) -> Bool {
    lhs.base < rhs.base
  }
}

extension CompactedCollection.Index: Hashable
where Base.Index: Hashable {}

extension Collection {
  /// Returns a new `Collection` that iterates over every non-nil element from
  /// the original `Collection`.
  ///
  /// Produces the same result as `c.compactMap { $0 }`.
  ///
  ///     let c = [1, nil, 2, 3, nil]
  ///     for num in c.compacted() {
  ///         print(num)
  ///     }
  ///     // 1
  ///     // 2
  ///     // 3
  ///
  /// - Returns: A `Collection` where the element is the unwrapped original
  ///   element and iterates over every non-nil element from the original
  ///   `Collection`.
  ///
  /// Complexity: O(*n*) where *n* is the number of elements in the
  /// original `Collection`.
  @inlinable
  public func compacted<Unwrapped>() -> CompactedCollection<Self, Unwrapped>
  where Element == Unwrapped? {
    CompactedCollection(base: self)
  }
}

//===----------------------------------------------------------------------===//
// Protocol Conformances
//===----------------------------------------------------------------------===//

extension CompactedSequence: LazySequenceProtocol
where Base: LazySequenceProtocol {}

extension CompactedCollection: LazySequenceProtocol, LazyCollectionProtocol
where Base: LazySequenceProtocol {}
