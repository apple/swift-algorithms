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
// striding(by:)
//===----------------------------------------------------------------------===//

extension Sequence {
  /// Returns a sequence stepping through the elements every `step` starting at
  /// the first value. Any remainders of the stride will be trimmed.
  ///
  ///     (0...10).striding(by: 2) // == [0, 2, 4, 6, 8, 10]
  ///     (0...10).striding(by: 3) // == [0, 3, 6, 9]
  ///
  /// - Complexity: O(1). Access to successive values is O(k) where _k_ is the
  ///   striding `step`.
  ///
  /// - Parameter step: The amount to step with each iteration.
  /// - Returns: Returns a sequence for stepping through the elements by the
  ///   specified amount.
  @inlinable
  public func striding(by step: Int) -> StridingSequence<Self> {
    StridingSequence(base: self, stride: step)
  }
}

extension Collection {
  /// Returns a sequence stepping through the elements every `step` starting at
  /// the first value. Any remainders of the stride will be trimmed.
  ///
  ///     (0...10).striding(by: 2) // == [0, 2, 4, 6, 8, 10]
  ///     (0...10).striding(by: 3) // == [0, 3, 6, 9]
  ///
  /// - Complexity: O(1). Access to successive values is O(1) if the collection
  ///   conforms to `RandomAccessCollection`; otherwise, O(_k_), where _k_ is
  ///   the striding `step`.
  ///
  /// - Parameter step: The amount to step with each iteration.
  /// - Returns: Returns a collection for stepping through the elements by the
  ///   specified amount.
  @inlinable
  public func striding(by step: Int) -> StridingCollection<Self> {
    StridingCollection(base: self, stride: step)
  }
}

/// A wrapper that strides over a base sequence.
public struct StridingSequence<Base: Sequence> {
  @usableFromInline
  internal let base: Base
  
  @usableFromInline
  internal let stride: Int
  
  @inlinable
  internal init(base: Base, stride: Int) {
    precondition(stride > 0, "Stride must be greater than zero")
    self.base = base
    self.stride = stride
  }
}

extension StridingSequence {
  @inlinable
  public func striding(by step: Int) -> Self {
    Self(base: base, stride: stride * step)
  }
}

extension StridingSequence: Sequence {
  /// An iterator over a `StridingSequence` instance.
  public struct Iterator: IteratorProtocol {
    @usableFromInline
    internal var iterator: Base.Iterator
    
    @usableFromInline
    internal let stride: Int
    
    @usableFromInline
    internal var striding: Bool = false
    
    @inlinable
    internal init(iterator: Base.Iterator, stride: Int) {
      self.iterator = iterator
      self.stride = stride
    }
    
    @inlinable
    public mutating func next() -> Base.Element? {
      guard striding else {
        striding = true
        return iterator.next()
      }
      for _ in 0..<stride - 1 {
        guard iterator.next() != nil else { break }
      }
      return iterator.next()
    }
  }
  
  @inlinable
  public func makeIterator() -> Iterator {
    Iterator(iterator: base.makeIterator(), stride: stride)
  }
}

extension StridingSequence: LazySequenceProtocol
  where Base: LazySequenceProtocol {}

/// A wrapper that strides over a base collection.
public struct StridingCollection<Base: Collection> {
  @usableFromInline
  internal let base: Base
  
  @usableFromInline
  internal let stride: Int
  
  @inlinable
  internal init(base: Base, stride: Int) {
    precondition(stride > 0, "striding must be greater than zero")
    self.base = base
    self.stride = stride
  }
}

extension StridingCollection {
  @inlinable
  public func striding(by step: Int) -> Self {
    Self(base: base, stride: stride * step)
  }
}

extension StridingCollection: Collection {
  /// A position in a `StridingCollection` instance.
  public struct Index: Comparable {
    @usableFromInline
    internal let base: Base.Index
    
    @usableFromInline
    internal init(_ base: Base.Index) {
      self.base = base
    }
    
    @inlinable
    public static func < (lhs: Index, rhs: Index) -> Bool {
      lhs.base < rhs.base
    }
  }
  
  @inlinable
  public var startIndex: Index {
    Index(base.startIndex)
  }
  
  @inlinable
  public var endIndex: Index {
    Index(base.endIndex)
  }
  
  @inlinable
  public subscript(i: Index) -> Base.Element {
    base[i.base]
  }
  
  @inlinable
  public func index(after i: Index) -> Index {
    precondition(i.base != base.endIndex, "Advancing past end index")
    return index(i, offsetBy: 1)
  }
  
  @inlinable
  public func index(
    _ i: Index,
    offsetBy n: Int,
    limitedBy limit: Index
  ) -> Index? {
    guard n != 0 else { return i }
    guard limit != i else { return nil }
    
    return n > 0
      ? offsetForward(i, offsetBy: n, limitedBy: limit)
      : offsetBackward(i, offsetBy: -n, limitedBy: limit)
  }
  
  @inlinable
  internal func offsetForward(
    _ i: Index,
    offsetBy n: Int,
    limitedBy limit: Index
  ) -> Index? {
    if limit < i {
      if let idx = base.index(
        i.base,
        offsetBy: n * stride,
        limitedBy: base.endIndex
      ) {
        return Index(idx)
      } else {
        assert(distance(from: i, to: endIndex) == n, "Advancing past end index")
        return endIndex
      }
    } else if let idx = base.index(
      i.base,
      offsetBy: n * stride,
      limitedBy: limit.base
    ) {
      return Index(idx)
    } else {
      return distance(from: i, to: limit) == n
        ? endIndex
        : nil
    }
  }
  
  @inlinable
  internal func offsetBackward(
    _ i: Index,
    offsetBy n: Int,
    limitedBy limit: Index
  ) -> Index? {
    // We typically use the ternary operator but this significantly increases
    // compile times when using Swift 5.3.2
    // https://github.com/apple/swift-algorithms/issues/146
    let distance: Int
    if i == endIndex {
      distance = -((base.count - 1) % stride + 1) + (n - 1) * -stride
    } else {
      distance = n * -stride
    }
    return base.index(
        i.base,
        offsetBy: distance,
        limitedBy: limit.base
    ).map(Index.init)
  }
  
  @inlinable
  public var count: Int {
    base.isEmpty ? 0 : (base.count - 1) / stride + 1
  }
  
  @inlinable
  public func distance(from start: Index, to end: Index) -> Int {
    let distance = base.distance(from: start.base, to: end.base)
    return distance / stride + (distance % stride).signum()
  }
  
  @inlinable
  public func index(_ i: Index, offsetBy distance: Int) -> Index {
    precondition(distance <= 0 || i.base != base.endIndex, "Advancing past end index")
    precondition(distance >= 0 || i.base != base.startIndex, "Incrementing past start index")
    let limit = distance > 0 ? endIndex : startIndex
    let idx = index(i, offsetBy: distance, limitedBy: limit)
    precondition(idx != nil, "The distance \(distance) is not valid for this collection")
    return idx!
  }
}

extension StridingCollection: BidirectionalCollection
  where Base: RandomAccessCollection {
  
  @inlinable
  public func index(before i: Index) -> Index {
    precondition(i.base != base.startIndex, "Incrementing past start index")
    return index(i, offsetBy: -1)
  }
}

extension StridingCollection: RandomAccessCollection
  where Base: RandomAccessCollection {}

extension StridingCollection: LazySequenceProtocol, LazyCollectionProtocol
  where Base: LazySequenceProtocol {}

extension StridingCollection.Index: Hashable where Base.Index: Hashable {}
