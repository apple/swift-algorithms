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

/// A sequence of applying a transform to the element of a sequence and the
/// previously transformed result.
public struct Reductions<Result, Base: Sequence> {
  let base: Base
  let initial: Result
  let transform: (Result, Base.Element) -> Result
}

extension Reductions: Sequence {
  public struct Iterator: IteratorProtocol {
    var iterator: Base.Iterator
    var current: Result
    let transform: (Result, Base.Element) -> Result

    public mutating func next() -> Result? {
      guard let element = iterator.next() else { return nil }
      current = transform(current, element)
      return current
    }
  }

  public func makeIterator() -> Iterator {
    Iterator(iterator: base.makeIterator(),
             current: initial,
             transform: transform)
  }
}

extension Reductions: Collection where Base: Collection {
  public var startIndex: Base.Index {
    base.startIndex
  }

  public var endIndex: Base.Index {
    base.endIndex
  }

  public subscript(position: Base.Index) -> Result {
    base[...position].reduce(initial, transform)
  }

  public func index(after i: Base.Index) -> Base.Index {
    base.index(after: i)
  }

  public func index(_ i: Base.Index, offsetBy distance: Int) -> Base.Index {
    base.index(i, offsetBy: distance)
  }

  public func index(_ i: Base.Index, offsetBy distance: Int, limitedBy limit: Base.Index) -> Base.Index? {
    base.index(i, offsetBy: distance, limitedBy: limit)
  }

  public func distance(from start: Base.Index, to end: Base.Index) -> Int {
    base.distance(from: start, to: end)
  }
}

extension Reductions: BidirectionalCollection where Base: BidirectionalCollection {
  public func index(before i: Base.Index) -> Base.Index {
    base.index(before: i)
  }
}

extension Sequence {

  public func reductions<Result>(
    _ initial: Result,
    _ transform: (Result, Element) throws -> Result
  ) rethrows -> [Result] {

    var result = initial
    return try map { element in
      result = try transform(result, element)
      return result
    }
  }
}

extension LazySequenceProtocol {

  /// Returns a sequence containing the results of combining the elements of
  /// the sequence using the given transform.
  ///
  /// This can be seen as applying the reduce function to each element and
  /// providing these results as a sequence.
  ///
  /// ```
  /// let values = [1, 2, 3, 4]
  /// let sequence = values.reductions(0, +)
  /// print(Array(sequence))
  ///
  /// // prints [1, 3, 6, 10]
  /// ```
  ///
  /// - Parameters:
  ///   - initial: The value to use as the initial accumulating value.
  ///   - transform: A closure that combines an accumulating value and
  ///     an element of the sequence.
  /// - Returns: A sequence of transformed elements.
  public func reductions<Result>(
    _ initial: Result,
    _ transform: @escaping (Result, Element) -> Result
  ) -> Reductions<Result, Self> {
    Reductions(base: self, initial: initial, transform: transform)
  }
}
