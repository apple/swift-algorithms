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
  public func windows(size: Int) -> Windows<Self> {
    Windows(base: self, size: size)
  }
}

public struct Windows<Base: Collection> {
  
  public struct Index: Comparable {
    internal var lowerBound: Base.Index
    internal var upperBound: Base.Index
    public static func == (lhs: Index, rhs: Index) -> Bool {
      lhs.lowerBound == rhs.lowerBound && lhs.upperBound == rhs.upperBound
    }
    public static func < (lhs: Index, rhs: Index) -> Bool {
      lhs.upperBound < rhs.upperBound
    }
  }
  
  public let base: Base
  public let size: Int
  
  public let startIndex: Index
  public let endIndex: Index
  
  public init(base: Base, size: Int) {
    precondition(size > 0, "Windows size must be greater than zero")
    self.base = base
    self.size = size
    let limit = base.count - size
    if limit > 0, let firstUpperBound = base.index(base.startIndex, offsetBy: size, limitedBy: base.endIndex) {
      startIndex = Index(lowerBound: base.startIndex, upperBound: firstUpperBound)
      endIndex = Index(lowerBound: base.endIndex, upperBound: base.endIndex)
    } else {
      startIndex = Index(lowerBound: base.startIndex, upperBound: base.startIndex)
      endIndex = startIndex
    }
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
    guard let lowerBound = base.index(index.lowerBound, offsetBy: -size, limitedBy: base.startIndex) else { return startIndex }
    return Index(lowerBound: lowerBound, upperBound: index == endIndex ? index.upperBound : base.index(before: index.upperBound))
  }
}

extension Windows: RandomAccessCollection where Base: RandomAccessCollection {}
extension Windows: Equatable where Base: Equatable {}
extension Windows: Hashable where Base: Hashable, Base.Index: Hashable {}
extension Windows.Index: Hashable where Base.Index: Hashable {}
