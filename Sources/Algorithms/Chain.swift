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
public struct Chain2<Base1: Sequence, Base2: Sequence>
  where Base1.Element == Base2.Element
{
  /// The first sequence in this chain.
  public let base1: Base1
  
  /// The second sequence in this chain.
  public let base2: Base2

  internal init(base1: Base1, base2: Base2) {
    self.base1 = base1
    self.base2 = base2
  }
}

extension Chain2: Sequence {
  /// The iterator for a `Chain` sequence.
  public struct Iterator: IteratorProtocol {
    @usableFromInline
    internal var iterator1: Base1.Iterator
    
    @usableFromInline
    internal var iterator2: Base2.Iterator
    
    @usableFromInline
    internal init(_ concatenation: Chain2) {
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

extension Chain2: Collection where Base1: Collection, Base2: Collection {
  /// A position in a `Chain` collection.
  public struct Index: Comparable {
    // The internal index representation, which can either be an index of the
    // first collection or the second. The `endIndex` of the first collection
    // is not to be used as a value - iterating over indices should go straight
    // from the penultimate index of the first collection to the start of the
    // second.
    @usableFromInline
    internal enum Representation : Equatable {
      case first(Base1.Index)
      case second(Base2.Index)
    }

    @usableFromInline
    internal let position: Representation

    /// Creates a new index into the first underlying collection.
    @usableFromInline
    internal init(first i: Base1.Index) {
      position = .first(i)
    }

    /// Creates a new index into the second underlying collection.
    @usableFromInline
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
  @usableFromInline
  internal func convertIndex(_ i: Base1.Index) -> Index {
    i == base1.endIndex ? Index(second: base2.startIndex) : Index(first: i)
  }

  @inlinable
  public var startIndex: Index {
    // if `base1` is empty, this will return `base2.startIndex` - if `base2` is
    // also empty, this will correctly equal `base2.endIndex`
    convertIndex(base1.startIndex)
  }

  @inlinable
  public var endIndex: Index {
    return Index(second: base2.endIndex)
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
      return convertIndex(base1.index(after: i))
    case let .second(i):
      return Index(second: base2.index(after: i))
    }
  }
  
  @inlinable
  public func index(_ i: Index, offsetBy n: Int) -> Index {
    if n == 0 { return i }
    return n > 0
      ? offsetForward(i, by: n, limitedBy: endIndex)!
      : offsetBackward(i, by: -n, limitedBy: startIndex)!
  }

  @inlinable
  public func index(
    _ i: Index,
    offsetBy n: Int,
    limitedBy limit: Index
  ) -> Index? {
    if n == 0 { return i }
    return n > 0
      ? offsetForward(i, by: n, limitedBy: limit)
      : offsetBackward(i, by: -n, limitedBy: limit)
  }

  @usableFromInline
  internal func offsetForward(
    _ i: Index, by n: Int, limitedBy limit: Index
  ) -> Index? {
    switch (i.position, limit.position) {
    case let (.first(i), .first(limit)):
      if limit >= i {
        // `limit` is relevant, so `base2` cannot be reached
        return base1.index(i, offsetBy: n, limitedBy: limit)
          .map(Index.init(first:))
      } else if let j = base1.index(i, offsetBy: n, limitedBy: base1.endIndex) {
        // the offset stays within the bounds of `base1`
        return convertIndex(j)
      } else {
        // the offset overflows the bounds of `base1` by `n - d`
        let d = base1.distance(from: i, to: base1.endIndex)
        return Index(second: base2.index(base2.startIndex, offsetBy: n - d))
      }
    
    case let (.first(i), .second(limit)):
      if let j = base1.index(i, offsetBy: n, limitedBy: base1.endIndex) {
        // the offset stays within the bounds of `base1`
        return convertIndex(j)
      } else {
        // the offset overflows the bounds of `base1` by `n - d`
        let d = base1.distance(from: i, to: base1.endIndex)
        return base2.index(base2.startIndex, offsetBy: n - d, limitedBy: limit)
          .map(Index.init(second:))
      }
      
    case let (.second(i), .first):
      // `limit` has no effect here
      return Index(second: base2.index(i, offsetBy: n))
      
    case let (.second(i), .second(limit)):
      return base2.index(i, offsetBy: n, limitedBy: limit)
        .map(Index.init(second:))
    }
  }

  @usableFromInline
  internal func offsetBackward(
    _ i: Index, by n: Int, limitedBy limit: Index
  ) -> Index? {
    switch (i.position, limit.position) {
    case let (.first(i), .first(limit)):
      return base1.index(i, offsetBy: -n, limitedBy: limit)
        .map(Index.init(first:))
      
    case let (.first(i), .second):
      // `limit` has no effect here
      return Index(first: base1.index(i, offsetBy: -n))
      
    case let (.second(i), .first(limit)):
      if let j = base2.index(i, offsetBy: -n, limitedBy: base2.startIndex) {
        // the offset stays within the bounds of `base2`
        return Index(second: j)
      } else {
        // the offset overflows the bounds of `base2` by `n - d`
        let d = base2.distance(from: base2.startIndex, to: i)
        return base1.index(base1.endIndex, offsetBy: -(n - d), limitedBy: limit)
          .map(Index.init(first:))
      }

    case let (.second(i), .second(limit)):
      if limit <= i {
        // `limit` is relevant, so `base1` cannot be reached
        return base2.index(i, offsetBy: -n, limitedBy: limit)
          .map(Index.init(second:))
      } else if let j = base2.index(i, offsetBy: -n, limitedBy: base2.startIndex) {
        // the offset stays within the bounds of `base2`
        return Index(second: j)
      } else {
        // the offset overflows the bounds of `base2` by `n - d`
        let d = base2.distance(from: base2.startIndex, to: i)
        return Index(first: base1.index(base1.endIndex, offsetBy: -(n - d)))
      }
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

extension Chain2: BidirectionalCollection
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

extension Chain2: RandomAccessCollection
  where Base1: RandomAccessCollection, Base2: RandomAccessCollection {}

extension Chain2: Equatable where Base1: Equatable, Base2: Equatable {}
extension Chain2: Hashable where Base1: Hashable, Base2: Hashable {}

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
public func chain<S1, S2>(_ s1: S1, _ s2: S2) -> Chain2<S1, S2> {
  Chain2(base1: s1, base2: s2)
}

// MARK: - Deprecations

@available(*, deprecated, renamed: "Chain2")
public typealias Chain = Chain2

extension Sequence {
  @available(*, deprecated, message: "Use the chain(_:_:) function, instead.")
  public func chained<S: Sequence>(with other: S) -> Chain2<Self, S>
    where Element == S.Element
  {
    Chain2(base1: self, base2: other)
  }
}
