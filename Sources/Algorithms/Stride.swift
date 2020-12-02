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
  /// Returns a sequence stepping through the elements every `step` starting
  /// at the first value. Any remainders of the stride will be trimmed.
  ///
  ///     (0...10).striding(by: 2) // == [0, 2, 4, 6, 8, 10]
  ///     (0...10).striding(by: 3) // == [0, 3, 6, 9]
  ///
  /// - Complexity: O(1). Access to successive values is O(1) if the
  /// collection conforms to `RandomAccessCollection`; otherwise,
  /// O(_k_), where _k_ is the striding `step`.
  ///
  /// - Parameter step: The amount to step with each iteration.
  /// - Returns: Returns a sequence or collection for stepping through the
  /// elements by the specified amount.
  public func striding(by step: Int) -> Stride<Self> {
    Stride(base: self, stride: step)
  }
}

/// A wrapper that strides over a base sequence or collection.
public struct Stride<Base: Sequence> {
  internal let base: Base
  internal let stride: Int
  
  internal init(base: Base, stride: Int) {
    precondition(stride > 0, "striding must be greater than zero")
    self.base = base
    self.stride = stride
  }
}

extension Stride {
  public func striding(by step: Int) -> Self {
    Stride(base: base, stride: stride * step)
  }
}

extension Stride: Sequence {
  /// An iterator over a `Stride` sequence.
  public struct Iterator: IteratorProtocol {
    internal var iterator: Base.Iterator
    internal let stride: Int
    internal var striding: Bool = false
    
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
  
  public func makeIterator() -> Stride<Base>.Iterator {
    Iterator(iterator: base.makeIterator(), stride: stride)
  }
}

extension Stride: Collection where Base: Collection {
  /// A position in a `Stride` collection.
  public struct Index: Comparable {
    internal let base: Base.Index
    
    internal init(_ base: Base.Index) {
      self.base = base
    }
    
    public static func < (lhs: Index, rhs: Index) -> Bool {
      lhs.base < rhs.base
    }
  }
  
  public var startIndex: Index {
    Index(base.startIndex)
  }
  
  public var endIndex: Index {
    Index(base.endIndex)
  }
  
  public subscript(i: Index) -> Base.Element {
    base[i.base]
  }
  
  public func index(after i: Index) -> Index {
    precondition(i.base < base.endIndex, "Advancing past end index")
    return index(i, offsetBy: 1)
  }
  
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
  
  private func offsetForward(
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
  
  private func offsetBackward(
    _ i: Index,
    offsetBy n: Int,
    limitedBy limit: Index
  ) -> Index? {
    let distance = i == endIndex
      ? -((base.count - 1) % stride + 1) + (n - 1) * -stride
      : n * -stride
    return base.index(
        i.base,
        offsetBy: distance,
        limitedBy: limit.base
    ).map(Index.init)
  }
  
  public var count: Int {
    base.isEmpty ? 0 : (base.count - 1) / stride + 1
  }
  
  public func distance(from start: Index, to end: Index) -> Int {
    let distance = base.distance(from: start.base, to: end.base)
    return distance / stride + (distance % stride).signum()
  }
  
  public func index(_ i: Index, offsetBy distance: Int) -> Index {
    precondition(distance <= 0 || i.base < base.endIndex, "Advancing past end index")
    precondition(distance >= 0 || i.base > base.startIndex, "Incrementing past start index")
    let limit = distance > 0 ? endIndex : startIndex
    let idx = index(i, offsetBy: distance, limitedBy: limit)
    precondition(idx != nil, "The distance \(distance) is not valid for this collection")
    return idx!
  }
}

extension Stride: BidirectionalCollection
  where Base: RandomAccessCollection {

  public func index(before i: Index) -> Index {
    precondition(i.base > base.startIndex, "Incrementing past start index")
    return index(i, offsetBy: -1)
  }
}

extension Stride: RandomAccessCollection where Base: RandomAccessCollection {}

extension Stride: Equatable where Base.Element: Equatable {
  public static func == (lhs: Stride, rhs: Stride) -> Bool {
    lhs.elementsEqual(rhs, by: ==)
  }
}

extension Stride: Hashable where Base.Element: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(stride)
    for element in self {
      hasher.combine(element)
    }
  }
}

extension Stride.Index: Hashable where Base.Index: Hashable {}
