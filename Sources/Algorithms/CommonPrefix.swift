//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift Algorithms open source project
//
// Copyright (c) 2021 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

public struct CommonPrefix<Base: Sequence, Other: Sequence> {
  @usableFromInline
  internal let base: Base
  
  @usableFromInline
  internal let other: Other
  
  @usableFromInline
  internal let areEquivalent: (Base.Element, Other.Element) -> Bool
  
  @inlinable
  internal init(
    base: Base,
    other: Other,
    areEquivalent: @escaping (Base.Element, Other.Element) -> Bool
  ) {
    self.base = base
    self.other = other
    self.areEquivalent = areEquivalent
  }
}

extension CommonPrefix: Sequence {
  public struct Iterator: IteratorProtocol {
    @usableFromInline
    internal var base: Base.Iterator
    
    @usableFromInline
    internal var other: Other.Iterator
    
    @usableFromInline
    internal let areEquivalent: (Base.Element, Other.Element) -> Bool
    
    @inlinable
    internal init(
      base: Base.Iterator,
      other: Other.Iterator,
      areEquivalent: @escaping (Base.Element, Other.Element) -> Bool
    ) {
      self.base = base
      self.other = other
      self.areEquivalent = areEquivalent
    }
    
    public mutating func next() -> Base.Element? {
      if let next = base.next(),
         let otherNext = other.next(),
         areEquivalent(next, otherNext) {
        return next
      } else {
        return nil
      }
    }
  }
  
  @inlinable
  public func makeIterator() -> Iterator {
    Iterator(
      base: base.makeIterator(),
      other: other.makeIterator(),
      areEquivalent: areEquivalent)
  }
}

extension CommonPrefix: Collection where Base: Collection, Other: Collection {
  public struct Index {
    @usableFromInline
    internal let base: Base.Index
    
    @usableFromInline
    internal let other: Other.Index

    @inlinable
    internal init(base: Base.Index, other: Other.Index) {
      self.base = base
      self.other = other
    }
  }
  
  @inlinable
  internal func normalizeIndex(base: Base.Index, other: Other.Index) -> Index {
    if base != self.base.endIndex
        && other != self.other.endIndex
        && areEquivalent(self.base[base], self.other[other])
    {
      return Index(base: base, other: other)
    } else {
      return endIndex
    }
  }
  
  @inlinable
  public var startIndex: Index {
    normalizeIndex(base: base.startIndex, other: other.startIndex)
  }
  
  @inlinable
  public var endIndex: Index {
    Index(base: base.endIndex, other: other.endIndex)
  }
  
  @inlinable
  public func index(after index: Index) -> Index {
    normalizeIndex(
      base: base.index(after: index.base),
      other: other.index(after: index.other))
  }
  
  @inlinable
  public subscript(index: Index) -> Base.Element {
    base[index.base]
  }
}

extension CommonPrefix.Index: Comparable {
  @inlinable
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.base == rhs.base
  }
  
  @inlinable
  public static func < (lhs: Self, rhs: Self) -> Bool {
    lhs.base < rhs.base
  }
}

extension CommonPrefix.Index: Hashable where Base.Index: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(base)
  }
}

extension CommonPrefix: LazySequenceProtocol where Base: LazySequenceProtocol {}
extension CommonPrefix: LazyCollectionProtocol
  where Base: LazyCollectionProtocol, Other: Collection {}

//===----------------------------------------------------------------------===//
// Sequence.commonPrefix(with:)
//===----------------------------------------------------------------------===//

extension Sequence {
  @inlinable
  public func commonPrefix<Other: Sequence>(
    with other: Other,
    by areEquivalent: (Element, Other.Element) throws -> Bool
  ) rethrows -> [Element] {
    var iterator = makeIterator()
    var otherIterator = other.makeIterator()
    var result: [Element] = []
    
    while let next = iterator.next(),
          let otherNext = otherIterator.next(),
          try areEquivalent(next, otherNext)
    {
      result.append(next)
    }
    
    return result
  }
}

extension Sequence where Element: Equatable {
  @inlinable
  public func commonPrefix<Other: Sequence>(
    with other: Other
  ) -> CommonPrefix<Self, Other> where Other.Element == Element {
    CommonPrefix(base: self, other: other, areEquivalent: ==)
  }
}

//===----------------------------------------------------------------------===//
// LazySequenceProtocol.commonPrefix(with:)
//===----------------------------------------------------------------------===//

extension LazySequenceProtocol {
  @inlinable
  public func commonPrefix<Other: Sequence>(
    with other: Other,
    by areEquivalent: @escaping (Element, Other.Element) -> Bool
  ) -> CommonPrefix<Self, Other> {
    CommonPrefix(base: self, other: other, areEquivalent: areEquivalent)
  }
}

