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
public struct Chain<Base1: Sequence, Base2: Sequence>
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

extension Chain: Sequence {
  /// The iterator for a `Chain` sequence.
  public struct Iterator: IteratorProtocol {
    internal var iterator1: Base1.Iterator
    internal var iterator2: Base2.Iterator
    
    internal init(_ concatenation: Chain) {
      iterator1 = concatenation.base1.makeIterator()
      iterator2 = concatenation.base2.makeIterator()
    }
    
    public mutating func next() -> Base1.Element? {
      return iterator1.next() ?? iterator2.next()
    }
  }
  
  public func makeIterator() -> Iterator {
    Iterator(self)
  }
}

extension Chain: Collection where Base1: Collection, Base2: Collection {
  /// A position in a `Chain` collection.
  public struct Index: Comparable {
    // The internal index representation, which can either be an index of the
    // first collection or the second. The `endIndex` of the first collection
    // is not to be used as a value - iterating over indices should go straight
    // from the penultimate index of the first collection to the start of the
    // second.
    internal enum Representation : Equatable {
      case first(Base1.Index)
      case second(Base2.Index)
    }

    internal let position: Representation

    /// Creates a new index into the first underlying collection.
    internal init(first i: Base1.Index) {
      position = .first(i)
    }

    /// Creates a new index into the second underlying collection.
    internal init(second i: Base2.Index) {
      position = .second(i)
    }

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

  public var startIndex: Index {
    // If `base1` is empty, then `base2.startIndex` is either a valid position
    // of the first element in `base2` or equal to `base2.endIndex`.
    return base1.isEmpty
      ? Index(second: base2.startIndex)
      : Index(first: base1.startIndex)
  }

  public var endIndex: Index {
    return Index(second: base2.endIndex)
  }

  public subscript(i: Index) -> Base1.Element {
    switch i.position {
    case let .first(i):
      return base1[i]
    case let .second(i):
      return base2[i]
    }
  }

  public func index(after i: Index) -> Index {
    switch i.position {
    case let .first(i):
      assert(i != base1.endIndex)
      let next = base1.index(after: i)
      return next == base1.endIndex
        ? Index(second: base2.startIndex)
        : Index(first: next)
    case let .second(i):
      return Index(second: base2.index(after: i))
    }
  }
  
  public func index(_ i: Index, offsetBy n: Int) -> Index {
    if n == 0 { return i }
    return n > 0
      ? offsetForward(i, by: n, limitedBy: endIndex)!
      : offsetBackward(i, by: -n, limitedBy: startIndex)!
  }

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

  private func offsetForward(
    _ i: Index, by n: Int, limitedBy limit: Index
  ) -> Index? {
    switch (i.position, limit.position) {
    case let (.first(i), .first(limit)):
      let d = base1.distance(from: i, to: base1.endIndex)
      if n < d {
        return base1.index(i, offsetBy: n, limitedBy: limit)
          .map(Index.init(first:))
      } else {
        // The limit only has an effect here if it's "above" `i`
        if limit >= i {
          return Index(first: limit)
        } else {
          return Index(
            second: base2.index(base2.startIndex, offsetBy: n - d))
        }
      }
    
    case let (.first(i), .second(limit)):
      let d = base1.distance(from: i, to: base1.endIndex)
      if n < d {
        return Index(first: base1.index(i, offsetBy: n))
      } else {
        return base2.index(
          base2.startIndex, offsetBy: n - d, limitedBy: limit)
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

  private func offsetBackward(
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
      let d = base2.distance(from: base2.startIndex, to: i)
      if n <= d {
        return Index(second: base2.index(i, offsetBy: -n))
      } else {
        return base1.index(base1.endIndex, offsetBy: -n - d, limitedBy: limit)
          .map(Index.init(first:))
      }

    case let (.second(i), .second(limit)):
      let d = base2.distance(from: base2.startIndex, to: i)
      if n <= d {
        return base2.index(i, offsetBy: -n, limitedBy: limit)
          .map(Index.init(second:))
      } else {
        return Index(
          first: base1.index(base1.endIndex, offsetBy: -n - d))
      }
    }
  }
  
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

extension Chain: BidirectionalCollection
  where Base1: BidirectionalCollection, Base2: BidirectionalCollection
{
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

extension Chain: RandomAccessCollection
  where Base1: RandomAccessCollection, Base2: RandomAccessCollection {}

extension Chain: Equatable where Base1: Equatable, Base2: Equatable {}
extension Chain: Hashable where Base1: Hashable, Base2: Hashable {}

//===----------------------------------------------------------------------===//
// chained(with:)
//===----------------------------------------------------------------------===//

extension Sequence {
  /// Returns a new sequence that iterates over this sequence, followed by the
  /// given sequence.
  ///
  /// You can pass a sequence or collection of any type that has the same
  /// element type as this sequence. This example chains a closed range of `Int`
  /// with an array of `Int`:
  ///
  ///     let small = 1...3
  ///     let big = [100, 200, 300]
  ///     for num in small.chained(with: big) {
  ///         print(num)
  ///     }
  ///     // 1
  ///     // 2
  ///     // 3
  ///     // 100
  ///     // 200
  ///     // 300
  ///
  /// - Parameter other: The sequence to iterate over after this sequence.
  /// - Returns: A sequences that follows iteration of this sequence with
  ///   `other`.
  ///
  /// - Complexity: O(1)
  public func chained<S: Sequence>(with other: S) -> Chain<Self, S>
    where Element == S.Element
  {
    Chain(base1: self, base2: other)
  }
}
