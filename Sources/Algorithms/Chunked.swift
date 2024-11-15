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
/// predicate.
///
/// Call `lazy.chunked(by:)` on a collection to create an instance of this type.
public struct ChunkedByCollection<Base: Collection, Subject> {
  /// The collection that this instance provides a view onto.
  @usableFromInline
  internal let base: Base
  
  /// The projection function.
  @usableFromInline
  internal let projection: (Base.Element) -> Subject
  
  /// The predicate.
  @usableFromInline
  internal let belongInSameGroup: (Subject, Subject) -> Bool
  
  /// The end index of the first chunk.
  @usableFromInline
  internal var endOfFirstChunk: Base.Index
  
  @inlinable
  internal init(
    base: Base,
    projection: @escaping (Base.Element) -> Subject,
    belongInSameGroup: @escaping (Subject, Subject) -> Bool
  ) {
    self.base = base
    self.projection = projection
    self.belongInSameGroup = belongInSameGroup
    self.endOfFirstChunk = base.startIndex
    
    if !base.isEmpty {
      endOfFirstChunk = endOfChunk(startingAt: base.startIndex)
    }
  }
}

extension ChunkedByCollection: Collection {
  /// A position in a chunked collection.
  public struct Index: Comparable {
    /// The range corresponding to the chunk at this position.
    @usableFromInline
    internal var baseRange: Range<Base.Index>
    
    @inlinable
    internal init(_ baseRange: Range<Base.Index>) {
      self.baseRange = baseRange
    }
    
    @inlinable
    public static func == (lhs: Index, rhs: Index) -> Bool {
      // Since each index represents the range of a disparate chunk, no two
      // unique indices will have the same lower bound.
      lhs.baseRange.lowerBound == rhs.baseRange.lowerBound
    }
    
    @inlinable
    public static func < (lhs: Index, rhs: Index) -> Bool {
      // Only use the lower bound to test for ordering, as above.
      lhs.baseRange.lowerBound < rhs.baseRange.lowerBound
    }
  }

  /// Returns the index in the base collection of the end of the chunk starting
  /// at the given index.
  @inlinable
  internal func endOfChunk(startingAt start: Base.Index) -> Base.Index {
    var subject = projection(base[start])
    
    return base[base.index(after: start)...].endOfPrefix(while: { element in
      let nextSubject = projection(element)
      defer { subject = nextSubject }
      return belongInSameGroup(subject, nextSubject)
    })
  }
  
  @inlinable
  public var startIndex: Index {
    Index(base.startIndex..<endOfFirstChunk)
  }
  
  @inlinable
  public var endIndex: Index {
    Index(base.endIndex..<base.endIndex)
  }
  
  @inlinable
  public func index(after i: Index) -> Index {
    precondition(i != endIndex, "Can't advance past endIndex")
    let upperBound = i.baseRange.upperBound
    guard upperBound != base.endIndex else { return endIndex }
    let end = endOfChunk(startingAt: upperBound)
    return Index(upperBound..<end)
  }
  
  @inlinable
  public subscript(position: Index) -> Base.SubSequence {
    precondition(position != endIndex, "Can't subscript using endIndex")
    return base[position.baseRange]
  }
}

extension ChunkedByCollection.Index: Hashable where Base.Index: Hashable {}

extension ChunkedByCollection: BidirectionalCollection
  where Base: BidirectionalCollection
{
  /// Returns the index in the base collection of the start of the chunk ending
  /// at the given index.
  @inlinable
  internal func startOfChunk(endingAt end: Base.Index) -> Base.Index {
    let indexBeforeEnd = base.index(before: end)
    var subject = projection(base[indexBeforeEnd])
    
    return base[..<indexBeforeEnd].startOfSuffix(while: { element in
      let nextSubject = projection(element)
      defer { subject = nextSubject }
      return belongInSameGroup(nextSubject, subject)
    })
  }

  @inlinable
  public func index(before i: Index) -> Index {
    precondition(i != startIndex, "Can't advance before startIndex")
    let start = startOfChunk(endingAt: i.baseRange.lowerBound)
    return Index(start..<i.baseRange.lowerBound)
  }
}

