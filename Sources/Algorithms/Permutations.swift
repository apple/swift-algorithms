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

/// A sequence of all the permutations of a collection's elements.
public struct Permutations<Base: Collection> {
  /// The base collection.
  public let base: Base
  
  internal let baseCount: Int
  internal let countToChoose: Int
  
  internal init(_ base: Base, k: Int? = nil) {
    self.base = base
    let baseCount = base.count
    self.baseCount = baseCount
    self.countToChoose = k ?? baseCount
  }
  
  public var count: Int {
    return baseCount >= countToChoose
      ? stride(from: baseCount, to: baseCount - countToChoose, by: -1).reduce(1, *)
      : 0
  }
}
 
extension Permutations: Sequence {
  public struct Iterator: IteratorProtocol {
    @usableFromInline
    internal var base: Base
    @usableFromInline
    internal var indexes: [Base.Index]
    @usableFromInline
    internal var hasMorePermutations: Bool
    @usableFromInline
    internal var countToChoose: Int = 0
        
    /// `true` if we're generating permutations of the full collection.
    @usableFromInline
    internal var permutesFullCollection: Bool {
      countToChoose == indexes.count
    }
    
    @usableFromInline
    internal init(_ base: Base) {
      self.base = base
      self.indexes = Array(base.indices)
      self.countToChoose = self.indexes.count
      self.hasMorePermutations = true
    }
    
    @usableFromInline
    internal init(_ base: Base, count: Int) {
      self.base = base
      self.countToChoose = count
      
      // Produce exactly one empty permutation when `count == 0`.
      self.indexes = count == 0 ? [] : Array(base.indices)

      // Can't produce any permutations when `count > base.count`.
      self.hasMorePermutations = count <= indexes.count
    }
    
    /// Advances the `indexes` array such that the first `countToChoose`
    /// elements contain the next lexicographic ordering of elements.
    ///
    /// Uses the SEP(n,k) algorithm, as described in:
    /// https://alistairisrael.wordpress.com/2009/09/22/simple-efficient-pnk-algorithm/
    ///
    /// - Returns: A Boolean value indicating whether `indexes` still has
    ///   remaining permutations. When this method returns `false`, `indexes`
    ///   is in ascending order.
    ///
    /// - Complexity: O(*n*), where *n* is the length of the collection.
    @usableFromInline
    internal mutating func nextState() -> Bool {
      let edge = countToChoose - 1

      // Find first index greater than the one at `edge`.
      if let i = indexes[countToChoose...].firstIndex(where: { indexes[edge] < $0 }) {
        indexes.swapAt(edge, i)
      } else {
        indexes.reverse(subrange: countToChoose..<indexes.endIndex)

        // Find last increasing pair below `edge`.
        // TODO: This could be indexes[..<edge].adjacentPairs().lastIndex(where: ...)
        var lastAscent = edge - 1
        while (lastAscent >= 0 && indexes[lastAscent] >= indexes[lastAscent + 1]) {
          lastAscent -= 1
        }
        if (lastAscent < 0) {
          return false
        }

        // Find rightmost index less than that at `lastAscent`.
        if let i = indexes[lastAscent...].lastIndex(where: { indexes[lastAscent] < $0 }) {
          indexes.swapAt(lastAscent, i)
        }
        indexes.reverse(subrange: (lastAscent + 1)..<indexes.endIndex)
      }
      
      return true
    }
    
    @inlinable
    public mutating func next() -> [Base.Element]? {
      if !hasMorePermutations { return nil }
      
      if permutesFullCollection {
        // If we're permuting the full collection, each iteration is just a
        // call to `nextPermutation` on `indexes`.
        defer { hasMorePermutations = indexes.nextPermutation() }
        return indexes.map { base[$0] }
      } else {
        // Otherwise, return the items at the first `countToChoose` indices and
        // advance the state.
        defer { hasMorePermutations = nextState() }
        return indexes.prefix(countToChoose).map { base[$0] }
      }
    }
  }
  
