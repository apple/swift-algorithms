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
  ///             f               l
  ///
  /// - Postcondition: For returned indices `(f, l)`:
  ///   `f == limit || l == limit`
  @discardableResult
  internal mutating func _reverse(
    subrange: Range<Index>, until limit: Index
  ) -> (Index, Index) {
    var f = subrange.lowerBound
    var l = subrange.upperBound
    while f != limit && l != limit {
      formIndex(before: &l)
      swapAt(f, l)
      formIndex(after: &f)
    }
    return (f, l)
  }
  
  public mutating func reverse(subrange: Range<Index>) {
    if subrange.isEmpty { return }
    var lo = subrange.lowerBound
    var hi = subrange.upperBound
    
    while lo < hi {
      formIndex(before: &hi)
      swapAt(lo, hi)
      formIndex(after: &lo)
    }
  }
}

//===----------------------------------------------------------------------===//
// rotate(at:) / rotate(subrange:at:)
//===----------------------------------------------------------------------===//

extension MutableCollection {
  /// Swaps the elements of the two given subranges, up to the upper bound of
  /// the smaller subrange. The returned indices are the ends of the two
  /// ranges that were actually swapped.
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

  @discardableResult
  public mutating func rotate(
    subrange: Range<Index>,
    at newStart: Index
  ) -> Index {
    var m = newStart, s = subrange.lowerBound
    let e = subrange.upperBound
    
    // Handle the trivial cases
    if s == m { return e }
    if m == e { return s }
    
    // We have two regions of possibly-unequal length that need to be
    // exchanged.  The return value of this method is going to be the
    // position following that of the element that is currently last
    // (element j).
    //
    //   [a b c d e f g|h i j]   or   [a b c|d e f g h i j]
    //   ^             ^     ^        ^     ^             ^
    //   s             m     e        s     m             e
    //
    var ret = e // start with a known incorrect result.
    while true {
      // Exchange the leading elements of each region (up to the
      // length of the shorter region).
      //
      //   [a b c d e f g|h i j]   or   [a b c|d e f g h i j]
      //    ^^^^^         ^^^^^          ^^^^^ ^^^^^
      //   [h i j d e f g|a b c]   or   [d e f|a b c g h i j]
      //   ^     ^       ^     ^         ^    ^     ^       ^
      //   s    s1       m    m1/e       s   s1/m   m1      e
      //
      let (s1, m1) = _swapNonemptySubrangePrefixes(s..<m, m..<e)
      
      if m1 == e {
        // Left-hand case: we have moved element j into position.  if
        // we haven't already, we can capture the return value which
        // is in s1.
        //
        // Note: the STL breaks the loop into two just to avoid this
        // comparison once the return value is known.  I'm not sure
        // it's a worthwhile optimization, though.
        if ret == e { ret = s1 }
        
        // If both regions were the same size, we're done.
        if s1 == m { break }
      }
      
      // Now we have a smaller problem that is also a rotation, so we
      // can adjust our bounds and repeat.
      //
      //    h i j[d e f g|a b c]   or    d e f[a b c|g h i j]
      //         ^       ^     ^              ^     ^       ^
      //         s       m     e              s     m       e
      s = s1
      if s == m { m = m1 }
    }
    
    return ret
  }
  
  @discardableResult
  public mutating func rotate(at newStart: Index) -> Index {
    rotate(subrange: startIndex..<endIndex, at: newStart)
  }
}

extension MutableCollection where Self: BidirectionalCollection {
  @discardableResult
  public mutating func rotate(
    subrange: Range<Index>,
    at newStart: Index
  ) -> Index {
    reverse(subrange: subrange.lowerBound..<newStart)
    reverse(subrange: newStart..<subrange.upperBound)
    let (p, q) = _reverse(subrange: subrange, until: newStart)
    reverse(subrange: p..<q)
    return newStart == p ? q : p
  }

  /// Rotates the elements of this collection so that the element
  /// at the specified index moves to the front of the collection.
  ///
  /// Rotating a collection is equivalent to breaking the collection into two
  /// sections at the index `newStart`, and then swapping those two sections.
  /// In this example, the `numbers` array is rotated so that the element at
  /// index `3` (`40`) is first:
  ///
  ///     var numbers = [10, 20, 30, 40, 50, 60, 70, 80]
  ///     let oldStart = numbers.rotate(at: 3)
  ///     // numbers == [40, 50, 60, 70, 80, 10, 20, 30]
  ///     // numbers[oldStart] == 10
  ///
  /// - Parameter newStart: The index of the element that should be first after
  ///   rotating.
  /// - Returns: The new index of the element that was first pre-rotation.
  ///
  /// - Complexity: O(*n*)
  @discardableResult
  public mutating func rotate(at newStart: Index) -> Index {
    rotate(subrange: startIndex..<endIndex, at: newStart)
  }
}
