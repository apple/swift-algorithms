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

/// A sequence that represents the product of two sequences' elements.
public struct Product2Sequence<Base1: Sequence, Base2: Collection> {
  /// The outer sequence in the product.
  @usableFromInline
  internal let base1: Base1
  
  /// The inner sequence in the product.
  @usableFromInline
  internal let base2: Base2
  
  @inlinable
  internal init(_ base1: Base1, _ base2: Base2) {
    self.base1 = base1
    self.base2 = base2
  }
}

extension Product2Sequence: Sequence {
  public typealias Element = (Base1.Element, Base2.Element)
  
  /// The iterator for a `Product2Sequence` sequence.
  public struct Iterator: IteratorProtocol {
    @usableFromInline
    internal var i1: Base1.Iterator
    @usableFromInline
    internal var i2: Base2.Iterator
    @usableFromInline
    internal var element1: Base1.Element?
    @usableFromInline
    internal let base2: Base2

    @inlinable
    internal init(_ c: Product2Sequence) {
      self.base2 = c.base2
      self.i1 = c.base1.makeIterator()
      self.i2 = c.base2.makeIterator()
      self.element1 = nil
    }
    
    @inlinable
    public mutating func next() -> (Base1.Element,
                                    Base2.Element)? {
      // This is the initial state, where i1.next() has never
      // been called, or the final state, where i1.next() has
      // already returned nil.
      if element1 == nil {
        element1 = i1.next()
        // once Base1 is exhausted, return `nil` forever
        if element1 == nil { return nil }
      }
      
      // Get the next element from the second sequence, if not
      // at end.
      if let element2 = i2.next() {
        return (element1!, element2)
      }
      
      // We've reached the end of the second sequence, so:
      // 1) Get the next element of the first sequence, if exists
      // 2) Restart iteration of the second sequence
      // 3) Get the first element of the second sequence, if exists
      element1 = i1.next()
      guard let element1 = element1
        else { return nil }
      
      i2 = base2.makeIterator()
      if let element2 = i2.next() {
        return (element1, element2)
      } else {
        return nil
      }
    }
  }

  @inlinable
  public func makeIterator() -> Iterator {
    Iterator(self)
  }
}

extension Product2Sequence: Collection where Base1: Collection {
  /// The index type for a `Product2Sequence` collection.
  public struct Index: Comparable {
    @usableFromInline
    internal var i1: Base1.Index
    @usableFromInline
    internal var i2: Base2.Index
    
    @inlinable
    internal init(i1: Base1.Index, i2: Base2.Index) {
      self.i1 = i1
      self.i2 = i2
    }
    
    @inlinable
    public static func < (lhs: Index, rhs: Index) -> Bool {
      (lhs.i1, lhs.i2) < (rhs.i1, rhs.i2)
    }
  }
  
  @inlinable
  public var count: Int {
    base1.count * base2.count
  }
  
  @inlinable
  public var startIndex: Index {
    Index(
      i1: base2.isEmpty ? base1.endIndex : base1.startIndex,
      i2: base2.startIndex)
  }
  
  @inlinable
  public var endIndex: Index {
    // `base2.startIndex` simplifies index calculations.
    Index(i1: base1.endIndex, i2: base2.startIndex)
  }
  
  @inlinable
  public subscript(position: Index) -> (Base1.Element,
                                        Base2.Element) {
    (base1[position.i1], base2[position.i2])
  }
  
  /// Forms an index from a pair of base indices, normalizing
  /// `(i, base2.endIndex)` to `(base1.index(after: i), base2.startIndex)` if
  /// necessary.
  @inlinable
  internal func normalizeIndex(_ i1: Base1.Index, _ i2: Base2.Index) -> Index {
    i2 == base2.endIndex
      ? Index(i1: base1.index(after: i1), i2: base2.startIndex)
      : Index(i1: i1, i2: i2)
  }
  
  @inlinable
  public func index(after i: Index) -> Index {
    precondition(i.i1 != base1.endIndex, "Can't advance past endIndex")
    return normalizeIndex(i.i1, base2.index(after: i.i2))
  }
  
  @inlinable
  public func distance(from start: Index, to end: Index) -> Int {
    guard start.i1 <= end.i1
      else { return -distance(from: end, to: start) }
    guard start.i1 != end.i1
      else { return base2.distance(from: start.i2, to: end.i2) }
    
    // The number of full cycles through `base2` between `start` and `end`,
    // excluding the cycles that `start` and `end` are on.
    let fullBase2Cycles = base1[start.i1..<end.i1].count - 1
    
    if start.i2 <= end.i2 {
      //               start.i2
      //                  v
      // start.i1 > [l l l|c c c c c c r r r]
      //            [l l l c c c c c c r r r] >
      //                       ...            > `fullBase2Cycles` times
      //            [l l l c c c c c c r r r] >
      //   end.i1 > [l l l c c c c c c|r r r]
      //                              ^
      //                            end.i2
      
      let left = base2[..<start.i2].count
      let center = base2[start.i2..<end.i2].count
      let right = base2[end.i2...].count
      
      return center + right
        + fullBase2Cycles * (left + center + right)
        + left + center
    } else {
      //                           start.i2
      //                              v
      // start.i1 > [l l l c c c c c c|r r r]
      //            [l l l c c c c c c r r r] >
      //                       ...            > `fullBase2Cycles` times
      //            [l l l c c c c c c r r r] >
      //   end.i1 > [l l l|c c c c c c r r r]
      //                  ^
      //                end.i2
      
      let left = base2[..<end.i2].count
      let right = base2[start.i2...].count
      
      // We can avoid traversing `base2[end.i2..<start.i2]` if `start` and `end`
      // are on consecutive cycles.
      guard fullBase2Cycles > 0 else { return right + left }
      
      let center = base2[end.i2..<start.i2].count
      return right
        + fullBase2Cycles * (left + center + right)
        + left
    }
  }
  
