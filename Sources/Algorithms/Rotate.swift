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
// reverse(subrange:)
//===----------------------------------------------------------------------===//

extension MutableCollection where Self: BidirectionalCollection {
  /// Reverses the elements of the collection, moving from each end until
  /// `limit` is reached from either direction. The returned indices are the
  /// start and end of the range of unreversed elements.
  ///
  ///     Input:
  ///     [a b c d e f g h i j k l m n o p]
  ///             ^
  ///           limit
  ///     Output:
  ///     [p o n m e f g h i j k l d c b a]
  ///             ^               ^
  ///           lower           upper
  ///
  /// - Postcondition: For returned indices `(lower, upper)`:
  ///   `lower == limit || upper == limit`
  @inlinable
  @discardableResult
  internal mutating func _reverse(
    subrange: Range<Index>, until limit: Index
  ) -> (Index, Index) {
    var lower = subrange.lowerBound
    var upper = subrange.upperBound
    while lower != limit && upper != limit {
      formIndex(before: &upper)
      swapAt(lower, upper)
      formIndex(after: &lower)
    }
    return (lower, upper)
  }
  
  /// Reverses the elements within the given subrange.
  ///
  /// This example reverses the numbers within the subrange at the start of the
  /// `numbers` array:
  ///
  ///     var numbers = [10, 20, 30, 40, 50, 60, 70, 80]
  ///     numbers.reverse(subrange: 0..<4)
  ///     // numbers == [40, 30, 20, 10, 50, 60, 70, 80]
  ///
  /// - Parameter subrange: The subrange of this collection to reverse.
  ///
  /// - Complexity: O(*n*), where *n* is the length of `subrange`.
  @inlinable
  public mutating func reverse(subrange: Range<Index>) {
    if subrange.isEmpty { return }
    var lower = subrange.lowerBound
    var upper = subrange.upperBound
    while lower < upper {
      formIndex(before: &upper)
      swapAt(lower, upper)
      formIndex(after: &lower)
    }
  }
}

//===----------------------------------------------------------------------===//
// rotate(toStartAt:) / rotate(subrange:toStartAt:)
//===----------------------------------------------------------------------===//

extension MutableCollection {
  /// Swaps the elements of the two given subranges, up to the upper bound of
  /// the smaller subrange. The returned indices are the ends of the two ranges
  /// that were actually swapped.
  ///
  ///     Input:
  ///     [a b c d e f g h i j k l m n o p]
  ///      ^^^^^^^         ^^^^^^^^^^^^^
  ///      lhs             rhs
  ///
  ///     Output:
  ///     [i j k l e f g h a b c d m n o p]
  ///             ^               ^
  ///             p               q
  ///
  /// - Precondition: !lhs.isEmpty && !rhs.isEmpty
  /// - Postcondition: For returned indices `(p, q)`:
  ///
  ///   - distance(from: lhs.lowerBound, to: p) == distance(from:
  ///     rhs.lowerBound, to: q)
  ///   - p == lhs.upperBound || q == rhs.upperBound
  @inlinable
  internal mutating func _swapNonemptySubrangePrefixes(
    _ lhs: Range<Index>, _ rhs: Range<Index>
  ) -> (Index, Index) {
    assert(!lhs.isEmpty)
    assert(!rhs.isEmpty)
    
    var p = lhs.lowerBound
    var q = rhs.lowerBound
    repeat {
      swapAt(p, q)
      formIndex(after: &p)
      formIndex(after: &q)
    }
      while p != lhs.upperBound && q != rhs.upperBound
    return (p, q)
  }

