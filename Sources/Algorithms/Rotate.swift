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
