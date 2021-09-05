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

/// A concatenation of two sequences with the same element type.
public struct Chain2Sequence<Base1: Sequence, Base2: Sequence>
  where Base1.Element == Base2.Element
{
  /// The first sequence in this chain.
  @usableFromInline
  internal let base1: Base1
  
  /// The second sequence in this chain.
  @usableFromInline
  internal let base2: Base2

  @inlinable
  internal init(base1: Base1, base2: Base2) {
    self.base1 = base1
    self.base2 = base2
  }
}

extension Chain2Sequence: Sequence {
  /// The iterator for a `Chain2Sequence` instance.
  public struct Iterator: IteratorProtocol {
    @usableFromInline
    internal var iterator1: Base1.Iterator
    
    @usableFromInline
    internal var iterator2: Base2.Iterator
    
    @inlinable
    internal init(_ concatenation: Chain2Sequence) {
      iterator1 = concatenation.base1.makeIterator()
      iterator2 = concatenation.base2.makeIterator()
    }
    
    @inlinable
    public mutating func next() -> Base1.Element? {
      return iterator1.next() ?? iterator2.next()
    }
  }
  
  @inlinable
  public func makeIterator() -> Iterator {
    Iterator(self)
  }
}

extension Chain2Sequence: Collection where Base1: Collection, Base2: Collection {
  /// A position in a `Chain2Sequence` instance.
  public struct Index: Comparable {
    // The internal index representation, which can either be an index of the
    // first collection or the second. The `endIndex` of the first collection
    // is not to be used as a value - iterating over indices should go straight
    // from the penultimate index of the first collection to the start of the
    // second.
    @usableFromInline
    internal enum Representation: Equatable {
      case first(Base1.Index)
      case second(Base2.Index)
    }

    @usableFromInline
    internal let position: Representation

    /// Creates a new index into the first underlying collection.
    @inlinable
    internal init(first i: Base1.Index) {
      position = .first(i)
    }

    /// Creates a new index into the second underlying collection.
    @inlinable
    internal init(second i: Base2.Index) {
      position = .second(i)
    }

    @inlinable
    public static func < (lhs: Index, rhs: Index) -> Bool {
      switch (lhs.position, rhs.position) {
      case (.first, .second):
        return true
      case (.second, .first):
        return false
      case let (.first(l), .first(r)):
        return l < r
      case let (.second(l), .second(r)):
        return l < r
      }
    }
  }
  
  /// Converts an index of `Base1` to the corresponding `Index` by mapping
  /// `base1.endIndex` to `base2.startIndex`.
  @inlinable
  internal func normalizeIndex(_ i: Base1.Index) -> Index {
    i == base1.endIndex ? Index(second: base2.startIndex) : Index(first: i)
  }

  @inlinable
  public var startIndex: Index {
    // if `base1` is empty, this will return `base2.startIndex` - if `base2` is
    // also empty, this will correctly equal `base2.endIndex`
    normalizeIndex(base1.startIndex)
  }

  @inlinable
  public var endIndex: Index {
    Index(second: base2.endIndex)
  }

  @inlinable
  public subscript(i: Index) -> Base1.Element {
    switch i.position {
    case let .first(i):
      return base1[i]
    case let .second(i):
      return base2[i]
    }
  }

  @inlinable
  public func index(after i: Index) -> Index {
    switch i.position {
    case let .first(i):
      assert(i != base1.endIndex)
      return normalizeIndex(base1.index(after: i))
    case let .second(i):
      return Index(second: base2.index(after: i))
    }
  }
  
  @inlinable
  public func index(_ i: Index, offsetBy distance: Int) -> Index {
    guard distance != 0 else { return i }
    
    return distance > 0
      ? offsetForward(i, by: distance)
      : offsetBackward(i, by: -distance)
  }
  
  @inlinable
  public func index(
    _ i: Index,
    offsetBy distance: Int,
    limitedBy limit: Index
  ) -> Index? {
    if distance >= 0 {
      return limit >= i
        ? offsetForward(i, by: distance, limitedBy: limit)
        : offsetForward(i, by: distance)
    } else {
      return limit <= i
        ? offsetBackward(i, by: -distance, limitedBy: limit)
        : offsetBackward(i, by: -distance)
    }
  }

  @inlinable
  internal func offsetForward(_ i: Index, by distance: Int) -> Index {
    guard let index = offsetForward(i, by: distance, limitedBy: endIndex)
      else { fatalError("Index is out of bounds") }
    return index
  }
  
  @inlinable
  internal func offsetBackward(_ i: Index, by distance: Int) -> Index {
    guard let index = offsetBackward(i, by: distance, limitedBy: startIndex)
      else { fatalError("Index is out of bounds") }
    return index
  }

