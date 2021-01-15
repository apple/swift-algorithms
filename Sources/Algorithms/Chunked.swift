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

/// A collection wrapper that breaks a collection into chunks based on a
/// predicate or projection.
public struct LazyChunked<Base: Collection, Subject> {
  /// The collection that this instance provides a view onto.
  public let base: Base
  
  /// The projection function.
  @usableFromInline
  internal let projection: (Base.Element) -> Subject
  
  /// The predicate.
  @usableFromInline
  internal let belongInSameGroup: (Subject, Subject) -> Bool
  
  @usableFromInline
  internal init(
    base: Base,
    projection: @escaping (Base.Element) -> Subject,
    belongInSameGroup: @escaping (Subject, Subject) -> Bool
  ) {
    self.base = base
    self.projection = projection
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

  /// Returns the index in the base collection of the end of the chunk starting
  /// at the given index.
  @usableFromInline
  internal func endOfChunk(startingAt start: Base.Index) -> Base.Index {
    let subject = projection(base[start])
    return base[base.index(after: start)...]
      .firstIndex(where: { !belongInSameGroup(subject, projection($0)) })
      ?? base.endIndex
  }
  
  @inlinable
  public var startIndex: Index {
    Index(lowerBound: base.startIndex)
  }
  
  @inlinable
  public var endIndex: Index {
    Index(lowerBound: base.endIndex)
  }
  
  @inlinable
  public func index(after i: Index) -> Index {
    precondition(i != endIndex, "Can't advance past endIndex")
    let upperBound = i.upperBound ?? endOfChunk(startingAt: i.lowerBound)
    guard upperBound != base.endIndex else { return endIndex }
    let end = endOfChunk(startingAt: upperBound)
    return Index(lowerBound: upperBound, upperBound: end)
  }
  
  @inlinable
  public subscript(position: Index) -> Base.SubSequence {
    let upperBound = position.upperBound
      ?? endOfChunk(startingAt: position.lowerBound)
    return base[position.lowerBound..<upperBound]
  }
}

extension LazyChunked.Index: Hashable where Base.Index: Hashable {}

extension LazyChunked: BidirectionalCollection
  where Base: BidirectionalCollection
{
  /// Returns the index in the base collection of the start of the chunk ending
  /// at the given index.
  @usableFromInline
  internal func startOfChunk(endingAt end: Base.Index) -> Base.Index {
    let indexBeforeEnd = base.index(before: end)
    
    // Get the projected value of the last element in the range ending at `end`.
    let subject = projection(base[indexBeforeEnd])
    
    // Search backward from `end` for the first element whose projection isn't
    // equal to `subject`.
    if let firstMismatch = base[..<indexBeforeEnd]
      .lastIndex(where: { !belongInSameGroup(projection($0), subject) })
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
    precondition(i != startIndex, "Can't advance before startIndex")
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
  ) -> LazyChunked<Elements, Element> {
    LazyChunked(
      base: elements,
      projection: { $0 },
      belongInSameGroup: belongInSameGroup)
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
  ) -> LazyChunked<Elements, Subject> {
    LazyChunked(
      base: elements,
      projection: projection,
      belongInSameGroup: ==)
  }
}

//===----------------------------------------------------------------------===//
// chunked(by:)
//===----------------------------------------------------------------------===//

extension Collection {
  /// Returns a collection of subsequences of this collection, chunked by
  /// grouping elements that project to the same value according to the given
  /// predicate.
  ///
  /// - Complexity: O(*n*), where *n* is the length of this collection.
  @usableFromInline
  internal func chunked<Subject>(
    on projection: (Element) throws -> Subject,
    by belongInSameGroup: (Subject, Subject) throws -> Bool
  ) rethrows -> [SubSequence] {
    guard !isEmpty else { return [] }
    var result: [SubSequence] = []
    
    var start = startIndex
    var subject = try projection(self[start])
    
    for (index, element) in indexed().dropFirst() {
      let nextSubject = try projection(element)
      if try !belongInSameGroup(subject, nextSubject) {
        result.append(self[start..<index])
        start = index
        subject = nextSubject
      }
    }
    
    if start != endIndex {
      result.append(self[start..<endIndex])
    }
    
    return result
  }
  
  /// Returns a collection of subsequences of this collection, chunked by
  /// the given predicate.
  ///
  /// - Complexity: O(*n*), where *n* is the length of this collection.
  @inlinable
  public func chunked(
    by belongInSameGroup: (Element, Element) throws -> Bool
  ) rethrows -> [SubSequence] {
    try chunked(on: { $0 }, by: belongInSameGroup)
  }

