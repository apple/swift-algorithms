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

public struct LazyChunked<Base: Collection> {
  /// The collection that this instance provides a view onto.
  public let base: Base
  
  /// The projection function.
  @usableFromInline
  internal var belongInSameGroup: (Base.Element, Base.Element) -> Bool
  
  @usableFromInline
  internal init(base: Base, belongInSameGroup: @escaping (Base.Element, Base.Element) -> Bool) {
    self.base = base
    self.belongInSameGroup = belongInSameGroup
  }
}

extension LazyChunked: LazyCollectionProtocol {
  /// A position in a chunked collection.
  public struct Index: Comparable {
    /// The lower bound of the chunk at this position.
    @usableFromInline
    internal var lowerBound: Base.Index
    
    /// The upper bound of the chunk at this position.
    ///
    /// `upperBound` is optional so that computing `startIndex` can be an O(1)
    /// operation. When `upperBound` is `nil`, the actual upper bound is found
    /// when subscripting or calling `index(after:)`.
    @usableFromInline
    internal var upperBound: Base.Index?
    
    @usableFromInline
    internal init(lowerBound: Base.Index, upperBound: Base.Index? = nil) {
      self.lowerBound = lowerBound
      self.upperBound = upperBound
    }
    
    @inlinable
    public static func == (lhs: Index, rhs: Index) -> Bool {
      // Only use the lower bound to test for equality, since sometimes the
      // `startIndex` will have an upper bound of `nil` and sometimes it won't,
      // such as when retrieved by:
      // `c.index(before: c.index(after: c.startIndex))`.
      //
      // Since each index represents the range of a disparate chunk, no two
      // unique indices will have the same lower bound.
      lhs.lowerBound == rhs.lowerBound
    }
    
    @inlinable
    public static func < (lhs: Index, rhs: Index) -> Bool {
      // Only use the lower bound to test for ordering, as above.
      lhs.lowerBound < rhs.lowerBound
    }
  }

  /// Returns the index in the base collection for the first element that
  /// doesn't match the current chunk.
  @usableFromInline
  internal func endOfChunk(from i: Base.Index) -> Base.Index {
    guard i != base.endIndex else { return base.endIndex }
    return base[base.index(after: i)...]
      .firstIndex(where: { !belongInSameGroup($0, base[i]) }) ?? base.endIndex
  }
  
  @inlinable
  public var startIndex: Index {
    Index(lowerBound: base.startIndex)
  }
  
  @inlinable
  public var endIndex: Index {
    Index(lowerBound: base.endIndex, upperBound: base.endIndex)
  }
  
  @inlinable
  public func index(after i: Index) -> Index {
    let upperBound = i.upperBound ?? endOfChunk(from: i.lowerBound)
    let end = endOfChunk(from: upperBound)
    return Index(lowerBound: upperBound, upperBound: end)
  }
  
  @inlinable
  public subscript(position: Index) -> Base.SubSequence {
    let upperBound = position.upperBound
      ?? endOfChunk(from: position.lowerBound)
    return base[position.lowerBound..<upperBound]
  }
}

extension LazyChunked.Index: Hashable where Base.Index: Hashable {}

extension LazyChunked: BidirectionalCollection
  where Base: BidirectionalCollection
{
  /// Returns the index in the base collection for the element that starts
  /// the chunk ending at the given index.
  @usableFromInline
  internal func startOfChunk(endingAt end: Base.Index) -> Base.Index {
    // Get the projected value of the last element in the range ending at `end`.
    let lastOfPreviousChunk = base[base.index(before: end)]
    
    // Search backward from `end` for the first element whose projection isn't
    // equal to `lastOfPreviousChunk`.
    if let firstMismatch = base[..<end]
      .lastIndex(where: { !belongInSameGroup($0, lastOfPreviousChunk) })
    {
      // If we found one, that's the last element of the _next_ previous chunk,
      // and therefore one position _before_ the start of this chunk.
      return base.index(after: firstMismatch)
    } else {
      // If we didn't find such an element, this chunk extends back to the start
      // of the collection.
      return base.startIndex
    }
  }

  @inlinable
  public func index(before i: Index) -> Index {
    let start = startOfChunk(endingAt: i.lowerBound)
    return Index(lowerBound: start, upperBound: i.lowerBound)
  }
}

//===----------------------------------------------------------------------===//
// lazy.chunked(by:)
//===----------------------------------------------------------------------===//

extension LazyCollectionProtocol {
  /// Returns a lazy collection of subsequences of this collection, chunked by
  /// the given predicate.
  ///
  /// - Complexity: O(1). When iterating over the resulting collection,
  ///   accessing each successive chunk has a complexity of O(*m*), where *m*
  ///   is the length of the chunk.
  @inlinable
  public func chunked(
    by belongInSameGroup: @escaping (Element, Element) -> Bool
  ) -> LazyChunked<Elements> {
    LazyChunked(base: elements, belongInSameGroup: belongInSameGroup)
  }
  
  /// Returns a lazy collection of subsequences of this collection, chunked by
  /// grouping elements that project to the same value.
  ///
  /// - Complexity: O(1). When iterating over the resulting collection,
  ///   accessing each successive chunk has a complexity of O(*m*), where *m*
  ///   is the length of the chunk.
  @inlinable
  public func chunked<Subject: Equatable>(
    on projection: @escaping (Element) -> Subject
  ) -> LazyChunked<Elements> {
    LazyChunked(
      base: elements,
      belongInSameGroup: { projection($0) == projection($1) })
  }
}

//===----------------------------------------------------------------------===//
// chunked(by:)
//===----------------------------------------------------------------------===//

extension Collection {
  /// Returns a collection of subsequences of this collection, chunked by
  /// the given predicate.
  ///
  /// - Complexity: O(*n*), where *n* is the length of this collection.
  @inlinable
  public func chunked(
    by belongInSameGroup: (Element, Element) -> Bool
  ) -> [SubSequence] {
    guard !isEmpty else { return [] }
    var result: [SubSequence] = []
    
    var start = startIndex
    var current = startIndex
    while true {
      let next = index(after: current)
      if next == endIndex { break }
      
      if !belongInSameGroup(self[current], self[next]) {
        result.append(self[start..<next])
        start = next
      }
      current = next
    }
    
    if start != endIndex {
      result.append(self[start..<endIndex])
    }
    
    return result
  }

  /// Returns a collection of subsequences of this collection, chunked by
  /// grouping elements that project to the same value.
  ///
  /// - Complexity: O(*n*), where *n* is the length of this collection.
  @inlinable
  public func chunked<Subject: Equatable>(
    on projection: (Element) -> Subject
  ) -> [SubSequence] {
    chunked(by: { projection($0) == projection($1) })
  }
}

