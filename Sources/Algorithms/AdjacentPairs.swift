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

public struct LazyAdjacentPairs<Base: Collection> {
  /// The leading element is the lower indexed element of the pair.
  public typealias AdjacentPair = (leading: Base.Element, trailing: Base.Element)
  
  /// The collection of which to consider each pair of adjacent elements.
  public let base: Base
  
}

extension LazyAdjacentPairs: LazyCollectionProtocol {
  public typealias Index = Base.Index
  
  public var startIndex: Index {
    base.startIndex
  }
  
  public var endIndex: Index {
    base.index(base.endIndex, offsetBy: -1)
  }
  
  public func index(after i: Index) -> Index {
    base.index(after: i)
  }
  
  public subscript(position: Index) -> AdjacentPair {
    (leading: base[position], trailing: base[base.index(after: position)])
  }
  
}

extension LazyAdjacentPairs: BidirectionalCollection where Base: BidirectionalCollection {
  public func index(before i: Index) -> Index {
    base.index(before: i)
  }
  
}

extension LazyAdjacentPairs: RandomAccessCollection where Base: RandomAccessCollection {}
extension LazyAdjacentPairs: Equatable where Base: Equatable {}
extension LazyAdjacentPairs: Hashable where Base: Hashable {}

//===----------------------------------------------------------------------===//
// adjacentPairs
//===----------------------------------------------------------------------===//

extension LazyCollectionProtocol {
  public var adjacentPairs: LazyAdjacentPairs<Self> {
    LazyAdjacentPairs(base: self)
  }
  
}

extension Collection {
  public typealias AdjacentPair = LazyAdjacentPairs<Self>.AdjacentPair
  
  public var adjacentPairs: [AdjacentPair] {
    // not lazy, as this is computed immediately
    LazyAdjacentPairs(base: self)
      .map { $0 }
  }
  
}
