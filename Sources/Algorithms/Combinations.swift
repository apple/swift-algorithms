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

public struct Combinations<Base: Collection> {
  /// The collection to iterate over for combinations.
  public let base: Base
  
  @usableFromInline
  internal var k: Int
  
  @usableFromInline
  internal init(_ base: Base, k: Int) {
    self.base = base
    self.k = base.count < k ? -1 : k
  }

  @inlinable
  public var count: Int {
    func binomial(n: Int, k: Int) -> Int {
      switch k {
      case n, 0: return 1
      case n...: return 0
      case (n / 2 + 1)...: return binomial(n: n, k: n - k)
      default: return n * binomial(n: n - 1, k: k - 1) / k
      }
    }
    
    return k >= 0
      ? binomial(n: base.count, k: k)
      : 0
  }
}

extension Combinations: Sequence {
  public struct Iterator: IteratorProtocol {
    @usableFromInline
    internal let base: Base
    
    @usableFromInline
    internal var indexes: [Base.Index]
    
    @usableFromInline
    internal var finished: Bool
    
    internal init(_ combinations: Combinations) {
      self.base = combinations.base
      self.finished = combinations.k < 0
      self.indexes = combinations.k < 0
        ? []
        : Array(combinations.base.indices.prefix(combinations.k))
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
      guard !indexes.isEmpty else {
        // Initial state for combinations of 0 elements is an empty array with
        // `finished == false`. Even though no indexes are involved, advancing
        // from that state means we are finished with iterating.
        finished = true
        return
      }
    
      let i = indexes.count - 1
      base.formIndex(after: &indexes[i])
      if indexes[i] != base.endIndex { return }

      var j = i
      while indexes[i] == base.endIndex {
        j -= 1
        guard j >= 0 else {
          // Finished iterating over combinations
          finished = true
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
// combinations(count:)
//===----------------------------------------------------------------------===//

extension Collection {
  /// Returns a collection of combinations of this collection's elements, with
  /// each combination having the specificed number of elements.
  ///
  /// This example prints the different combinations of three from an array of
  /// four colors:
  ///
  ///     let colors = ["fuchsia", "cyan", "mauve", "magenta"]
  ///     for combo in colors.combinations(ofCount k: 3) {
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
