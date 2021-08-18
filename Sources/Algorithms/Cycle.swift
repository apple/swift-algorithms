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

/// A collection wrapper that repeats the elements of a base collection.
public struct CycledSequence<Base: Collection> {
  /// The collection to repeat.
  @usableFromInline
  internal let base: Base
  
  @inlinable
  internal init(base: Base) {
    self.base = base
  }
}

extension CycledSequence: Sequence {
  /// The iterator for a `CycledSequence` instance.
  public struct Iterator: IteratorProtocol {
    @usableFromInline
    internal let base: Base
    
    @usableFromInline
    internal var current: Base.Index
    
    @inlinable
    internal init(base: Base) {
      self.base = base
      self.current = base.startIndex
    }
    
    @inlinable
    public mutating func next() -> Base.Element? {
      guard !base.isEmpty else { return nil }
      
      if current == base.endIndex {
        current = base.startIndex
      }
      
      defer { base.formIndex(after: &current) }
      return base[current]
    }
  }
  
  @inlinable
  public func makeIterator() -> Iterator {
    Iterator(base: base)
  }
}

extension CycledSequence: LazySequenceProtocol
  where Base: LazySequenceProtocol {}

/// A collection wrapper that repeats the elements of a base collection for a
/// finite number of times.
public struct CycledTimesCollection<Base: Collection> {
  /// A `Product2Sequence` instance for iterating the base collection.
  @usableFromInline
  internal let product: Product2Sequence<Range<Int>, Base>

  @inlinable
  internal init(base: Base, times: Int) {
    self.product = Product2Sequence(0..<times, base)
  }
}

extension CycledTimesCollection: Collection {
  public typealias Element = Base.Element

  public struct Index: Comparable {
    /// The index corresponding to the `Product2Sequence` index at this
    /// position.
    @usableFromInline
    internal let productIndex: Product2Sequence<Range<Int>, Base>.Index

    @inlinable
    internal init(_ productIndex: Product2Sequence<Range<Int>, Base>.Index) {
      self.productIndex = productIndex
    }

    @inlinable
    public static func == (lhs: Index, rhs: Index) -> Bool {
      lhs.productIndex == rhs.productIndex
    }

    @inlinable
    public static func < (lhs: Index, rhs: Index) -> Bool {
      lhs.productIndex < rhs.productIndex
    }
  }

  @inlinable
  public var startIndex: Index {
    Index(product.startIndex)
  }

  @inlinable
  public var endIndex: Index {
    Index(product.endIndex)
  }

  @inlinable
  public subscript(_ index: Index) -> Element {
    product[index.productIndex].1
  }

  @inlinable
  public func index(after i: Index) -> Index {
    let productIndex = product.index(after: i.productIndex)
    return Index(productIndex)
  }

  @inlinable
  public func distance(from start: Index, to end: Index) -> Int {
    product.distance(from: start.productIndex, to: end.productIndex)
  }

  @inlinable
  public func index(_ i: Index, offsetBy distance: Int) -> Index {
    let productIndex = product.index(i.productIndex, offsetBy: distance)
    return Index(productIndex)
  }

  @inlinable
  public func index(
    _ i: Index,
    offsetBy distance: Int,
    limitedBy limit: Index
  ) -> Index? {
    guard let productIndex = product.index(
      i.productIndex,
      offsetBy: distance,
      limitedBy: limit.productIndex)
    else { return nil }
    return Index(productIndex)
  }

  @inlinable
  public var count: Int {
    product.count
  }
}

extension CycledTimesCollection: BidirectionalCollection
  where Base: BidirectionalCollection {
  @inlinable
  public func index(before i: Index) -> Index {
    let productIndex = product.index(before: i.productIndex)
    return Index(productIndex)
  }
}

extension CycledTimesCollection: RandomAccessCollection
  where Base: RandomAccessCollection {}

extension CycledTimesCollection: LazySequenceProtocol, LazyCollectionProtocol
  where Base: LazySequenceProtocol {}

//===----------------------------------------------------------------------===//
// cycled()
//===----------------------------------------------------------------------===//

extension Collection {
  /// Returns a sequence that repeats the elements of this collection forever.
  ///
  /// Use the `cycled()` method to repeat the elements of a sequence or
  /// collection forever. You can combine `cycled()` with another, finite
  /// sequence to iterate over the two together.
  ///
  ///     for (evenOrOdd, number) in zip(["even", "odd"].cycled(), 0..<10) {
  ///         print("\(number) is \(evenOrOdd)")
  ///     }
  ///     // 0 is even
  ///     // 1 is odd
  ///     // 2 is even
  ///     // 3 is odd
  ///     // ...
  ///     // 9 is odd
  ///
  /// - Important: When called on a non-empty collection, the resulting sequence
  ///   is infinite. Do not directly call methods that require a finite
  ///   sequence, like `map` or `filter`, without first constraining the length
  ///   of the cycling sequence.
  ///
  /// - Returns: A sequence that repeats the elements of this collection
  ///   forever.
  ///
  /// - Complexity: O(1)
  @inlinable
  public func cycled() -> CycledSequence<Self> {
    CycledSequence(base: self)
  }
  
  /// Returns a sequence that repeats the elements of this collection the
  /// specified number of times.
  ///
  /// Passing `1` as `times` results in this collection's elements being
  /// provided a single time; passing `0` results in an empty sequence. The
  /// `print(_:)` function in this example is never called:
  ///
  ///     for x in [1, 2, 3].cycled(times: 0) {
  ///         print(x)
  ///     }
  ///
  /// - Parameter times: The number of times to repeat this sequence. `times`
  ///   must be zero or greater.
  /// - Returns: A sequence that repeats the elements of this sequence `times`
  ///   times.
  ///
  /// - Complexity: O(1)
  @inlinable
  public func cycled(times: Int) -> CycledTimesCollection<Self> {
    CycledTimesCollection(base: self, times: times)
  }
}