  @inlinable
  public func index(_ i: Index, offsetBy distance: Int) -> Index {
    guard distance != 0 else { return i }
    
    return distance > 0
      ? offsetForward(i, by: distance)
      : offsetBackward(i, by: -distance)
  }
  
  @inlinable
  public func index(
    _ i: Index,
    offsetBy distance: Int,
    limitedBy limit: Index
  ) -> Index? {
    if distance >= 0 {
      return limit >= i
        ? offsetForward(i, by: distance, limitedBy: limit)
        : offsetForward(i, by: distance)
    } else {
      return limit <= i
        ? offsetBackward(i, by: -distance, limitedBy: limit)
        : offsetBackward(i, by: -distance)
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
    _ i: Index, by distance: Int, limitedBy limit: Index
  ) -> Index? {
    assert(distance >= 0)
    assert(limit >= i)
    
    if limit.i1 == i.i1 {
      // Delegate to `base2` if the offset is limited to `i.i1`.
      //
      //             i.i2      limit.i2
      //              v           v
      // i.i1 > [x x x|x x x x x x|x x x]
      
      return base2.index(i.i2, offsetBy: distance, limitedBy: limit.i2)
        .map { i2 in Index(i1: i.i1, i2: i2) }
    }
    
    
    if let i2 = base2.index(i.i2, offsetBy: distance, limitedBy: base2.endIndex) {
      // `distance` does not overflow `base2[i.i2...]`.
      //
      //             i.i2         i2
      //              v           v
      // i.i1 > [x x x|x x x x x x|x x x]
      //        [     |> > > > > >|     ]   (`distance`)
      
      return normalizeIndex(i.i1, i2)
    }
    
    let suffixCount = base2[i.i2...].count
    let remaining = distance - suffixCount
    let nextI1 = base1.index(after: i.i1)
    
    if limit.i1 == nextI1 {
      // Delegate to `base2` if the offset is limited to `nextI1`.
      //
      //               i.i2
      //                v
      //   i.i1 > [x x x|x x x x x x x x x]
      // nextI1 > [x x x x x x x x x|x x x]
      //                            ^
      //                         limit.i2
      
      return base2.index(base2.startIndex, offsetBy: remaining, limitedBy: limit.i2)
        .map { i2 in Index(i1: nextI1, i2: i2) }
    }
    
    if let i2 = base2.index(base2.startIndex, offsetBy: remaining, limitedBy: i.i2) {
      // `remaining` does not overflow `base2[..<i.i2]`.
      //
      //                           i.i2
      //                            v
      //   i.i1 > [x x x x x x x x x|x x x]
      //          [                 |> > >]   (`suffixCount`)
      //          [> > >|                 ]   (`remaining`)
      // nextI1 > [x x x|x x x x x x x x x]
      //                ^
      //                i2
      
      return Index(i1: nextI1, i2: i2)
    }
    
    let prefixCount = base2[..<i.i2].count
    let base2Count = prefixCount + suffixCount
    let base1Distance = remaining / base2Count
    
    guard let i1 = base1.index(nextI1, offsetBy: base1Distance, limitedBy: limit.i1)
      else { return nil }
    
    // The distance from `base2.startIndex` to the target.
    let base2Distance = remaining % base2Count
    
    let base2Limit = limit.i1 == i1 ? limit.i2 : base2.endIndex
    return base2.index(base2.startIndex, offsetBy: base2Distance, limitedBy: base2Limit)
      .map { i2 in Index(i1: i1, i2: i2) }
  }

  @inlinable
  internal func offsetBackward(
    _ i: Index, by distance: Int, limitedBy limit: Index
  ) -> Index? {
    assert(distance >= 0)
    assert(limit <= i)
    
    if limit.i1 == i.i1 {
      // Delegate to `base2` if the offset is limited to `i.i1`.
      //
      //           limit.i2      i.i2
      //              v           v
      // i.i1 > [x x x|x x x x x x|x x x]
      
      return base2.index(i.i2, offsetBy: -distance, limitedBy: limit.i2)
        .map { i2 in Index(i1: i.i1, i2: i2) }
    }
    
    if let i2 = base2.index(i.i2, offsetBy: -distance, limitedBy: base2.startIndex) {
      // `distance` does not underflow `base2[..<i.i2]`.
      //
      //              i2         i.i2
      //              v           v
      // i.i1 > [x x x|x x x x x x|x x x]
      //        [     |< < < < < <|     ]   (`distance`)
      
      return Index(i1: i.i1, i2: i2)
    }
    
    let prefixCount = base2[..<i.i2].count
    let remaining = distance - prefixCount
    let previousI1 = base1.index(i.i1, offsetBy: -1)
    
    if limit.i1 == previousI1 {
      // Delegate to `base2` if the offset is limited to `previousI1`.
      //
      //                 limit.i2
      //                    v
      // previousI1 > [x x x|x x x x x x x x x]
      //       i.i1 > [x x x x x x x x x|x x x]
      //                                ^
      //                               i.i2
      
      return base2.index(base2.endIndex, offsetBy: -remaining, limitedBy: limit.i2)
        .map { i2 in Index(i1: previousI1, i2: i2) }
    }
    
    if let i2 = base2.index(base2.endIndex, offsetBy: -remaining, limitedBy: i.i2) {
      // `remaining` does not underflow `base2[i.i2...]`.
      //
      //                                i2
      //                                v
      // previousI1 > [x x x x x x x x x|x x x]
      //              [                 |< < <]   (`remaining`)
      //              [< < <|                 ]   (`prefixCount`)
      //       i.i1 > [x x x|x x x x x x x x x]
      //                    ^
      //                   i.i2
      
      return Index(i1: previousI1, i2: i2)
    }
    
    let suffixCount = base2[i.i2...].count
    let base2Count = prefixCount + suffixCount
    let base1Distance = remaining / base2Count
    
    // The distance from `base2.endIndex` to the target.
    let base2Distance = remaining % base2Count
    
    if base2Distance == 0 {
      // We end up exactly between two cycles, so `base1Distance` would
      // overshoot the target by 1.
      //
      //       base2.startIndex
      //              v
      //         i1 > |x x x x x x x x x x x x] >
      //                         ...            > `base1Distance` times
      // previousI1 > [x x x x x x x x x x x x] >
      //       i.i1 > [x x x|x x x x x x x x x]
      //                    ^
      //                   i.i2
      
      if let i1 = base1.index(previousI1, offsetBy: -(base1Distance - 1), limitedBy: limit.i1) {
        let index = Index(i1: i1, i2: base2.startIndex)
        return index < limit ? nil : index
      } else {
        return nil
      }
    }
    
    guard let i1 = base1.index(previousI1, offsetBy: -base1Distance, limitedBy: limit.i1)
      else { return nil }
    
    let base2Limit = limit.i1 == i1 ? limit.i2 : base2.startIndex
    return base2.index(base2.endIndex, offsetBy: -base2Distance, limitedBy: base2Limit)
      .map { i2 in Index(i1: i1, i2: i2) }
  }
}

extension Product2Sequence: BidirectionalCollection
  where Base1: BidirectionalCollection, Base2: BidirectionalCollection
{
  @inlinable
  public func index(before i: Index) -> Index {
    precondition(i != startIndex,
                 "Can't move before startIndex")
    if i.i2 == base2.startIndex {
      return Index(
        i1: base1.index(before: i.i1),
        i2: base2.index(before: base2.endIndex))
    } else {
      return Index(i1: i.i1, i2: base2.index(before: i.i2))
    }
  }
}

extension Product2Sequence: RandomAccessCollection
  where Base1: RandomAccessCollection, Base2: RandomAccessCollection {}

extension Product2Sequence.Index: Hashable
  where Base1.Index: Hashable, Base2.Index: Hashable {}

//===----------------------------------------------------------------------===//
// product(_:_:)
//===----------------------------------------------------------------------===//

/// Creates a sequence of each pair of elements of two underlying sequences.
///
/// Use this function to iterate over every pair of elements in two different
/// collections. The returned sequence yields 2-element tuples, where the first
/// element of the tuple is from the first collection and the second element is
/// from the second collection.
///
///
///     let numbers = 1...3
///     let colors = ["cerise", "puce", "heliotrope"]
///     for (number, color) in product(numbers, colors) {
///         print("\(number): \(color)")
///     }
///     // 1: cerise
///     // 1: puce
///     // 1: heliotrope
///     // 2: cerise
///     // 2: puce
///     // 2: heliotrope
///     // 3: cerise
///     // 3: puce
///     // 3: heliotrope
///
/// The order of tuples in the returned sequence is consistent. The first
/// element of the first collection is paired with each element of the second
/// collection, then the second element of the first collection is paired with
/// each element of the second collection, and so on.
///
/// - Parameters:
///   - s1: The first sequence to iterate over.
///   - s2: The second sequence to iterate over.
///
/// - Complexity: O(1)
@inlinable
public func product<Base1: Sequence, Base2: Collection>(
  _ s1: Base1, _ s2: Base2
) -> Product2Sequence<Base1, Base2> {
  Product2Sequence(s1, s2)
}
