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

/// A collection consisting of all the elements contained in a collection of
/// collections.
@usableFromInline
internal struct FlattenCollection<Base: Collection>
  where Base.Element: Collection
{
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
  
  /// Forms an index from a pair of base indices, normalizing
  /// `(i, base2.endIndex)` to `(base1.index(after: i), base2.startIndex)` if
  /// necessary.
  @inlinable
  internal func normalizeIndex(
    outer: Base.Index,
    inner: Base.Element.Index
  ) -> Index {
    if inner == base[outer].endIndex {
      let outer = base[base.index(after: outer)...]
        .endOfPrefix(while: { $0.isEmpty })
      let inner = outer == base.endIndex ? nil : base[outer].startIndex
      return Index(outer: outer, inner: inner)
    } else {
      return Index(outer: outer, inner: inner)
    }
  }
  
  @inlinable
  internal func index(after index: Index) -> Index {
    let element = base[index.outer]
    let nextInner = element.index(after: index.inner!)
    return normalizeIndex(outer: index.outer, inner: nextInner)
  }
  
  @inlinable
  internal subscript(position: Index) -> Base.Element.Element {
    base[position.outer][position.inner!]
  }
  
  @inlinable
  internal func distance(from start: Index, to end: Index) -> Int {
    guard start.outer <= end.outer
      else { return -distance(from: end, to: start) }
    guard let startInner = start.inner
      else { return 0 }
    guard start.outer != end.outer
      else {
        return base[start.outer].distance(from: startInner, to: end.inner!)
      }
    
    let firstPart = base[start.outer][startInner...].count
    let middlePart = base[start.outer..<end.outer].dropFirst()
      .reduce(0, { $0 + $1.count })
    let lastPart = end.inner.map { base[end.outer][..<$0].count } ?? 0
    
    return firstPart + middlePart + lastPart
  }
  
  @inlinable
  internal func index(_ index: Index, offsetBy distance: Int) -> Index {
    guard distance != 0 else { return index }
    
    return distance > 0
      ? offsetForward(index, by: distance)
      : offsetBackward(index, by: -distance)
  }
  
  @inlinable
  internal func index(
    _ index: Index,
    offsetBy distance: Int,
    limitedBy limit: Index
  ) -> Index? {
    guard distance != 0 else { return index }
    
    if distance > 0 {
      return limit >= index
        ? offsetForward(index, by: distance, limitedBy: limit)
        : offsetForward(index, by: distance)
    } else {
      return limit <= index
        ? offsetBackward(index, by: -distance, limitedBy: limit)
        : offsetBackward(index, by: -distance)
    }
  }
  
  @inlinable
  internal func offsetForward(_ i: Index, by distance: Int) -> Index {
    guard let index = offsetForward(i, by: distance, limitedBy: endIndex)
      else { fatalError("Index is out of bounds") }
    return index
  }
  
  @inlinable
  internal func offsetBackward(_ i: Index, by distance: Int) -> Index {
    guard let index = offsetBackward(i, by: distance, limitedBy: startIndex)
      else { fatalError("Index is out of bounds") }
    return index
  }
  
  @inlinable
  internal func offsetForward(
    _ index: Index, by distance: Int, limitedBy limit: Index
  ) -> Index? {
    assert(distance > 0)
    assert(limit >= index)
    
    if index.outer == limit.outer {
      if let indexInner = index.inner, let limitInner = limit.inner {
        return base[index.outer]
          .index(indexInner, offsetBy: distance, limitedBy: limitInner)
          .map { inner in Index(outer: index.outer, inner: inner) }
      } else {
        // `index` and `limit` are both `endIndex`
        return nil
      }
    }
    
    // `index <= limit` and `index.outer != limit.outer`, so `index != endIndex`
    let indexInner = index.inner!
    let element = base[index.outer]
    
    if let inner = element.index(
        indexInner,
        offsetBy: distance,
        limitedBy: element.endIndex
    ) {
      return normalizeIndex(outer: index.outer, inner: inner)
    }
    
    var remainder = distance - element[indexInner...].count
    var outer = base.index(after: index.outer)
    
    while outer != limit.outer {
      let element = base[outer]
      
      if let inner = element.index(
          element.startIndex,
          offsetBy: remainder,
          limitedBy: element.endIndex
      ) {
        return normalizeIndex(outer: outer, inner: inner)
      }
      
      remainder -= element.count
      base.formIndex(after: &outer)
    }
    
    if let limitInner = limit.inner {
      let element = base[outer]
      return element.index(
        element.startIndex,
        offsetBy: remainder,
        limitedBy: limitInner)
        .map { inner in Index(outer: outer, inner: inner) }
    } else {
      return nil
    }
  }
  
  @inlinable
  internal func offsetBackward(
    _ index: Index, by distance: Int, limitedBy limit: Index
  ) -> Index? {
    assert(distance > 0)
    assert(limit <= index)
    
    if index.outer == limit.outer {
      if let indexInner = index.inner, let limitInner = limit.inner {
        return base[index.outer]
          .index(indexInner, offsetBy: -distance, limitedBy: limitInner)
          .map { inner in Index(outer: index.outer, inner: inner) }
      } else {
        // `index` and `limit` are both `endIndex`
        return nil
      }
    }
    
    var remainder = distance
    
    if let indexInner = index.inner {
      let element = base[index.outer]
      
      if let inner = element.index(
          indexInner,
          offsetBy: -remainder,
          limitedBy: element.startIndex
      ) {
        return Index(outer: index.outer, inner: inner)
      }
      
      remainder -= element[..<indexInner].count
    }
    
    var outer = base.index(index.outer, offsetBy: -1)
    
    while outer != limit.outer {
      let element = base[outer]
      
      if let inner = element.index(
          element.endIndex,
          offsetBy: -remainder,
          limitedBy: element.startIndex
      ) {
        return Index(outer: outer, inner: inner)
      }
      
      remainder -= element.count
      base.formIndex(&outer, offsetBy: -1)
    }
    
    let element = base[outer]
    return element.index(
      element.endIndex,
      offsetBy: -remainder,
      limitedBy: limit.inner!
    ).map { inner in Index(outer: outer, inner: inner) }
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

extension FlattenCollection: LazySequenceProtocol, LazyCollectionProtocol
  where Base: LazySequenceProtocol, Base.Element: LazySequenceProtocol {}

//===----------------------------------------------------------------------===//
// joined()
//===----------------------------------------------------------------------===//

extension Collection where Element: Collection {
  /// Returns the concatenation of the elements in this collection of
  /// collections.
  @inlinable
  internal func joined() -> FlattenCollection<Self> {
    FlattenCollection(base: self)
  }
}
