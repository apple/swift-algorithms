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
// nextPermutation()
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
  @inlinable
  internal mutating func nextPermutation() -> Bool {
    // Ensure we have > 1 element in the collection.
    guard !isEmpty else { return false }
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
        self.reverse(subrange: ip1 ..< endIndex)
        
        // check here if i < the prefix, if so, return true, if not, continue
        return true
      }
      
      if i == startIndex {
        self.reverse()
        return false
      }
    }
  }

  @inlinable
  internal mutating func nextPermutation(upperBound: Index) -> Bool {
    // Ensure we have > 1 element in the collection.
    guard !isEmpty else { return false }
    var i = index(before: endIndex)
    if i == startIndex { return false }
    
    while true {
      let ip1 = i
      formIndex(before: &i)
      
      // Find the last ascending pair (ie. ..., a, b, ... where a < b)
      if self[i] < self[ip1] {
        // Find the last element greater than self[i]
        // This is _always_ at most `ip1` due to if statement above
        let j = lastIndex(where: { $0 > self[i] })!
        
        // At this point we have something like this:
        //    0, 1, 4, 3, 2
        //       ^        ^
        //       i        j
        swapAt(i, j)
        self.reverse(subrange: ip1 ..< endIndex)
        
        // Only return if we've made a change within ..<upperBound region
        if i < upperBound {
          return true
        } else {
          i = index(before: endIndex)
          continue
        }
      }
      
      if i == startIndex {
        self.reverse()
        return false
      }
    }
  }
}

//===----------------------------------------------------------------------===//
// struct Permutations<Base>
//===----------------------------------------------------------------------===//

/// A sequence of all the permutations of a collection's elements.
public struct Permutations<Base: Collection> {
  /// The base collection to iterate over for permutations.
  public let base: Base
  
  @usableFromInline
  internal let baseCount: Int
  
  /// The range of accepted sizes of permutations.
  /// - Note: This may be empty if the attempted range entirely exceeds the
  /// bounds of the size of the `base` collection.
  @usableFromInline
  internal let kRange: Range<Int>
  
  /// Initializes a `Permutations` for all permutations of `base` of size `k`.
  /// - Parameters:
  ///   - base: The collection to iterate over for permutations
  ///   - k: The expected size of each permutation, or `nil` (default) to
  ///   iterate over all permutations of the same size as the base collection.
  @usableFromInline
  internal init(_ base: Base, k: Int? = nil) {
    let kRange: ClosedRange<Int>?
    if let countToChoose = k {
      kRange = countToChoose ... countToChoose
    } else {
      kRange = nil
    }
    self.init(base, kRange: kRange)
  }
  
  /// Initializes a `Permutations` for all combinations of `base` of sizes
  /// within a given range.
  /// - Parameters:
  ///   - base: The collection to iterate over for permutations.
  ///   - kRange: The range of accepted sizes of permutations, or `nil` to
  ///   iterate over all permutations of the same size as the base collection.
  @usableFromInline
  internal init<R: RangeExpression>(
    _ base: Base, kRange: R?
  ) where R.Bound == Int {
    self.base = base
    let baseCount = base.count
    self.baseCount = baseCount
    let upperBound = baseCount + 1
    self.kRange = kRange?.relative(to: 0 ..< .max)
      .clamped(to: 0 ..< upperBound) ??
      baseCount ..< upperBound
  }
  
  /// The total number of permutations.
  @inlinable
  public var count: Int {
    return kRange.map {
      stride(from: baseCount, to: baseCount - $0, by: -1).reduce(1, *)
    }.reduce(0, +)
  }
}

extension Permutations: Sequence {
  /// The iterator for a `Permutations` instance.
  public struct Iterator: IteratorProtocol {
    @usableFromInline
    internal var base: Base
    
    @usableFromInline
    internal let baseCount: Int
    
    /// The current range of accepted sizes of permutations.
    /// - Note: The range is contracted until empty while iterating over
    /// permutations of different sizes. When the range is empty, iteration is
    /// finished.
    @usableFromInline
    internal var kRange: Range<Int>
    
    /// Whether or not iteration is finished (`kRange` is empty)
    @usableFromInline
    internal var isFinished: Bool {
      return kRange.isEmpty
    }
    
    @usableFromInline
    internal var indexes: [Base.Index]
    