  /// Returns a collection of subsequences of this collection, chunked by
  /// grouping elements that project to the same value.
  ///
  /// - Complexity: O(*n*), where *n* is the length of this collection.
  @inlinable
  public func chunked<Subject: Equatable>(
    on projection: (Element) throws -> Subject
  ) rethrows -> [SubSequence] {
    try chunked(on: projection, by: ==)
  }
}

//===----------------------------------------------------------------------===//
// chunks(ofCount:)
//===----------------------------------------------------------------------===//

/// A collection that presents the elements of its base collection
/// in `SubSequence` chunks of any given count.
///
/// A `ChunkedByCount` is a lazy view on the base Collection, but it does not implicitly confer
/// laziness on algorithms applied to its result.  In other words, for ordinary collections `c`:
///
/// * `c.chunks(ofCount: 3)` does not create new storage
/// * `c.chunks(ofCount: 3).map(f)` maps eagerly and returns a new array
/// * `c.lazy.chunks(ofCount: 3).map(f)` maps lazily and returns a `LazyMapCollection`
public struct ChunkedByCount<Base: Collection> {
  
  public typealias Element = Base.SubSequence
  
  @usableFromInline
  internal let base: Base
  
  @usableFromInline
  internal let chunkCount: Int
  
  @usableFromInline
  internal var startUpperBound: Base.Index

  ///  Creates a view instance that presents the elements of `base`
  ///  in `SubSequence` chunks of the given count.
  ///
  /// - Complexity: O(n)
  @inlinable
  internal init(_base: Base, _chunkCount: Int) {
    self.base = _base
    self.chunkCount = _chunkCount
    
    // Compute the start index upfront in order to make
    // start index a O(1) lookup.
    self.startUpperBound = _base.index(
      _base.startIndex, offsetBy: _chunkCount,
      limitedBy: _base.endIndex
    ) ?? _base.endIndex
  }
}

extension ChunkedByCount: Collection {
  public struct Index {
    @usableFromInline
    internal let baseRange: Range<Base.Index>
    
    @usableFromInline
    internal init(_baseRange: Range<Base.Index>) {
      self.baseRange = _baseRange
    }
  }

  /// - Complexity: O(1)
  @inlinable
  public var startIndex: Index {
    Index(_baseRange: base.startIndex..<startUpperBound)
  }
  @inlinable
  public var endIndex: Index {
    Index(_baseRange: base.endIndex..<base.endIndex)
  }
  
  /// - Complexity: O(1)
  public subscript(i: Index) -> Element {
    precondition(i < endIndex, "Index out of range")
    return base[i.baseRange]
  }
  
  @inlinable
  public func index(after i: Index) -> Index {
    precondition(i < endIndex, "Advancing past end index")
    let baseIdx = base.index(
      i.baseRange.upperBound, offsetBy: chunkCount,
      limitedBy: base.endIndex
    ) ?? base.endIndex
    return Index(_baseRange: i.baseRange.upperBound..<baseIdx)
  }
}

extension ChunkedByCount.Index: Comparable {
  @inlinable
  public static func == (lhs: ChunkedByCount.Index,
                         rhs: ChunkedByCount.Index) -> Bool {
    lhs.baseRange.lowerBound == rhs.baseRange.lowerBound
  }
  
  @inlinable
  public static func < (lhs: ChunkedByCount.Index,
                        rhs: ChunkedByCount.Index) -> Bool {
    lhs.baseRange.lowerBound < rhs.baseRange.lowerBound
  }
}

extension ChunkedByCount:
  BidirectionalCollection, RandomAccessCollection
where Base: RandomAccessCollection {
  @inlinable
  public func index(before i: Index) -> Index {
    precondition(i > startIndex, "Advancing past start index")
    
    var offset = chunkCount
    if i.baseRange.lowerBound == base.endIndex {
      let remainder = base.count%chunkCount
      if remainder != 0 {
        offset = remainder
      }
    }
    
    let baseIdx = base.index(
      i.baseRange.lowerBound, offsetBy: -offset,
      limitedBy: base.startIndex
    ) ?? base.startIndex
    return Index(_baseRange: baseIdx..<i.baseRange.lowerBound)
  }
}

extension ChunkedByCount {
  @inlinable
  public func distance(from start: Index, to end: Index) -> Int {
    let distance =
      base.distance(from: start.baseRange.lowerBound,
                    to: end.baseRange.lowerBound)
    let (quotient, remainder) =
      distance.quotientAndRemainder(dividingBy: chunkCount)
    return quotient + remainder.signum()
  }

  @inlinable
  public var count: Int {
    let (quotient, remainder) =
      base.count.quotientAndRemainder(dividingBy: chunkCount)
    return quotient + remainder.signum()
  }
  
  @inlinable
  public func index(
    _ i: Index, offsetBy offset: Int, limitedBy limit: Index
  ) -> Index? {
    guard offset != 0 else { return i }
    guard limit != i else { return nil }
    
    if offset > 0 {
      return limit > i
        ? offsetForward(i, offsetBy: offset, limit: limit)
        : offsetForward(i, offsetBy: offset)
    } else {
      return limit < i
        ? offsetBackward(i, offsetBy: offset, limit: limit)
        : offsetBackward(i, offsetBy: offset)
    }
  }