extension ChunkedByCollection: LazyCollectionProtocol {}

/// A collection wrapper that breaks a collection into chunks based on a
/// predicate.
///
/// Call `lazy.chunked(on:)` on a collection to create an instance of this type.
public struct ChunkedOnCollection<Base: Collection, Subject: Equatable> {
  @usableFromInline
  internal var chunked: ChunkedByCollection<Base, Subject>
  
  @inlinable
  internal init(
    base: Base,
    projection: @escaping (Base.Element) -> Subject
  ) {
    self.chunked = ChunkedByCollection(
      base: base,
      projection: projection,
      belongInSameGroup: ==)
  }
}

extension ChunkedOnCollection: Collection {
  public typealias Index = ChunkedByCollection<Base, Subject>.Index
  
  @inlinable
  public var startIndex: Index {
    chunked.startIndex
  }
  
  @inlinable
  public var endIndex: Index {
    chunked.endIndex
  }
  
  @inlinable
  public subscript(position: Index) -> (Subject, Base.SubSequence) {
    let subsequence = chunked[position]
    let subject = chunked.projection(subsequence.first!)
    return (subject, subsequence)
  }
  
  @inlinable
  public func index(after i: Index) -> Index {
    chunked.index(after: i)
  }
}

extension ChunkedOnCollection: BidirectionalCollection
  where Base: BidirectionalCollection
{
  @inlinable
  public func index(before i: Index) -> Index {
    chunked.index(before: i)
  }
}

extension ChunkedOnCollection: LazyCollectionProtocol {}

/// A collection wrapper that evenly breaks a collection into a given number of
/// chunks.
public struct EvenlyChunkedCollection<Base: Collection> {
  /// The base collection.
  @usableFromInline
  internal let base: Base
  
  /// The number of equal chunks the base collection is divided into.
  @usableFromInline
  internal let numberOfChunks: Int
  
  /// The count of the base collection.
  @usableFromInline
  internal let baseCount: Int
  
  /// The upper bound of the first chunk.
  @usableFromInline
  internal var firstUpperBound: Base.Index
  
  @inlinable
  internal init(base: Base, numberOfChunks: Int) {
    self.base = base
    self.numberOfChunks = numberOfChunks
    self.baseCount = base.count
    self.firstUpperBound = base.startIndex
    
    if numberOfChunks > 0 {
      firstUpperBound = endOfChunk(startingAt: base.startIndex, offset: 0)
    }
  }
}

extension EvenlyChunkedCollection {
  /// Returns the number of chunks with size `smallChunkSize + 1` at the start
  /// of this collection.
  @inlinable
  internal var numberOfLargeChunks: Int {
    baseCount % numberOfChunks
  }
  
  /// Returns the size of a chunk at a given offset.
  @inlinable
  internal func sizeOfChunk(offset: Int) -> Int {
    let isLargeChunk = offset < numberOfLargeChunks
    return baseCount / numberOfChunks + (isLargeChunk ? 1 : 0)
  }
  
  /// Returns the index in the base collection of the end of the chunk starting
  /// at the given index.
  @inlinable
  internal func endOfChunk(startingAt start: Base.Index, offset: Int) -> Base.Index {
    base.index(start, offsetBy: sizeOfChunk(offset: offset))
  }
  
  /// Returns the index in the base collection of the start of the chunk ending
  /// at the given index.
  @inlinable
  internal func startOfChunk(endingAt end: Base.Index, offset: Int) -> Base.Index {
    base.index(end, offsetBy: -sizeOfChunk(offset: offset))
  }
  
  /// Returns the index that corresponds to the chunk that starts at the given
  /// base index.
  @inlinable
  internal func indexOfChunk(startingAt start: Base.Index, offset: Int) -> Index {
    guard offset != numberOfChunks else { return endIndex }
    let end = endOfChunk(startingAt: start, offset: offset)
    return Index(start..<end, offset: offset)
  }
  
  /// Returns the index that corresponds to the chunk that ends at the given
  /// base index.
  @inlinable
  internal func indexOfChunk(endingAt end: Base.Index, offset: Int) -> Index {
    let start = startOfChunk(endingAt: end, offset: offset)
    return Index(start..<end, offset: offset)
  }
}

