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
// windows(size:)
//===----------------------------------------------------------------------===//

extension Collection {
  /// Returns a collection for all contiguous windows of length size. The windows overlap.
  /// If the slice is shorter than `size`, the collection returns an empty subsequence.
  ///
  /// - Complexity: O(*n*). When iterating over the resulting collection,
  ///   accessing each successive window has a complexity of O(*m*), where *m*
  ///   is the length of the window.
  public func windows(size: Int) -> Windows<Self> {
    Windows(base: self, size: size)
  }
}

public struct Windows<Base: Collection> {
  
  public struct Index: Comparable {
    internal var lowerBound: Base.Index
    internal var upperBound: Base.Index
    public static func == (lhs: Index, rhs: Index) -> Bool {
      lhs.lowerBound == rhs.lowerBound
    }
    public static func < (lhs: Index, rhs: Index) -> Bool {
      lhs.lowerBound < rhs.lowerBound
    }
  }
  
  public let base: Base
  public let size: Int
  
  private var firstUpperBound: Base.Index?
  
  public var startIndex: Index {
    if let upperBound = firstUpperBound {
      return Index(lowerBound: base.startIndex, upperBound: upperBound)
    } else {
      return endIndex
    }
  }
  
  public var endIndex: Index {
    Index(lowerBound: base.endIndex, upperBound: base.endIndex)
  }
  
  public init(base: Base, size: Int) {
    precondition(size > 0, "Windows size must be greater than zero")
    self.base = base
    self.size = size
    self.firstUpperBound = base.index(base.startIndex, offsetBy: size, limitedBy: base.endIndex)
  }
}

extension Windows: Collection {
  public subscript(index: Index) -> Base.SubSequence {
    base[index.lowerBound..<index.upperBound]
  }
  
  public func index(after index: Index) -> Index {
    guard index.upperBound < base.endIndex else { return endIndex }
    return Index(lowerBound: base.index(after: index.lowerBound), upperBound: base.index(after: index.upperBound))
  }
}

extension Windows: BidirectionalCollection where Base: BidirectionalCollection {
  public func index(before index: Index) -> Index {
    if index == endIndex {
      return Index(lowerBound: base.index(index.lowerBound, offsetBy: -size), upperBound: index.upperBound)
    } else {
      return Index(lowerBound: base.index(before: index.lowerBound), upperBound: base.index(before: index.upperBound))
    }
  }
}

extension Windows: RandomAccessCollection where Base: RandomAccessCollection {}
extension Windows: Equatable where Base: Equatable {}
extension Windows: Hashable where Base: Hashable, Base.Index: Hashable {}
extension Windows.Index: Hashable where Base.Index: Hashable {}
