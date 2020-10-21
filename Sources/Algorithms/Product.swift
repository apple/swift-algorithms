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

/// A sequence that represents the product of two sequence's elements.
public struct Product2<Base1: Sequence, Base2: Collection> {
  /// The outer sequence in the product.
  public let base1: Base1
  /// The inner sequence in the product.
  public let base2: Base2
  
  internal init(_ base1: Base1, _ base2: Base2) {
    self.base1 = base1
    self.base2 = base2
  }
}

extension Product2: Sequence {
  /// The iterator for a `Product2` sequence.
  public struct Iterator: IteratorProtocol {
    @usableFromInline
    internal var i1: Base1.Iterator
    @usableFromInline
    internal var i2: Base2.Iterator
    @usableFromInline
    internal var element1: Base1.Element?
    @usableFromInline
    internal let base2: Base2

    @usableFromInline
    internal init(_ c: Product2) {
      self.base2 = c.base2
      self.i1 = c.base1.makeIterator()
      self.i2 = c.base2.makeIterator()
      self.element1 = nil
    }
    
    @inlinable
    public mutating func next() -> (Base1.Element, Base2.Element)? {
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

  public func makeIterator() -> Iterator {
    return Iterator(self)
  }
}

extension Product2: Collection where Base1: Collection {
  /// The index type for a `Product2` collection.
  public struct Index: Comparable {
    @usableFromInline
    internal var i1: Base1.Index
    @usableFromInline
    internal var i2: Base2.Index
    
    @usableFromInline
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
  public func index(after i: Index) -> Index {
    precondition(i.i1 != base1.endIndex, "Can't advance past endIndex")
    let newIndex2 = base2.index(after: i.i2)
    return newIndex2 == base2.endIndex
      ? Index(i1: base1.index(after: i.i1), i2: base2.startIndex)
      : Index(i1: i.i1, i2: newIndex2)
  }
  
  // TODO: Implement index(_:offsetBy:) and index(_:offsetBy:limitedBy:)
  
  @inlinable
  public func distance(from start: Index, to end: Index) -> Int {
    if start > end {
      return -distance(from: end, to: start)
    }
    if start.i1 == end.i1 {
      return base2[start.i2..<end.i2].count
    }
    
    return base2[start.i2...].count + base2[..<end.i2].count
      + base2.count * (base1.distance(from: start.i1, to: end.i1) - 1)
  }

  @inlinable
  public subscript(position: Index) -> (Base1.Element, Base2.Element) {
    return (base1[position.i1], base2[position.i2])
  }
}

extension Product2: BidirectionalCollection
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

extension Product2: RandomAccessCollection
  where Base1: RandomAccessCollection, Base2: RandomAccessCollection {}

extension Product2.Index: Hashable where Base1.Index: Hashable, Base2.Index: Hashable {}
extension Product2: Equatable where Base1: Equatable, Base2: Equatable {}
extension Product2: Hashable where Base1: Hashable, Base2: Hashable {}

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
public func product<Base1: Sequence, Base2: Collection>(
  _ s1: Base1, _ s2: Base2
) -> Product2<Base1, Base2> {
  return Product2(s1, s2)
}
