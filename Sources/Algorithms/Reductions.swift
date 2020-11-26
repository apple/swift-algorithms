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
  public struct Index: Comparable {
    let index: Base.Index
    let result: Result

    public static func < (lhs: Index, rhs: Index) -> Bool {
        lhs.index < rhs.index
    }

    public static func == (lhs: Index, rhs: Index) -> Bool {
        lhs.index == rhs.index
    }
  }

  public var startIndex: Index {
    let start = base.startIndex
    let result = transform(initial, base[start])
    return Index(index: start, result: result)
  }

  public var endIndex: Index {
    let end = base.endIndex
    let result = base.reduce(initial, transform)
    return Index(index: end, result: result)
  }

  public subscript(position: Index) -> Result {
    position.result
  }

  public func index(after i: Index) -> Index {
    let index = base.index(after: i.index)
    let result = transform(i.result, base[i.index])
    return Index(index: index, result: result)
  }

  public func distance(from start: Index, to end: Index) -> Int {
    base.distance(from: start.index, to: end.index)
  }
}

extension Collection {
  public func reductions(
    _ transform: (Element, Element) throws -> Element
  ) rethrows -> [Element] {

    guard let first = first else { return [] }
    return try dropFirst().reductions(including: first, transform)
  }
}

extension Sequence {

  public func reductions<Result>(
    including initial: Result,
    _ transform: (Result, Element) throws -> Result
  ) rethrows -> [Result] {

    var output = [Result]()
    output.reserveCapacity(underestimatedCount + 1)
    output.append(initial)

    var result = initial
    for element in self {
      result = try transform(result, element)
      output.append(result)
    }

    return output
  }

  public func reductions<Result>(
    excluding initial: Result,
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