  @inlinable
  internal func offsetForward(
    _ i: Index, by distance: Int, limitedBy limit: Index
  ) -> Index? {
    assert(distance >= 0)
    assert(limit >= i)
    
    switch (i.position, limit.position) {
    case let (.first(i), .first(limit)):
      return base1.index(i, offsetBy: distance, limitedBy: limit)
        .map(Index.init(first:))
    
    case let (.first(i), .second(limit)):
      if let j = base1.index(i, offsetBy: distance, limitedBy: base1.endIndex) {
        // the offset stays within the bounds of `base1`
        return normalizeIndex(j)
      } else {
        // the offset overflows the bounds of `base1` by `n - d`
        let d = base1.distance(from: i, to: base1.endIndex)
        return base2.index(base2.startIndex, offsetBy: distance - d, limitedBy: limit)
          .map(Index.init(second:))
      }
      
    case (.second, .first):
      // impossible because `limit >= i`
      fatalError()
      
    case let (.second(i), .second(limit)):
      return base2.index(i, offsetBy: distance, limitedBy: limit)
        .map(Index.init(second:))
    }
  }

  @inlinable
  internal func offsetBackward(
    _ i: Index, by distance: Int, limitedBy limit: Index
  ) -> Index? {
    assert(distance >= 0)
    assert(limit <= i)
    
    switch (i.position, limit.position) {
    case let (.first(i), .first(limit)):
      return base1.index(i, offsetBy: -distance, limitedBy: limit)
        .map(Index.init(first:))
      
    case (.first, .second):
      // impossible because `limit <= i`
      fatalError()
      
    case let (.second(i), .first(limit)):
      if let j = base2.index(i, offsetBy: -distance, limitedBy: base2.startIndex) {
        // the offset stays within the bounds of `base2`
        return Index(second: j)
      } else {
        // the offset overflows the bounds of `base2` by `n - d`
        let d = base2.distance(from: base2.startIndex, to: i)
        return base1.index(base1.endIndex, offsetBy: -(distance - d), limitedBy: limit)
          .map(Index.init(first:))
      }

    case let (.second(i), .second(limit)):
      // `limit` is relevant, so `base1` cannot be reached
      return base2.index(i, offsetBy: -distance, limitedBy: limit)
        .map(Index.init(second:))
    }
  }
  
  @inlinable
  public func distance(from start: Index, to end: Index) -> Int {
    switch (start.position, end.position) {
    case let (.first(i), .first(j)):
      return base1.distance(from: i, to: j)
    case let (.second(i), .second(j)):
      return base2.distance(from: i, to: j)
    case let (.first(i), .second(j)):
      return base1.distance(from: i, to: base1.endIndex)
        + base2.distance(from: base2.startIndex, to: j)
    case let (.second(i), .first(j)):
      return base2.distance(from: i, to: base2.startIndex)
        + base1.distance(from: base1.endIndex, to: j)
    }
  }
}

extension Chain2Sequence: BidirectionalCollection
  where Base1: BidirectionalCollection, Base2: BidirectionalCollection
{
  @inlinable
  public func index(before i: Index) -> Index {
    assert(i != startIndex, "Can't advance before startIndex")
    switch i.position {
    case let .first(i):
      return Index(first: base1.index(before: i))
    case let .second(i):
      return i == base2.startIndex
        ? Index(first: base1.index(before: base1.endIndex))
        : Index(second: base2.index(before: i))
    }
  }
}

extension Chain2Sequence: RandomAccessCollection
  where Base1: RandomAccessCollection, Base2: RandomAccessCollection {}

//===----------------------------------------------------------------------===//
// chain(_:_:)
//===----------------------------------------------------------------------===//

/// Returns a new sequence that iterates over the two given sequences, one
/// followed by the other.
///
/// You can pass any two sequences or collections that have the same element
/// type as this sequence. This example chains a closed range of `Int` with an
/// array of `Int`:
///
///     let small = 1...3
///     let big = [100, 200, 300]
///     for num in chain(small, big) {
///         print(num)
///     }
///     // 1
///     // 2
///     // 3
///     // 100
///     // 200
///     // 300
///
/// - Parameters:
///   - s1: The first sequence.
///   - s2: The second sequence.
/// - Returns: A sequence that iterates first over the elements of `s1`, and
///   then over the elements of `s2`.
///
/// - Complexity: O(1)
@inlinable
public func chain<S1, S2>(_ s1: S1, _ s2: S2) -> Chain2Sequence<S1, S2> {
  Chain2Sequence(base1: s1, base2: s2)
}