extension EvenlyChunkedCollection: Collection {
  public struct Index: Comparable {
    /// The range corresponding to the chunk at this position.
    @usableFromInline
    internal var baseRange: Range<Base.Index>
    
    /// The offset corresponding to the chunk at this position. The first chunk
    /// has offset `0` and all other chunks have an offset `1` greater than the
    /// previous.
    @usableFromInline
    internal var offset: Int
    
    @inlinable
    internal init(_ baseRange: Range<Base.Index>, offset: Int) {
      self.baseRange = baseRange
      self.offset = offset
    }
    
    @inlinable
    public static func == (lhs: Self, rhs: Self) -> Bool {
      lhs.offset == rhs.offset
    }
    
    @inlinable
    public static func < (lhs: Self, rhs: Self) -> Bool {
      lhs.offset < rhs.offset
    }
  }
  
  public typealias Element = Base.SubSequence

  @inlinable
  public var startIndex: Index {
    Index(base.startIndex..<firstUpperBound, offset: 0)
  }
  
  @inlinable
  public var endIndex: Index {
    Index(base.endIndex..<base.endIndex, offset: numberOfChunks)
  }
  
  @inlinable
  public func index(after i: Index) -> Index {
    precondition(i != endIndex, "Can't advance past endIndex")
    let start = i.baseRange.upperBound
    return indexOfChunk(startingAt: start, offset: i.offset + 1)
  }
  
  @inlinable
  public subscript(position: Index) -> Element {
    precondition(position != endIndex)
    return base[position.baseRange]
  }
  
  @inlinable
  public func index(_ i: Index, offsetBy distance: Int) -> Index {
    /// Returns the base distance between two `EvenChunksCollection` indices
    /// from the end of one to the start of the other, when given their offsets.
    func baseDistance(from offsetA: Int, to offsetB: Int) -> Int {
      let smallChunkSize = baseCount / numberOfChunks
      let numberOfChunks = (offsetB - offsetA) - 1
      
      let largeChunksEnd = Swift.min(self.numberOfLargeChunks, offsetB)
      let largeChunksStart = Swift.min(self.numberOfLargeChunks, offsetA + 1)
      let numberOfLargeChunks = largeChunksEnd - largeChunksStart
      
      return smallChunkSize * numberOfChunks + numberOfLargeChunks
    }
    
    if distance == 0 {
      return i
    } else if distance > 0 {
      let offset = i.offset + distance
      let baseOffset = baseDistance(from: i.offset, to: offset)
      let start = base.index(i.baseRange.upperBound, offsetBy: baseOffset)
      return indexOfChunk(startingAt: start, offset: offset)
    } else {
      let offset = i.offset + distance
      let baseOffset = baseDistance(from: offset, to: i.offset)
      let end = base.index(i.baseRange.lowerBound, offsetBy: -baseOffset)
      return indexOfChunk(endingAt: end, offset: offset)
    }
  }
  
  @inlinable
  public func index(_ i: Index, offsetBy distance: Int, limitedBy limit: Index) -> Index? {
    if distance >= 0 {
      if (0..<distance).contains(self.distance(from: i, to: limit)) {
        return nil
      }
    } else {
      if (0..<(-distance)).contains(self.distance(from: limit, to: i)) {
        return nil
      }
    }
    return index(i, offsetBy: distance)
  }
  
  @inlinable
  public func distance(from start: Index, to end: Index) -> Int {
    end.offset - start.offset
  }
}

extension EvenlyChunkedCollection.Index: Hashable where Base.Index: Hashable {}

extension EvenlyChunkedCollection: BidirectionalCollection
  where Base: BidirectionalCollection
{
  @inlinable
  public func index(before i: Index) -> Index {
    precondition(i != startIndex, "Can't advance before startIndex")
    return indexOfChunk(endingAt: i.baseRange.lowerBound, offset: i.offset - 1)
  }
}

extension EvenlyChunkedCollection: RandomAccessCollection
  where Base: RandomAccessCollection {}

