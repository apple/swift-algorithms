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
    return base.index(i.base, offsetBy: stride, limitedBy: base.endIndex)
      .map(Index.init) ?? endIndex
  }
  
  public func index(
    _ i: Index,
    offsetBy distance: Int,
    limitedBy limit: Index
  ) -> Index? {
    base.index(i.base, offsetBy: distance * stride, limitedBy: limit.base)
      .map(Index.init)
  }

  public var count: Int {
    let limit = base.count - 1
    return limit / stride + (limit < 0 ? 0 : 1)
  }
  
  public func distance(from start: Index, to end: Index) -> Int {
    let distance = base.distance(from: start.base, to: end.base)
    return distance / stride + (distance % stride > 0 ? 1 : 0)
  }
  
  public func index(_ i: Index, offsetBy distance: Int) -> Index {
    precondition(distance <= 0 || i.base < base.endIndex, "Advancing past end index")
    precondition(distance >= 0 || i.base > base.startIndex, "Incrementing past start index")
    return Index(base.index(i.base, offsetBy: distance * stride))
  }
}

extension Stride: BidirectionalCollection
  where Base: RandomAccessCollection {
  
  public func index(before i: Index) -> Index {
    precondition(i.base > base.startIndex, "Incrementing past start index")
    if i == endIndex {
      let count = base.count
      precondition(count > 0, "Can't move before the starting index")
      return Index(
        base.index(base.endIndex, offsetBy: -((count - 1) % stride + 1))
      )
    } else {
      guard let step = base.index(
        i.base,
        offsetBy: -stride,
        limitedBy: startIndex.base
      ) else {
        fatalError("Incrementing past start index")
      }
      return Index(step)
    }
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
