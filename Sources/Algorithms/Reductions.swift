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

// MARK: - Exclusive Reductions

extension LazySequenceProtocol {

  /// Returns a sequence containing the results of combining the elements of
  /// the sequence using the given transform.
  ///
  /// This can be seen as applying the reduce function to each element and
  /// providing the initial value followed by these results as a sequence.
  ///
  /// ```
  /// let values = [1, 2, 3, 4]
  /// let sequence = values.reductions(0, +)
  /// print(Array(sequence))
  ///
  /// // prints [0, 1, 3, 6, 10]
  /// ```
  ///
  /// - Parameters:
  ///   - initial: The value to use as the initial value.
  ///   - transform: A closure that combines the previously reduced result and
  ///   the next element in the receiving sequence.
  /// - Returns: A sequence of transformed elements.
  public func reductions<Result>(
    _ initial: Result,
    _ transform: @escaping (Result, Element) -> Result
  ) -> ExclusiveReductions<Result, Self> {
    ExclusiveReductions(base: self, initial: initial, transform: transform)
  }
}

extension Sequence {

  public func reductions<Result>(
    _ initial: Result,
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
}

/// A sequence of applying a transform to the element of a sequence and the
/// previously transformed result.
public struct ExclusiveReductions<Result, Base: Sequence> {
  let base: Base
  let initial: Result
  let transform: (Result, Base.Element) -> Result
}

extension ExclusiveReductions: Sequence {
  public struct Iterator: IteratorProtocol {
    var iterator: Base.Iterator
    var current: Result?
    let transform: (Result, Base.Element) -> Result

    public mutating func next() -> Result? {
      guard let result = current else { return nil }
      current = iterator.next().map { transform(result, $0) }
      return result
    }
  }

  public func makeIterator() -> Iterator {
    Iterator(iterator: base.makeIterator(),
             current: initial,
             transform: transform)
  }
}

extension ExclusiveReductions: LazySequenceProtocol
  where Base: LazySequenceProtocol {}

// MARK: - Inclusive Reductions

extension LazySequenceProtocol {

  public func reductions(
    _ transform: @escaping (Element, Element) -> Element
  ) -> InclusiveReductions<Self> {
    InclusiveReductions(base: self, transform: transform)
  }
}

extension Sequence {
  public func reductions(
    _ transform: (Element, Element) throws -> Element
  ) rethrows -> [Element] {
    var iterator = makeIterator()
    guard let initial = iterator.next() else { return [] }
    return try IteratorSequence(iterator).reductions(initial, transform)
  }
}

public struct InclusiveReductions<Base: Sequence> {
  let base: Base
  let transform: (Base.Element, Base.Element) -> Base.Element
}

extension InclusiveReductions: Sequence {
  public struct Iterator: IteratorProtocol {
    var iterator: Base.Iterator
    var element: Base.Element?
    let transform: (Base.Element, Base.Element) -> Base.Element

    public mutating func next() -> Base.Element? {
      guard let previous = element else {
        element = iterator.next()
        return element
      }
      guard let next = iterator.next() else { return nil }
      element = transform(previous, next)
      return element
    }
  }

  public func makeIterator() -> Iterator {
    Iterator(iterator: base.makeIterator(),
             transform: transform)
  }
}

extension InclusiveReductions: LazySequenceProtocol
  where Base: LazySequenceProtocol {}
