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

@usableFromInline
internal struct FlattenCollection<Base: Collection> where Base.Element: Collection {
  @usableFromInline
  internal let base: Base
  
  @usableFromInline
  internal let indexOfFirstNonEmptyElement: Base.Index
  
  @inlinable
  internal init(base: Base) {
    self.base = base
    self.indexOfFirstNonEmptyElement = base.endOfPrefix(while: { $0.isEmpty })
  }
}

extension FlattenCollection: Collection {
  @usableFromInline
  internal struct Index: Comparable {
    @usableFromInline
    internal let outer: Base.Index
    
    @usableFromInline
    internal let inner: Base.Element.Index?
    
    @inlinable
    init(outer: Base.Index, inner: Base.Element.Index?) {
      self.outer = outer
      self.inner = inner
    }
    
    @inlinable
    internal static func < (lhs: Self, rhs: Self) -> Bool {
      guard lhs.outer == rhs.outer else { return lhs.outer < rhs.outer }
      return lhs.inner == nil ? false : lhs.inner! < rhs.inner!
    }
  }
  
  @inlinable
  internal var startIndex: Index {
    let outer = indexOfFirstNonEmptyElement
    let inner = outer == base.endIndex ? nil : base[outer].startIndex
    return Index(outer: outer, inner: inner)
  }
  
  @inlinable
  internal var endIndex: Index {
    Index(outer: base.endIndex, inner: nil)
  }
  
  @inlinable
  internal func index(after index: Index) -> Index {
    let element = base[index.outer]
    let nextInner = element.index(after: index.inner!)
    
    if nextInner == element.endIndex {
      let nextOuter = base[base.index(after: index.outer)...]
        .endOfPrefix(while: { $0.isEmpty })
      let nextInner = nextOuter == base.endIndex
        ? nil
        : base[nextOuter].startIndex
      return Index(outer: nextOuter, inner: nextInner)
    } else {
      return Index(outer: index.outer, inner: nextInner)
    }
  }
  
  @inlinable
  internal subscript(position: Index) -> Base.Element.Element {
    base[position.outer][position.inner!]
  }
  
  @inlinable
  internal func index(_ index: Index, offsetBy distance: Int) -> Index {
    // TODO
    fatalError()
  }
  
  @inlinable
  internal func index(
    _ index: Index,
    offsetBy distance: Int,
    limitedBy limit: Index
  ) -> Index? {
    // TODO
    fatalError()
  }
  
  @inlinable
  internal func distance(from start: Index, to end: Index) -> Int {
    guard start.outer <= end.outer
      else { return -distance(from: end, to: start) }
    guard let startInner = start.inner
      else { return 0 }
    guard start.outer != end.outer
      else { return base[start.outer].distance(from: startInner, to: end.inner!) }
    
    let firstPart = base[start.outer][startInner...].count
    let middlePart = base[start.outer..<end.outer].dropFirst().reduce(0, { $0 + $1.count })
    let lastPart = end.inner.map { base[end.outer][..<$0].count } ?? 0
    
    return firstPart + middlePart + lastPart
  }
}

extension FlattenCollection: BidirectionalCollection
  where Base: BidirectionalCollection, Base.Element: BidirectionalCollection
{
  @inlinable
  internal func index(before index: Index) -> Index {
    if let inner = index.inner {
      let element = base[index.outer]
      
      if inner != element.startIndex {
        let previousInner = element.index(before: inner)
        return Index(outer: index.outer, inner: previousInner)
      }
    }
    
    let previousOuter = base[..<index.outer].lastIndex(where: { !$0.isEmpty })!
    let element = base[previousOuter]
    let previousInner = element.index(before: element.endIndex)
    return Index(outer: previousOuter, inner: previousInner)
  }
}

extension Collection where Element: Collection {
  @inlinable
  internal func joined() -> FlattenCollection<Self> {
    FlattenCollection(base: self)
  }
}