//===----------------------------------------------------------------------===//
// Collection.commonPrefix(with:)
//===----------------------------------------------------------------------===//

extension Collection {
  @inlinable
  public func commonPrefix<Other: Sequence>(
    with other: Other,
    by areEquivalent: (Element, Other.Element) throws -> Bool
  ) rethrows -> SubSequence {
    let endIndex = endIndex
    
    var index = startIndex
    var iterator = other.makeIterator()
    
    while index != endIndex,
          let next = iterator.next(),
          try areEquivalent(self[index], next)
    {
      formIndex(after: &index)
    }
    
    return self[..<index]
  }
}

extension Collection where Element: Equatable {
  @inlinable
  public func commonPrefix<Other: Sequence>(
    with other: Other
  ) -> SubSequence where Other.Element == Element {
    commonPrefix(with: other, by: ==)
  }
}

//===----------------------------------------------------------------------===//
// LazyCollectionProtocol.commonPrefix(with:)
//===----------------------------------------------------------------------===//

extension LazyCollectionProtocol {
  @inlinable
  public func commonPrefix<Other: Sequence>(
    with other: Other,
    by areEquivalent: @escaping (Element, Other.Element) -> Bool
  ) -> CommonPrefix<Self, Other> {
    CommonPrefix(base: self, other: other, areEquivalent: areEquivalent)
  }
}

extension LazyCollectionProtocol where Element: Equatable {
  @inlinable
  public func commonPrefix<Other: Sequence>(
    with other: Other
  ) -> CommonPrefix<Self, Other> where Other.Element == Element {
    commonPrefix(with: other, by: ==)
  }
}

//===----------------------------------------------------------------------===//
// BidirectionalCollection.commonSuffix(with:)
//===----------------------------------------------------------------------===//

extension BidirectionalCollection {
  @inlinable
  public func commonSuffix<Other: BidirectionalCollection>(
    with other: Other,
    by areEquivalent: (Element, Other.Element) throws -> Bool
  ) rethrows -> SubSequence {
    let (index, _) = try startsOfCommonSuffix(with: other, by: areEquivalent)
    return self[index...]
  }
}

extension BidirectionalCollection where Element: Equatable {
  @inlinable
  public func commonSuffix<Other: BidirectionalCollection>(
    with other: Other
  ) -> SubSequence where Other.Element == Element {
    commonSuffix(with: other, by: ==)
  }
}

//===----------------------------------------------------------------------===//
// Collection.endsOfCommonPrefix(with:)
//===----------------------------------------------------------------------===//

extension Collection {
  @inlinable
  public func endsOfCommonPrefix<Other: Collection>(
    with other: Other,
    by areEquivalent: (Element, Other.Element) throws -> Bool
  ) rethrows -> (Index, Other.Index) {
    var index = startIndex
    var otherIndex = other.startIndex
    
    while index != endIndex && otherIndex != other.endIndex,
          try areEquivalent(self[index], other[otherIndex])
    {
      formIndex(after: &index)
      other.formIndex(after: &otherIndex)
    }
    
    return (index, otherIndex)
  }
}

extension Collection where Element: Equatable {
  @inlinable
  public func endsOfCommonPrefix<Other: Collection>(
    with other: Other
  ) -> (Index, Other.Index) where Other.Element == Element {
    endsOfCommonPrefix(with: other, by: ==)
  }
}

//===----------------------------------------------------------------------===//
// BidirectionalCollection.startsOfCommonPrefix(with:)
//===----------------------------------------------------------------------===//

extension BidirectionalCollection {
  @inlinable
  public func startsOfCommonSuffix<Other: BidirectionalCollection>(
    with other: Other,
    by areEquivalent: (Element, Other.Element) throws -> Bool
  ) rethrows -> (Index, Other.Index) {
    let startIndex = startIndex
    let otherStartIndex = other.startIndex

    var index = endIndex
    var otherIndex = other.endIndex

    while index != startIndex && otherIndex != otherStartIndex {
      let prev = self.index(before: index)
      let otherPrev = other.index(before: otherIndex)
      
      if try !areEquivalent(self[prev], other[otherPrev]) {
        break
      }
      
      index = prev
      otherIndex = otherPrev
    }

    return (index, otherIndex)
  }
}

extension BidirectionalCollection where Element: Equatable {
  @inlinable
  public func startsOfCommonSuffix<Other: BidirectionalCollection>(
    with other: Other
  ) -> (Index, Other.Index) where Other.Element == Element {
    startsOfCommonSuffix(with: other, by: ==)
  }
}
