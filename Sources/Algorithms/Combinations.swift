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

/// A collection wrapper that generates combinations of a base collection.
public struct Combinations<Base: Collection> {
  /// The collection to iterate over for combinations.
  public let base: Base
  
  /// The range of accepted sizes of combinations.
  /// - Note: This may be `nil` if the attempted range entirely exceeds the
  /// upper bounds of the size of the `base` collection.
  @usableFromInline
  internal let k: Range<Int>?
  
  /// Initializes a `Combinations` for all combinations of `base` of all sizes.
  /// - Parameter base: The collection to iterate over for combinations.
  @usableFromInline
  internal init(_ base: Base) {
    self.init(base, k: 0...)
  }
  
  /// Initializes a `Combinations` for all combinations of `base` of size `k`.
  /// - Parameters:
  ///   - base: The collection to iterate over for combinations.
  ///   - k: The expected size of each combination.
  @usableFromInline
  internal init(_ base: Base, k: Int) {
    self.init(base, k: k...k)
  }
  
  /// Initializes a `Combinations` for all combinations of `base` of sizes
  /// within a given range.
  /// - Parameters:
  ///   - base: The collection to iterate over for combinations.
  ///   - k: The range of accepted sizes of combinations.
  @usableFromInline
  internal init<R: RangeExpression>(
    _ base: Base, k: R
  ) where R.Bound == Int {
    let range = k.relative(to: R.Bound.zero..<R.Bound.max)
    self.base = base
    let upperBound = base.count + 1
    self.k = range.lowerBound < upperBound
      ? range.clamped(to: 0..<upperBound)
      : nil
  }
  
  /// The total number of combinations.
  @inlinable
  public var count: Int {
    guard let k = self.k else { return 0 }
    let n = base.count
    if k == 0..<(n + 1) {
      return 1 << n
    }
    
    func binomial(n: Int, k: Int) -> Int {
      switch k {
      case n, 0: return 1
      case n...: return 0
      case (n / 2 + 1)...: return binomial(n: n, k: n - k)
      default: return n * binomial(n: n - 1, k: k - 1) / k
      }
    }
    
    return k.map {
      binomial(n: n, k: $0)
    }.reduce(0, +)
  }
}

extension Combinations: Sequence {
  /// The iterator for a `Combinations` instance.
  public struct Iterator: IteratorProtocol {
    @usableFromInline
    internal let base: Base
    
    /// The current range of accepted sizes of combinations.
    @usableFromInline
    internal var k: Range<Int>
    
    @usableFromInline
    internal var indexes: [Base.Index]
    
    @usableFromInline
    internal var finished: Bool
    
    internal init(_ combinations: Combinations) {
      self.base = combinations.base
      self.k = combinations.k ?? 0..<1
      self.indexes = Array(combinations.base.indices.prefix(k.lowerBound))
      self.finished = (combinations.k == nil)
    }
    
    /// Advances the current indices to the next set of combinations. If
    /// `indexes.count == 3` and `base.count == 5`, the indices advance like
    /// this:
    ///
    ///     [0, 1, 2]
    ///     [0, 1, 3]
    ///     [0, 1, 4] *
    ///     // * `base.endIndex` reached in `indexes.last`
    ///     // Advance penultimate index and propagate that change
    ///     [0, 2, 3]
    ///     [0, 2, 4] *
    ///     [0, 3, 4] *
    ///     [1, 2, 3]
    ///     [1, 2, 4] *
    ///     [1, 3, 4] *
    ///     [2, 3, 4] *
    ///     // Can't advance without needing to go past `base.endIndex`,
    ///     // so the iteration is finished.
    @usableFromInline
    internal mutating func advance() {
      /// Advances `k` by increasing its `lowerBound` or finishes the iteration.
      func advanceK() {
        let advancedLowerBound = k.lowerBound.advanced(by: 1)
        if advancedLowerBound < k.upperBound {
          k = advancedLowerBound..<k.upperBound
          self.indexes = Array(base.indices.prefix(k.lowerBound))
        } else {
          finished = true
        }
      }
      
      guard !indexes.isEmpty else {
        // Initial state for combinations of 0 elements is an empty array with
        // `finished == false`. Even though no indexes are involved, advancing
        // from that state means we are finished with iterating.
        advanceK()
        return
      }
      
      let i = indexes.count - 1
      base.formIndex(after: &indexes[i])
      if indexes[i] != base.endIndex { return }
      
      var j = i
      while indexes[i] == base.endIndex {
        j -= 1
        guard j >= 0 else {
          // Finished iterating over combinations of this size.
          advanceK()
          return
        }
        
        base.formIndex(after: &indexes[j])
        for k in indexes.indices[(j + 1)...] {
          indexes[k] = base.index(after: indexes[k - 1])
          if indexes[k] == base.endIndex {
            break
          }
        }
      }
    }
    
    @inlinable
    public mutating func next() -> [Base.Element]? {
      if finished { return nil }
      defer { advance() }
      return indexes.map { i in base[i] }
    }
  }
  
