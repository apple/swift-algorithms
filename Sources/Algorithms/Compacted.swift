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
}

extension CompactedCollection: BidirectionalCollection
  where Base: BidirectionalCollection {

  @inlinable
  public func index(before i: Index) -> Index {
    precondition(i != startIndex, "Index out of bounds")
    
    guard let idx =
            base[startIndex.base..<i.base]
                .lastIndex(where: { $0 != nil })
      else { fatalError("Index out of bounds") }
    return Index(base: idx)
  }
}

extension CompactedCollection.Index: Comparable {  
  @inlinable
  public static func < (lhs: CompactedCollection.Index,
                        rhs: CompactedCollection.Index) -> Bool {
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
    where Element == Unwrapped?
  {
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