    @usableFromInline
    internal init(_ permutations: Permutations) {
      self.base = permutations.base
      self.baseCount = permutations.baseCount
      self.kRange = permutations.kRange
      self.indexes = Array(permutations.base.indices)
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
      let countToChoose = self.kRange.lowerBound
      let edge = countToChoose - 1
      
      // Find first index greater than the one at `edge`.
      if let i = indexes[countToChoose...].firstIndex(where: { indexes[edge] < $0 }) {
        indexes.swapAt(edge, i)
      } else {
        indexes.reverse(subrange: countToChoose ..< indexes.endIndex)
        
        // Find last increasing pair below `edge`.
        // TODO: This could be indexes[..<edge].adjacentPairs().lastIndex(where: ...)
        var lastAscent = edge - 1
        while (lastAscent >= 0 && indexes[lastAscent] >= indexes[lastAscent + 1]) {
          lastAscent -= 1
        }
        if lastAscent < 0 {
          return false
        }
        
        // Find rightmost index less than that at `lastAscent`.
        if let i = indexes[lastAscent...].lastIndex(where: { indexes[lastAscent] < $0 }) {
          indexes.swapAt(lastAscent, i)
        }
        indexes.reverse(subrange: (lastAscent + 1) ..< indexes.endIndex)
      }
      
      return true
    }
    
    @inlinable
    public mutating func next() -> [Base.Element]? {
      guard !isFinished else { return nil }
      
      /// Advances `kRange` by incrementing its `lowerBound` until the range is
      /// empty, when iteration is finished.
      func advanceKRange() {
        kRange.removeFirst()
        indexes = Array(base.indices)
      }
      
      let countToChoose = self.kRange.lowerBound
      if countToChoose == 0 {
        defer {
          advanceKRange()
        }
        return []
      }
      
      let permutesFullCollection = (countToChoose == baseCount)
      if permutesFullCollection {
        // If we're permuting the full collection, each iteration is just a
        // call to `nextPermutation` on `indexes`.
        defer {
          let hasMorePermutations = indexes.nextPermutation()
          if !hasMorePermutations {
            advanceKRange()
          }
        }
        return indexes.map { base[$0] }
      } else {
        // Otherwise, return the items at the first `countToChoose` indices and
        // advance the state.
        defer {
          let hasMorePermutations = nextState()
          if !hasMorePermutations {
            advanceKRange()
          }
        }
        return indexes.prefix(countToChoose).map { base[$0] }
      }
    }
  }
  
  @inlinable
  public func makeIterator() -> Iterator {
    Iterator(self)
  }
}

extension Permutations: LazySequenceProtocol where Base: LazySequenceProtocol {}

//===----------------------------------------------------------------------===//
// permutations(ofCount:)
//===----------------------------------------------------------------------===//

extension Collection {
  /// Returns a collection of the permutations of this collection with lengths
  /// in the specified range.
  ///
  /// This example prints the different permutations of one to two elements from
  /// an array of three names:
  ///
  ///     let names = ["Alex", "Celeste", "Davide"]
  ///     for perm in names.permutations(ofCount: 1...2) {
  ///         print(perm.joined(separator: ", "))
  ///     }
  ///     // Alex
  ///     // Celeste
  ///     // Davide
  ///     // Alex, Celeste
  ///     // Alex, Davide
  ///     // Celeste, Alex
  ///     // Celeste, Davide
  ///     // Davide, Alex
  ///     // Davide, Celeste
  ///
  /// This example prints _all_ the permutations (including an empty array) from
  /// the an array of numbers:
  ///
  ///     let numbers = [10, 20, 30]
  ///    for perm in numbers.permutations(ofCount: 0...) {
  ///        print(perm)
  ///    }
  ///    // []
  ///    // [10]
  ///    // [20]
  ///    // [30]
  ///    // [10, 20]
  ///    // [10, 30]
  ///    // [20, 10]
  ///    // [20, 30]
  ///    // [30, 10]
  ///    // [30, 20]
  ///    // [10, 20, 30]
  ///    // [10, 30, 20]
  ///    // [20, 10, 30]
  ///    // [20, 30, 10]
  ///    // [30, 10, 20]
  ///    // [30, 20, 10]
  ///
  /// - Parameter kRange: The number of elements to include in each permutation.
  ///
  /// - Complexity: O(1) for random-access base collections. O(*n*) where *n*
  /// is the number of elements in the base collection, since `Permutations`
  /// accesses the `count` of the base collection.
  @inlinable
  public func permutations<R: RangeExpression>(
    ofCount kRange: R
  ) -> Permutations<Self> where R.Bound == Int {
    return Permutations(self, kRange: kRange)
  }
  
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
  ///   If `k` is `nil`, the resulting sequence represents permutations of this
  ///   entire collection.
  ///
  /// - Complexity: O(1) for random-access base collections. O(*n*) where *n*
  /// is the number of elements in the base collection, since `Permutations`
  /// accesses the `count` of the base collection.
  @inlinable
  public func permutations(ofCount k: Int? = nil) -> Permutations<Self> {
    precondition(
      k ?? 0 >= 0,
      "Can't have permutations with a negative number of elements.")
    return Permutations(self, k: k)
  }
}

