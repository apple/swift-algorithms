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
public struct Scan<Result, Base: Sequence> {
  let base: Base
  let initial: Result
  let transform: (Result, Base.Element) -> Result
}

extension Scan: Sequence {
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

extension Sequence {

  /// Returns a sequence containing the results of combining the elements of
  /// the sequence using the given transform.
  ///
  /// This can be seen as applying the reduce function to each element and
  /// providing these results as a sequence.
  ///
  /// ```
  /// let values = [1, 2, 3, 4]
  /// let sequence = values.scan(0, +)
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
  public func scan<Result>(
    _ initial: Result,
    _ transform: @escaping (Result, Element) -> Result
  ) -> Scan<Result, Self> {
    Scan(base: self, initial: initial, transform: transform)
  }
}