  @inlinable
  public func index(_ i: Index, offsetBy distance: Int) -> Index {
    guard distance != 0 else { return i }
    
    let idx = distance > 0
        ? offsetForward(i, offsetBy: distance)
        : offsetBackward(i, offsetBy: distance)
    guard let index = idx else {
      fatalError("Out of bounds")
    }
    return index
  }
  
  @usableFromInline
  internal func offsetForward(
    _ i: Index, offsetBy distance: Int, limit: Index? = nil
  ) -> Index? {
    assert(distance > 0)

    return makeOffsetIndex(
      from: i, baseBound: base.endIndex,
      distance: distance, baseDistance: distance * chunkCount,
      limit: limit, by: >
    )
  }
  
  // Convenience to compute offset backward base distance.
  @inline(__always)
  private func computeOffsetBackwardBaseDistance(
    _ i: Index, _ distance: Int
  ) -> Int {
    if i == endIndex {
      let remainder = base.count%chunkCount
      // We have to take it into account when calculating offsets.
      if remainder != 0 {
        // Distance "minus" one(at this point distance is negative)
        // because we need to adjust for the last position that have
        // a variadic(remainder) number of elements.
        return ((distance + 1) * chunkCount) - remainder
      }
    }
    return distance * chunkCount
  }
  
  @usableFromInline
  internal func offsetBackward(
    _ i: Index, offsetBy distance: Int, limit: Index? = nil
  ) -> Index? {
    assert(distance < 0)
    let baseDistance =
        computeOffsetBackwardBaseDistance(i, distance)
    return makeOffsetIndex(
      from: i, baseBound: base.startIndex,
      distance: distance, baseDistance: baseDistance,
      limit: limit, by: <
    )
  }
  
  // Helper to compute index(offsetBy:) index.
  @inline(__always)
  private func makeOffsetIndex(
    from i: Index, baseBound: Base.Index, distance: Int, baseDistance: Int,
    limit: Index?, by limitFn: (Base.Index, Base.Index) -> Bool
  ) -> Index? {
    let baseIdx = base.index(
      i.baseRange.lowerBound, offsetBy: baseDistance,
      limitedBy: baseBound
    )
    
    if let limit = limit {
      if baseIdx == nil {
        // If we past the bounds while advancing forward and the
        // limit is the `endIndex`, since the computation on base
        // don't take into account the remainder, we have to make
        // sure that passing the bound was because of the distance
        // not just because of a remainder. Special casing is less
        // expensive than always use count(which could be O(n) for
        // non-random access collection base) to compute the base
        // distance taking remainder into account.
        if baseDistance > 0 && limit == endIndex {
          if self.distance(from: i, to: limit) < distance {
            return nil
          }
        } else {
          return nil
        }
      }

      // Checks for the limit.
      let baseStartIdx = baseIdx ?? baseBound
      if limitFn(baseStartIdx, limit.baseRange.lowerBound) {
        return nil
      }
    }
    
    let baseStartIdx = baseIdx ?? baseBound
    let baseEndIdx = base.index(
      baseStartIdx, offsetBy: chunkCount, limitedBy: base.endIndex
    ) ?? base.endIndex
    
    return Index(_baseRange: baseStartIdx..<baseEndIdx)
  }
}

extension Collection {
  /// Returns a `ChunkedCollection<Self>` view presenting the elements
  /// in chunks with count of the given count parameter.
  ///
  /// - Parameter size: The size of the chunks. If the count parameter
  ///   is evenly divided by the count of the base `Collection` all the
  ///   chunks will have the count equals to size.
  ///   Otherwise, the last chunk will contain the remaining elements.
  ///
  ///     let c = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
  ///     print(c.chunks(ofCount: 5).map(Array.init))
  ///     // [[1, 2, 3, 4, 5], [6, 7, 8, 9, 10]]
  ///
  ///     print(c.chunks(ofCount: 3).map(Array.init))
  ///     // [[1, 2, 3], [4, 5, 6], [7, 8, 9], [10]]
  ///
  /// - Complexity: O(1)
  @inlinable
  public func chunks(ofCount count: Int) -> ChunkedByCount<Self> {
    precondition(count > 0, "Cannot chunk with count <= 0!")
    return ChunkedByCount(_base: self, _chunkCount: count)
  }
}

// Conditional conformances.
extension ChunkedByCount: Equatable where Base: Equatable {}

// Since we have another stored property of type `Index` on the
// collection, synthesis of `Hashble` conformace would require
// a `Base.Index: Hashable` constraint, so we implement the hasher
// only in terms of `base`. Since the computed index is based on it,
// it should not make a difference here.
extension ChunkedByCount: Hashable where Base: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(base)
  }
}
extension ChunkedByCount.Index: Hashable where Base.Index: Hashable {}

// Lazy conditional conformance.
extension ChunkedByCount: LazySequenceProtocol
  where Base: LazySequenceProtocol {}
extension ChunkedByCount: LazyCollectionProtocol
  where Base: LazyCollectionProtocol {}