  /// Rotates the elements within the given subrange so that the element at the
  /// specified index becomes the start of the subrange.
  ///
  /// Rotating a collection is equivalent to breaking the collection into two
  /// sections at the index `newStart`, and then swapping those two sections.
  /// In this example, the `numbers` array is rotated so that the element at
  /// index `3` (`40`) is first:
  ///
  ///     var numbers = [10, 20, 30, 40, 50, 60, 70, 80]
  ///     let oldStart = numbers.rotate(subrange: 0..<4, toStartAt: 2)
  ///     // numbers == [30, 40, 10, 20, 50, 60, 70, 80]
  ///     // numbers[oldStart] == 10
  ///
  /// - Parameters:
  ///   - subrange: The subrange of this collection to rotate.
  ///   - newStart: The index of the element that should be at the start of
  ///     `subrange` after rotating.
  /// - Returns: The new index of the element that was at the start of
  ///   `subrange` pre-rotation.
  ///
  /// - Complexity: O(*n*), where *n* is the length of `subrange`.
  @inlinable
  @discardableResult
  public mutating func rotate(
    subrange: Range<Index>,
    toStartAt newStart: Index
  ) -> Index {
    var m = newStart, s = subrange.lowerBound
    let e = subrange.upperBound
    
    // Handle the trivial cases
    if s == m { return e }
    if m == e { return s }
    
    // We have two regions of possibly-unequal length that need to be exchanged.
    // The return value of this method is going to be the position following
    // that of the element that is currently last (element j).
    //
    //   [a b c d e f g|h i j]   or   [a b c|d e f g h i j]
    //   ^             ^     ^        ^     ^             ^
    //   s             m     e        s     m             e
    //
    var ret = e // start with a known incorrect result.
    while true {
      // Exchange the leading elements of each region (up to the length of the
      // shorter region).
      //
      //   [a b c d e f g|h i j]   or   [a b c|d e f g h i j]
      //    ^^^^^         ^^^^^          ^^^^^ ^^^^^
      //   [h i j d e f g|a b c]   or   [d e f|a b c g h i j]
      //   ^     ^       ^     ^         ^    ^     ^       ^
      //   s    s1       m    m1/e       s   s1/m   m1      e
      //
      let (s1, m1) = _swapNonemptySubrangePrefixes(s..<m, m..<e)
      
      if m1 == e {
        // Left-hand case: we have moved element j into position. If we haven't
        // already, we can capture the return value which is in s1.
        //
        // Note: the STL breaks the loop into two just to avoid this comparison
        // once the return value is known. I'm not sure it's a worthwhile
        // optimization, though.
        if ret == e { ret = s1 }
        
        // If both regions were the same size, we're done.
        if s1 == m { break }
      }
      
      // Now we have a smaller problem that is also a rotation, so we can adjust
      // our bounds and repeat.
      //
      //    h i j[d e f g|a b c]   or    d e f[a b c|g h i j]
      //         ^       ^     ^              ^     ^       ^
      //         s       m     e              s     m       e
      s = s1
      if s == m { m = m1 }
    }
    
    return ret
  }
  
  /// Rotates the elements of this collection so that the element at the
  /// specified index becomes the start of the collection.
  ///
  /// Rotating a collection is equivalent to breaking the collection into two
  /// sections at the index `newStart`, and then swapping those two sections.
  /// In this example, the `numbers` array is rotated so that the element at
  /// index `3` (`40`) is first:
  ///
  ///     var numbers = [10, 20, 30, 40, 50, 60, 70, 80]
  ///     let oldStart = numbers.rotate(toStartAt: 3)
  ///     // numbers == [40, 50, 60, 70, 80, 10, 20, 30]
  ///     // numbers[oldStart] == 10
  ///
  /// - Parameter newStart: The index of the element that should be first after
  ///   rotating.
  /// - Returns: The new index of the element that was first pre-rotation.
  ///
  /// - Complexity: O(*n*), where *n* is the length of the collection.
  @inlinable
  @discardableResult
  public mutating func rotate(toStartAt newStart: Index) -> Index {
    rotate(subrange: startIndex..<endIndex, toStartAt: newStart)
  }
}

extension MutableCollection where Self: BidirectionalCollection {
  /// Rotates the elements within the given subrange so that the element at the
  /// specified index becomes the start of the subrange.
  ///
  /// Rotating a collection is equivalent to breaking the collection into two
  /// sections at the index `newStart`, and then swapping those two sections.
  /// In this example, the `numbers` array is rotated so that the element at
  /// index `3` (`40`) is first:
  ///
  ///     var numbers = [10, 20, 30, 40, 50, 60, 70, 80]
  ///     let oldStart = numbers.rotate(subrange: 0..<4, toStartAt: 2)
  ///     // numbers == [30, 40, 10, 20, 50, 60, 70, 80]
  ///     // numbers[oldStart] == 10
  ///
  /// - Parameters:
  ///   - subrange: The subrange of this collection to rotate.
  ///   - newStart: The index of the element that should be at the start of
  ///     `subrange` after rotating.
  /// - Returns: The new index of the element that was at the start of
  ///   `subrange` pre-rotation.
  ///
  /// - Complexity: O(*n*), where *n* is the length of `subrange`.
  @inlinable
  @discardableResult
  public mutating func rotate(
    subrange: Range<Index>,
    toStartAt newStart: Index
  ) -> Index {
    reverse(subrange: subrange.lowerBound..<newStart)
    reverse(subrange: newStart..<subrange.upperBound)
    let (p, q) = _reverse(subrange: subrange, until: newStart)
    reverse(subrange: p..<q)
    return newStart == p ? q : p
  }