extension EvenlyChunkedCollection: LazySequenceProtocol
  where Base: LazySequenceProtocol {}

extension EvenlyChunkedCollection: LazyCollectionProtocol
  where Base: LazyCollectionProtocol {}

//===----------------------------------------------------------------------===//
// lazy.chunked(by:) / lazy.chunked(on:)
//===----------------------------------------------------------------------===//

extension LazySequenceProtocol where Self: Collection, Elements: Collection {
  /// Returns a lazy collection of subsequences of this collection, chunked by
  /// the given predicate.
  ///
  /// - Parameter belongInSameGroup: A closure that takes two adjacent elements
  /// of the sequence and returns whether or not they belong in the same group.
  ///
  /// - Complexity: O(*n*), because the start index is pre-computed.
  @inlinable
  public func chunked(
    by belongInSameGroup: @escaping (Element, Element) -> Bool
  ) -> ChunkedByCollection<Elements, Element> {
    ChunkedByCollection(
      base: elements,
      projection: { $0 },
      belongInSameGroup: belongInSameGroup)
  }
  
  /// Returns a lazy collection of subsequences of this collection, chunked by
  /// grouping elements that project to equal values.
  ///
  /// - Parameter projection: A closure that takes an element in the sequence
  /// and returns an `Equatable` value that can be used to determine if adjacent
  /// elements belong in the same group.
  ///
  /// - Complexity: O(*n*), because the start index is pre-computed.
  @inlinable
  public func chunked<Subject>(
    on projection: @escaping (Element) -> Subject
  ) -> ChunkedOnCollection<Elements, Subject> {
    ChunkedOnCollection(
      base: elements,
      projection: projection)
  }
}

//===----------------------------------------------------------------------===//
// chunked(by:) / chunked(on:)
//===----------------------------------------------------------------------===//

extension Collection {
  /// Returns a collection of subsequences of this collection, chunked by the
  /// given predicate.
  ///
  /// - Parameter belongInSameGroup: A closure that takes two adjacent elements
  /// of the collection and returns whether or not they belong in the same
  /// group.
  ///
  /// - Complexity: O(*n*), where *n* is the length of this collection.
  @inlinable
  public func chunked(
    by belongInSameGroup: (Element, Element) throws -> Bool
  ) rethrows -> [SubSequence] {
    guard !isEmpty else { return [] }
    var result: [SubSequence] = []
    
    var start = startIndex
    var current = self[start]
    
    for (index, element) in indexed().dropFirst() {
      if try !belongInSameGroup(current, element) {
        result.append(self[start..<index])
        start = index
      }
      current = element
    }
    
    if start != endIndex {
      result.append(self[start...])
    }
    
    return result
  }

  /// Returns a collection of subsequences of this collection, chunked by
  /// grouping elements that project to equal values.
  ///
  /// - Parameter projection: A closure that takes an element in the collection
  /// and returns an `Equatable` value that can be used to determine if adjacent
  /// elements belong in the same group.
  ///
  /// - Complexity: O(*n*), where *n* is the length of this collection.
  @inlinable
  public func chunked<Subject: Equatable>(
    on projection: (Element) throws -> Subject
  ) rethrows -> [(Subject, SubSequence)] {
    guard !isEmpty else { return [] }
    var result: [(Subject, SubSequence)] = []
    
    var start = startIndex
    var subject = try projection(self[start])
    
    for (index, element) in indexed().dropFirst() {
      let nextSubject = try projection(element)
      if subject != nextSubject {
        result.append((subject, self[start..<index]))
        start = index
        subject = nextSubject
      }
    }
    
    if start != endIndex {
      result.append((subject, self[start...]))
    }
    
    return result
  }
}

//===----------------------------------------------------------------------===//
// chunks(ofCount:)
//===----------------------------------------------------------------------===//

/// A collection that presents the elements of its base collection in
/// `SubSequence` chunks of any given count.
///
/// A `ChunksOfCountCollection` is a lazy view on the base `Collection`, but it
/// does not implicitly confer laziness on algorithms applied to its result. In
/// other words, for ordinary collections `c`:
///
/// * `c.chunks(ofCount: 3)` does not create new storage
/// * `c.chunks(ofCount: 3).map(f)` maps eagerly and returns a new array
/// * `c.lazy.chunks(ofCount: 3).map(f)` maps lazily and returns a
///   `LazyMapCollection`
public struct ChunksOfCountCollection<Base: Collection> {
  public typealias Element = Base.SubSequence
  