  @usableFromInline
  internal var permutesFullCollection: Bool {
    baseCount == countToChoose
  }

  public func makeIterator() -> Iterator {
    permutesFullCollection
      ? Iterator(base)
      : Iterator(base, count: countToChoose)
  }
}

extension Permutations: LazySequenceProtocol where Base: LazySequenceProtocol {}

//===----------------------------------------------------------------------===//
// nextPermutation(by:)
//===----------------------------------------------------------------------===//

extension MutableCollection
  where Self: BidirectionalCollection, Element: Comparable
{
  /// Permutes this collection's elements through all the lexical orderings.
  ///
  /// Call `nextPermutation()` repeatedly starting with the collection in
  /// sorted order. When the full cycle of all permutations has been completed,
  /// the collection will be back in sorted order and this method will return
  /// `false`.
  ///
  /// - Returns: A Boolean value indicating whether the collection still has
  ///   remaining permutations. When this method returns `false`, the collection
  ///   is in ascending order according to `areInIncreasingOrder`.
  ///
  /// - Complexity: O(*n*), where *n* is the length of the collection.
  @usableFromInline
  internal mutating func nextPermutation() -> Bool {
    // ensure we have > 1 element in the collection
    if isEmpty { return false }
    var i = index(before: endIndex)
    if i == startIndex { return false }
    
    while true {
      let ip1 = i
      formIndex(before: &i)
      
      if self[i] < self[ip1] {
        var j = index(before: endIndex)
        while self[i] >= self[j] {
          formIndex(before: &j)
        }
        swapAt(i, j)
        self.reverse(subrange: ip1..<endIndex)
        return true
      }
      
      if i == startIndex {
        self.reverse()
        return false
      }
    }
  }
}

//===----------------------------------------------------------------------===//
// permutations(ofCount:)
//===----------------------------------------------------------------------===//

extension Collection {
  /// Returns a collection of the permutations of this collection of the
  /// specified length.
  ///
  /// This example prints the different permutations of two elements from an
  /// array of three names:
  ///
  ///     let names = ["Alex", "Celeste", "Davide"]
  ///     for perm in names.permutations(ofCount: 2) {
  ///         print(perm.joined(separator: ", "))
  ///     }
  ///     // Alex, Celeste
  ///     // Alex, Davide
  ///     // Celeste, Alex
  ///     // Celeste, Davide
  ///     // Davide, Alex
  ///     // Davide, Celeste
  ///
  /// The permutations present the elements in increasing lexicographic order
  /// of the collection's original ordering (rather than the order of the
  /// elements themselves). The first permutation will always consist of
  /// elements in their original order, and the last will have the elements in
  /// the reverse of their original order.
  ///
  /// Values that are repeated in the original collection are always treated as
  /// separate values in the resulting permutations:
  ///
  ///     let numbers = [20, 10, 10]
  ///     for perm in numbers.permutations() {
  ///         print(perm)
  ///     }
  ///     // [20, 10, 10]
  ///     // [20, 10, 10]
  ///     // [10, 20, 10]
  ///     // [10, 10, 20]
  ///     // [10, 20, 10]
  ///     // [10, 10, 20]
  ///
  /// If `k` is zero, the resulting sequence has exactly one element, an
  /// empty array. If `k` is greater than the number of elements in this
  /// sequence, the resulting sequence has no elements.
  ///
  /// - Parameter k: The number of elements to include in each permutation.
  ///   If `count` is `nil`, the resulting sequence represents permutations
  ///   of this entire collection.
  ///
  /// - Complexity: O(1)
  public func permutations(ofCount k: Int? = nil) -> Permutations<Self> {
    assert(
      k ?? 0 >= 0,
      "Can't have permutations with a negative number of elements.")
    return Permutations(self, k: k)
  }
}