  public func makeIterator() -> Iterator {
    Iterator(self)
  }
}

extension Combinations: LazySequenceProtocol where Base: LazySequenceProtocol {}
extension Combinations: Equatable where Base: Equatable {}
extension Combinations: Hashable where Base: Hashable {}

//===----------------------------------------------------------------------===//
// combinations()
//===----------------------------------------------------------------------===//

extension Collection {
  /// Returns a collection of all the combinations of this collection's
  /// elements, including the full collection and an empty collection
  ///
  /// This example prints the all the combinations from an array of letters:
  ///
  ///     let letters = ["A", "B", "C", "D"]
  ///     for combo in letters.combinations() {
  ///         print(combo.joined(separator: ", "))
  ///     }
  ///     //
  ///     // A
  ///     // B
  ///     // C
  ///     // D
  ///     // A, B
  ///     // A, C
  ///     // A, D
  ///     // B, C
  ///     // B, D
  ///     // C, D
  ///     // A, B, C
  ///     // A, B, D
  ///     // A, C, D
  ///     // B, C, D
  ///     // A, B, C, D
  ///
  /// The returned collection presents combinations in a consistent order, where
  /// the indices in each combination are in ascending lexicographical order,
  /// and the size of the combinations are in increasing order.
  /// That is, in the example above, the combinations in order are the elements
  /// at `[]`, `[0]`, `[1]`, `[2]`, `[3]`, `[0, 1]`, `[0, 2]`, `[0, 3]`,
  /// `[1, 2]`, `[1, 3]`, … `[0, 1, 2, 3]`.
  ///
  /// - Complexity: O(1)
  @inlinable
  public func combinations() -> Combinations<Self> {
    return Combinations(self)
  }
}

//===----------------------------------------------------------------------===//
// combinations(ofCounts:)
//===----------------------------------------------------------------------===//

extension Collection {
  /// Returns a collection of combinations of this collection's elements, with
  /// each combination having the specified number of elements.
  ///
  /// This example prints the different combinations of 1 and 2 from an array of
  /// four colors:
  ///
  ///     let colors = ["fuchsia", "cyan", "mauve", "magenta"]
  ///     for combo in colors.combinations(ofCounts: 1...2) {
  ///         print(combo.joined(separator: ", "))
  ///     }
  ///     // fuchsia
  ///     // cyan
  ///     // mauve
  ///     // magenta
  ///     // fuchsia, cyan
  ///     // fuchsia, mauve
  ///     // fuchsia, magenta
  ///     // cyan, mauve
  ///     // cyan, magenta
  ///     // mauve, magenta
  ///
  /// The returned collection presents combinations in a consistent order, where
  /// the indices in each combination are in ascending lexicographical order.
  /// That is, in the example above, the combinations in order are the elements
  /// at `[0]`, `[1]`, `[2]`, `[3]`, `[0, 1]`, `[0, 2]`, `[0, 3]`, `[1, 2]`,
  /// `[1, 3]`, and finally `[2, 3]`.
  ///
  /// If `k` is `0...0`, the resulting sequence has exactly one element, an
  /// empty array. If `k.upperBound` is greater than the number of elements in
  /// this sequence, the resulting sequence has no elements.
  ///
  /// - Parameter k: The range of numbers of elements to include in each
  /// combination.
  ///
  /// - Complexity: O(1)
  @inlinable
  public func combinations<R: RangeExpression>(
    ofCounts k: R
  ) -> Combinations<Self> where R.Bound == Int {
    return Combinations(self, k: k)
  }
}

//===----------------------------------------------------------------------===//
// combinations(ofCount:)
//===----------------------------------------------------------------------===//

extension Collection {
  /// Returns a collection of combinations of this collection's elements, with
  /// each combination having the specified number of elements.
  ///
  /// This example prints the different combinations of three from an array of
  /// four colors:
  ///
  ///     let colors = ["fuchsia", "cyan", "mauve", "magenta"]
  ///     for combo in colors.combinations(ofCount: 3) {
  ///         print(combo.joined(separator: ", "))
  ///     }
  ///     // fuchsia, cyan, mauve
  ///     // fuchsia, cyan, magenta
  ///     // fuchsia, mauve, magenta
  ///     // cyan, mauve, magenta
  ///
  /// The returned collection presents combinations in a consistent order, where
  /// the indices in each combination are in ascending lexicographical order.
  /// That is, in the example above, the combinations in order are the elements
  /// at `[0, 1, 2]`, `[0, 1, 3]`, `[0, 2, 3]`, and finally `[1, 2, 3]`.
  ///
  /// If `k` is zero, the resulting sequence has exactly one element, an empty
  /// array. If `k` is greater than the number of elements in this sequence,
  /// the resulting sequence has no elements.
  ///
  /// - Parameter k: The number of elements to include in each combination.
  ///
  /// - Complexity: O(1)
  @inlinable
  public func combinations(ofCount k: Int) -> Combinations<Self> {
    assert(k >= 0, "Can't have combinations with a negative number of elements.")
    return Combinations(self, k: k)
  }
}