  @usableFromInline
  internal let base: Base
  
  @usableFromInline
  internal let chunkCount: Int
  
  @usableFromInline
  internal var endOfFirstChunk: Base.Index

  ///  Creates a view instance that presents the elements of `base` in
  ///  `SubSequence` chunks of the given count.
  ///
  /// - Complexity: O(*n*), because the start index is pre-computed.
  @inlinable
  internal init(_base: Base, _chunkCount: Int) {
    self.base = _base
    self.chunkCount = _chunkCount
    
    // Compute the start index upfront in order to make start index a O(1)
    // lookup.
    self.endOfFirstChunk = _base.index(
      _base.startIndex, offsetBy: _chunkCount,
      limitedBy: _base.endIndex
    ) ?? _base.endIndex
  }
}

extension ChunksOfCountCollection: Collection {
  public struct Index {
    @usableFromInline
    internal let baseRange: Range<Base.Index>
    
    @inlinable
    internal init(_baseRange: Range<Base.Index>) {
      self.baseRange = _baseRange
    }
  }

  /// - Complexity: O(1)
  @inlinable
  public var startIndex: Index {
    Index(_baseRange: base.startIndex..<endOfFirstChunk)
  }
  
  @inlinable
  public var endIndex: Index {
    Index(_baseRange: base.endIndex..<base.endIndex)
  }
  
  /// - Complexity: O(1)
  @inlinable
  public subscript(i: Index) -> Element {
    precondition(i != endIndex, "Index out of range")
    return base[i.baseRange]
  }
  
  @inlinable
  public func index(after i: Index) -> Index {
    precondition(i != endIndex, "Advancing past end index")
    let baseIdx = base.index(
      i.baseRange.upperBound, offsetBy: chunkCount,
      limitedBy: base.endIndex
    ) ?? base.endIndex
    return Index(_baseRange: i.baseRange.upperBound..<baseIdx)
  }
}

extension ChunksOfCountCollection.Index: Comparable {
  @inlinable
  public static func == (lhs: ChunksOfCountCollection.Index,
                         rhs: ChunksOfCountCollection.Index) -> Bool {
    lhs.baseRange.lowerBound == rhs.baseRange.lowerBound
  }
  
  @inlinable
  public static func < (lhs: ChunksOfCountCollection.Index,
                        rhs: ChunksOfCountCollection.Index) -> Bool {
    lhs.baseRange.lowerBound < rhs.baseRange.lowerBound
  }
}

extension ChunksOfCountCollection:
  BidirectionalCollection, RandomAccessCollection