  /// Rotates the elements of this collection so that the element at the
  /// specified index becomes the start of the collection.
  ///
  /// Rotating a collection is equivalent to breaking the collection into two
  /// sections at the index `newStart`, and then swapping those two sections. In
  /// this example, the `numbers` array is rotated so that the element at index
  /// `3` (`40`) is first:
  ///
  ///     var numbers = [10, 20, 30, 40, 50, 60, 70, 80]
  ///     let oldStart = numbers.rotate(toStartAt: 3)
  ///     // numbers == [40, 50, 60, 70, 80, 10, 20, 30]
  ///     // numbers[oldStart] == 10
  ///
  /// - Parameter newStart: The index of the element that should be first after
  ///   rotating.
  /// - Returns: The new index of the element that was first pre-rotation.
  ///
  /// - Complexity: O(*n*), where *n* is the length of the collection.
  @inlinable
  @discardableResult
  public mutating func rotate(toStartAt newStart: Index) -> Index {
    rotate(subrange: startIndex..<endIndex, toStartAt: newStart)
  }
}

//===----------------------------------------------------------------------===//
// RotatedCollection
//===----------------------------------------------------------------------===//
public struct RotatedCollection<Base: Collection> {
  public typealias Element = Base.Element

  @usableFromInline
  internal let base: Base

  @usableFromInline
  internal let newStart: Base.Index

  @usableFromInline
  internal let subrange: Range<Base.Index>

  @usableFromInline
  internal let rotatedStartIdx: Base.Index

  @usableFromInline
  internal let newStartDistance: Int

  @usableFromInline
  internal let lowerboundRotatedDistance: Int

  /// - Complexity: O(1) when `Base` conforms to `RandomAccessCollection`.
  /// Otherwise, O(*n*), where *n* is the count of the subrange.
  @inlinable
  internal init(
    _base: Base, _subrange: Range<Base.Index>, _newStart: Base.Index
  ) {
    self.base = _base
    self.subrange = _subrange
    self.newStart = _newStart

    // Pre-computed indexes and distance in order to calculate rotated
    // position.
    self.newStartDistance = base.distance(from: subrange.lowerBound,
                                          to: newStart)
    self.lowerboundRotatedDistance = base.distance(from: newStart,
                                                   to: subrange.upperBound)
    self.rotatedStartIdx = base.index(subrange.lowerBound,
                                      offsetBy: lowerboundRotatedDistance)
  }
}

extension RotatedCollection: Collection {
  public struct Index {
    @usableFromInline
    internal let baseIndex: Base.Index

    @inlinable
    internal init(_baseIndex: Base.Index) {
      self.baseIndex = _baseIndex
    }
  }

  @inlinable
  public var startIndex: Index {
    Index(_baseIndex: base.startIndex)
  }

  @inlinable
  public var endIndex: Index {
    Index(_baseIndex: base.endIndex)
  }

  /// - Complexity: O(1) if the collection conforms to
  /// `RandomAccessCollection`. Otherwise, O(*n*), where
  /// *n* is the count of the `subrange`.
  @inlinable
  public subscript(i: Index) -> Element {
    precondition(i != endIndex, "Index out of range")
    return base[_computeRotated(i.baseIndex)]
  }

  @inlinable
  public func index(after i: Index) -> Index {
    precondition(i != endIndex, "Advancing past end index")
    let next = base.index(after: i.baseIndex)
    return Index(_baseIndex: next)
  }

  @inlinable
  internal func _computeRotated(_ _originalIndex: Base.Index) -> Base.Index {
    guard subrange.contains(_originalIndex) else {
      return _originalIndex
    }

    guard subrange.lowerBound != newStart else {
      return _originalIndex
    }

    if _originalIndex < rotatedStartIdx {
      return base.index(_originalIndex, offsetBy: newStartDistance)
    } else {
      return base.index(_originalIndex, offsetBy: -lowerboundRotatedDistance)
    }
  }
}

extension RotatedCollection {
  /// - Complexity: O(1) when `Base` conforms to `RandomAccessCollection`.
  /// Otherwise, O(*n*), where *n* is the absolute value of `distance`.
  @inlinable
  public func index(_ i: Index, offsetBy distance: Int) -> Index {
    Index(_baseIndex: base.index(i.baseIndex, offsetBy: distance))
  }

  /// - Complexity: O(1) when `Base` conforms to `RandomAccessCollection`.
  /// Otherwise, O(*n*), where *n* is the absolute value of `distance`.
  @inlinable
  public func index(
    _ i: Index,
    offsetBy distance: Int,
    limitedBy limit: Index
  ) -> Index? {
    guard let idx = base.index(
      i.baseIndex, offsetBy: distance, limitedBy: limit.baseIndex
    ) else { return nil }
    return Index(_baseIndex: idx)
  }

  /// - Complexity: O(1) when `Base` conforms to `RandomAccessCollection`.
  /// Otherwise, O(*n*), where *n* is the absolute value of resulting `distance`.
  @inlinable
  public func distance(from start: Index, to end: Index) -> Int {
    base.distance(from: start.baseIndex, to: end.baseIndex)
  }