//===----------------------------------------------------------------------===//
// uniquePermutations()
//===----------------------------------------------------------------------===//

public struct UniquePermutations<Element: Comparable> {
  @usableFromInline
  internal let elements: [Element]
  
  @usableFromInline
  internal let kRange: Range<Int>

  @inlinable
  internal init<S: Sequence>(_ elements: S) where S.Element == Element {
    self.init(elements, 0..<Int.max)
  }

  @inlinable
  internal init<S: Sequence, R: RangeExpression>(_ elements: S, _ range: R)
    where S.Element == Element, R.Bound == Int
  {
    self.elements = elements.sorted()
    
    let upperBound = self.elements.count + 1
    self.kRange = range.relative(to: 0 ..< .max)
      .clamped(to: 0 ..< upperBound)
  }
}

extension UniquePermutations: Sequence {
  public struct Iterator: IteratorProtocol {
    @usableFromInline
    var elements: [Element]
    
    @usableFromInline
    enum State {
      case start, middle, end
    }
    
    @usableFromInline
    var state = State.start
    
    @usableFromInline
    var lengths: Range<Int>
    
    @inlinable
    init(_ elements: [Element], lengths: Range<Int>) {
      self.elements = elements
      self.lengths = lengths
    }
    
    @inlinable
    public mutating func next() -> ArraySlice<Element>? {
      switch state {
      case .start:
        state = .middle
        return elements[..<lengths.lowerBound]
      case .middle:
        if !elements.nextPermutation(upperBound: lengths.lowerBound) {
          lengths = (lengths.lowerBound + 1)..<lengths.upperBound

          if lengths.isEmpty {
            state = .end
            return nil
          }

          elements.sort()
          state = .start
        }
        return elements[..<lengths.lowerBound]
        
      case .end:
        return nil
      }
    }
  }
  
  @inlinable
  public func makeIterator() -> Iterator {
    Iterator(elements, lengths: kRange)
  }
}

extension Sequence where Element: Comparable {
  /// Returns a sequence of the unique permutations of this sequence.
  ///
  /// Use this method to iterate over the unique permutations of a sequence
  /// with repeating elements. This example prints every permutation of an
  /// array of numbers:
  ///
  ///     let numbers = [1, 2, 2]
  ///     for perm in numbers.uniquePermutations() {
  ///         print(perm)
  ///     }
  ///     // [1, 2, 2]
  ///     // [2, 1, 2]
  ///     // [2, 2, 1]
  ///
  /// By contrast, the unadorned `permutations()` method permutes over a
  /// collection by position, which includes permutations with equal elements
  /// in each permutation:
  ///
  ///     for perm in numbers.permutations()
  ///         print(perm)
  ///     }
  ///     // [1, 2, 2]
  ///     // [1, 2, 2]
  ///     // [2, 1, 2]
  ///     // [2, 2, 1]
  ///     // [2, 1, 2]
  ///     // [2, 2, 1]
  ///
  /// The returned permutations are in lexicographically sorted order.
  public func uniquePermutations() -> UniquePermutations<Element> {
    UniquePermutations(self)
  }

  public func uniquePermutations(ofCount k: Int) -> UniquePermutations<Element> {
    UniquePermutations(self, k ..< (k + 1))
  }

  public func uniquePermutations<R: RangeExpression>(ofCount kRange: R) -> UniquePermutations<Element>
    where R.Bound == Int
  {
    UniquePermutations(self, kRange)
  }
}