where Base: RandomAccessCollection {
  @inlinable
  public func index(before i: Index) -> Index {
    precondition(i != startIndex, "Advancing past start index")
    
    var offset = chunkCount
    if i.baseRange.lowerBound == base.endIndex {
      let remainder = base.count % chunkCount
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

extension ChunksOfCountCollection {
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
  
  @inlinable
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
  @inlinable
  internal func computeOffsetBackwardBaseDistance(
    _ i: Index, _ distance: Int
  ) -> Int {
    if i == endIndex {
      let remainder = base.count % chunkCount
      // We have to take it into account when calculating offsets.
      if remainder != 0 {
        // Distance "minus" one (at this point distance is negative) because we
        // need to adjust for the last position that have a variadic (remainder)
        // number of elements.
        return ((distance + 1) * chunkCount) - remainder
      }
    }
    return distance * chunkCount
  }
  
  @inlinable
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
  
  // Helper to compute `index(offsetBy:)` index.
  @inlinable
  internal func makeOffsetIndex(
    from i: Index, baseBound: Base.Index, distance: Int, baseDistance: Int,
    limit: Index?, by limitFn: (Base.Index, Base.Index) -> Bool
  ) -> Index? {
    let baseIdx = base.index(
      i.baseRange.lowerBound, offsetBy: baseDistance,
      limitedBy: baseBound
    )
    
    if let limit = limit {
      if baseIdx == nil {
        // If we passed the bounds while advancing forward, and the limit is the
        // `endIndex`, since the computation on `base` don't take into account
        // the remainder, we have to make sure that passing the bound was
        // because of the distance not just because of a remainder. Special
        // casing is less expensive than always using `count` (which could be
        // O(n) for non-random access collection base) to compute the base
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
  /// Returns a collection of subsequences, each with up to the specified
  /// length.
  ///
  /// If the number of elements in the collection is evenly divided by `count`,
  /// then every chunk will have a length equal to `count`. Otherwise, every
  /// chunk but the last will have a length equal to `count`, with the
  /// remaining elements in the last chunk.
  ///
  ///     let numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
  ///     for chunk in numbers.chunks(ofCount: 5) {
  ///         print(chunk)
  ///     }
  ///     // [1, 2, 3, 4, 5]
  ///     // [6, 7, 8, 9, 10]
  ///
  ///     for chunk in numbers.chunks(ofCount: 3) {
  ///         print(chunk)
  ///     }
  ///     // [1, 2, 3]
  ///     // [4, 5, 5]
  ///     // [7, 8, 9]
  ///     // [10]
  ///
  /// - Parameter count: The desired size of each chunk.
  /// - Returns: A collection of consescutive, non-overlapping subseqeunces of
  ///   this collection, where each subsequence (except possibly the last) has
  ///   the length `count`.
  ///
  /// - Complexity: O(1) if the collection conforms to `RandomAccessCollection`;
  ///   otherwise, O(*k*), where *k* is equal to `count`.
  ///
  @inlinable
  public func chunks(ofCount count: Int) -> ChunksOfCountCollection<Self> {
    precondition(count > 0, "Cannot chunk with count <= 0!")
    return ChunksOfCountCollection(_base: self, _chunkCount: count)
  }
}

extension ChunksOfCountCollection.Index: Hashable where Base.Index: Hashable {}

extension ChunksOfCountCollection: LazySequenceProtocol
  where Base: LazySequenceProtocol {}

extension ChunksOfCountCollection: LazyCollectionProtocol
  where Base: LazyCollectionProtocol {}

//===----------------------------------------------------------------------===//
// evenlyChunked(in:)
//===----------------------------------------------------------------------===//

extension Collection {
  /// Returns a collection of evenly divided consecutive subsequences of this
  /// collection.
  ///
  /// This method divides the collection into a given number of evenly sized
  /// chunks. If the length of the collection is not divisible by `count`, the
  /// chunks at the start will be longer than the chunks at the end, like in
  /// this example:
  ///
  ///     for chunk in "Hello, world!".evenlyChunked(in: 5) {
  ///         print(chunk)
  ///     }
  ///     // "Hel"
  ///     // "lo,"
  ///     // " wo"
  ///     // "rl"
  ///     // "d!"
  ///
  /// If the number passed as `count` is greater than the number of elements in
  /// the collection, the result will include one or more empty subsequences.
  ///
  ///     for chunk in "Hi!".evenlyChunked(in: 5) {
  ///         print(chunk)
  ///     }
  ///     // "H"
  ///     // "i"
  ///     // "!"
  ///     // ""
  ///     // ""
  ///
  /// - Parameter count: The number of chunks to evenly divide this collection
  ///   into. If this collection is non-empty, `count` must be greater than
  ///   zero; otherwise, `count` may be zero or greater.
  /// - Returns: A collection of `count` subsequences of this collection,
  ///   divided as evenly as possible.
  ///
  /// - Complexity: O(1) if the collection conforms to `RandomAccessCollection`;
  ///   otherwise, O(*n*), where *n* is the length of the collection.
  @inlinable
  public func evenlyChunked(in count: Int) -> EvenlyChunkedCollection<Self> {
    precondition(count >= 0, "Can't divide into a negative number of chunks")
    precondition(count > 0 || isEmpty, "Can't divide a non-empty collection into 0 chunks")
    return EvenlyChunkedCollection(base: self, numberOfChunks: count)
  }
}