  /// - Complexity: O(1) when `Base` conforms to `RandomAccessCollection`.
  /// Otherwise O(*n*), where *n* is the count of base collection.
  @inlinable
  public var count: Int { base.count }
}

/// Bidirectional Collection Conformance 
extension RotatedCollection: BidirectionalCollection
  where Base: BidirectionalCollection {
  @inlinable
  public func index(before i: Index) -> Index {
    precondition(i != startIndex, "Advancing past start index")
    let previous = base.index(before: i.baseIndex)
    return Index(_baseIndex: previous)
  }
}

extension RotatedCollection.Index: Comparable {
  @inlinable
  public static func == (lhs: RotatedCollection.Index,
                         rhs: RotatedCollection.Index) -> Bool {
    lhs.baseIndex == rhs.baseIndex
  }

  @inlinable
  public static func < (lhs: RotatedCollection.Index,
                        rhs: RotatedCollection.Index) -> Bool {
    lhs.baseIndex < rhs.baseIndex
  }
}

//===----------------------------------------------------------------------===//
// rotated(toStartAt:) / rotated(subrange:toStartAt:)
//===----------------------------------------------------------------------===//
extension Collection {
  /// Returns a `RotatedCollection<Self>` view where the elements of this collection
  /// in the given `subrange` are rotated so that the element at the specified `newStart`
  /// becomes the start of that subrange..
  ///
  /// Rotating a collection is equivalent to breaking the collection into two
  /// sections at the index `newStart`, and then swapping those two sections.
  /// In this example, the `numbers` array rotated  is a
  /// `RotatedCollection<Self>` view  where the element originally
  /// at`2` (`30`) is first of the collection subrange `0..<4`:
  ///
  ///     var numbers = [10, 20, 30, 40, 50, 60, 70, 80]
  ///     let rotatedNumbers = numbers.rotated(subrange: 0..<4, toStartAt: 2)
  ///     // rotatedNumbers == [30, 40, 10, 20, 50, 60, 70, 80]
  ///
  /// - Parameters:
  ///   - subrange: The subrange of this collection to rotate.
  ///   - newStart: The index of the element that should be at the start of
  ///     `subrange` after rotating.
  /// - Returns: A `RotatedCollection<Self>` view presenting the
  /// elements in the `subrange` of the base collection rotated according with
  /// `newStart` index.
  /// - Complexity: O(1) when `Base` conforms to `RandomAccessCollection`.
  /// Otherwise, O(*n*), where *n* is the `distance` of the subrange in the base collection.
  @inlinable
  public func rotated(
    subrange: Range<Index>,
    toStartAt newStart: Index
  ) -> RotatedCollection<Self> {
    precondition(subrange.isEmpty ||
                 subrange.contains(newStart), "newStart not in subrange")
    precondition(
      subrange.lowerBound >= startIndex && subrange.upperBound <= endIndex
    )
    return RotatedCollection(
      _base: self, _subrange: subrange, _newStart: newStart
    )
  }

  /// Returns a `RotatedCollection<Self>` view where the elements of
  /// this collection so that the element at the specified `newStart` becomes
  /// the start of the collection.
  ///
  /// Rotating a collection is equivalent to breaking the collection into two
  /// sections at the index `newStart`, and then swapping those two sections.
  /// In this example, the result of `numbers` rotated is a
  /// `RotatedCollection<Self>` view where the element at index
  /// `3` (`40`) is the first element:
  ///
  ///     var numbers = [10, 20, 30, 40, 50, 60, 70, 80]
  ///     let rotatedNumbers = numbers.rotated(toStartAt: 3)
  ///     // rotatedNumbers == [40, 50, 60, 70, 80, 10, 20, 30]
  ///
  /// - Parameter newStart: The index of the element that should be first after
  ///   rotating.
  /// - Returns: A `RotatedCollection<Self>` view presenting the elements
  /// of the base collection in the given `subrange` rotated according with
  /// `newStart` index.
  ///
  /// - Complexity: O(1) when `Base` conforms to `RandomAccessCollection`.
  /// Otherwise, O(*n*), where *n* is the length of the collection.
  @inlinable
  public func rotated(
    toStartAt newStart: Index
  ) -> RotatedCollection<Self> {
    RotatedCollection(
      _base: self, _subrange: startIndex..<endIndex, _newStart: newStart
    )
  }
}

extension RotatedCollection.Index: Hashable where Base.Index: Hashable {}

extension RotatedCollection: RandomAccessCollection
  where Base: RandomAccessCollection {}

extension RotatedCollection: LazySequenceProtocol, LazyCollectionProtocol
  where Base: LazySequenceProtocol {}
