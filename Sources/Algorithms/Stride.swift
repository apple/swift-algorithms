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

extension Collection {
  /// Returns a collection stepping through the elements every `step` starting
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
  /// - Returns: Returns a collection stepping through the elements by the
  /// specified amount.
  public func striding(by step: Int) -> Stride<Self> {
    Stride(base: self, stride: step)
  }
}

public struct Stride<Base: Collection> {
  
  public let base: Base
  public let stride: Int
  
  init(base: Base, stride: Int) {
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

extension Stride: Collection {
  
  public struct Index: Comparable {
    
    let base: Base.Index
    
    init(_ base: Base.Index) {
      self.base = base
    }
    
    init?(_ base: Base.Index?) {
      guard let base = base else { return nil }
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
    return index(i, offsetBy: 1, limitedBy: endIndex) ?? endIndex
  }

  public func index(
    _ i: Index,
    offsetBy n: Int,
    limitedBy limit: Index
  ) -> Index? {
    guard n != 0 else { return i }
    guard limit != i else { return nil }
    switch (i, n) {
    case (endIndex, ..<0):
      let baseEnd = base.index(base.endIndex, offsetBy: -((base.count - 1) % stride + 1))
      return Index(base.index(baseEnd, offsetBy: (n - n.signum()) * stride, limitedBy: limit.base))
    case (_, 1...):
      let max = limit < i ? endIndex.base : limit.base
      let idx = base.index(i.base, offsetBy: n * stride, limitedBy: max)
      if let idx = idx {
        return idx > max ? endIndex : Index(idx)
      }
      guard i >= limit || limit == endIndex else {
        return nil
      }
      let isToEnd = distance(from: i, to: endIndex) == n
      return isToEnd ? endIndex : nil
    case _:
      return Index(base.index(i.base, offsetBy: n * stride, limitedBy: limit.base))
    }
  }

  public var count: Int {
    let limit = base.count - 1
    return limit / stride + (limit < 0 ? 0 : 1)
  }
  
  public func distance(from start: Index, to end: Index) -> Int {
    let distance = base.distance(from: start.base, to: end.base)
    return distance / stride + (abs(distance % stride) > 0 ? distance.signum() : 0)
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

extension Stride: RandomAccessCollection
  where Base: RandomAccessCollection {}

extension Stride: Equatable
  where Base.Element: Equatable {
  
  public static func == (lhs: Stride, rhs: Stride) -> Bool {
    lhs.elementsEqual(rhs, by: ==)
  }
  
}

extension Stride: Hashable
  where Base.Element: Hashable {
  
  public func hash(into hasher: inout Hasher) {
    hasher.combine(stride)
    for element in self {
      hasher.combine(element)
    }
  }
  
}

extension Stride.Index: Hashable
  where Base.Index: Hashable {}
