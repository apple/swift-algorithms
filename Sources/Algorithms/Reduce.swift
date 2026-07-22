//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift Algorithms open source project
//
// Copyright (c) 2026 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

extension Sequence {
  /// Returns the result of combining the elements of the sequence using the
  /// given closure, or `nil` if the sequence has no elements.
  ///
  /// Use this method when the elements themselves are the values being
  /// combined and there is no natural initial result. The first element of
  /// the sequence is used as the initial result, and the closure combines
  /// the running result with each subsequent element:
  ///
  /// ```swift
  /// let numbers = [1, 2, 3, 4]
  /// let sum = numbers.reduce(+)
  /// // sum == 10
  ///
  /// let none = EmptyCollection<Int>().reduce(+)
  /// // none == nil
  /// ```
  ///
  /// This method is the single-value counterpart of `reductions(_:)`, which
  /// additionally returns all of the intermediate results.
  ///
  /// - Parameter nextPartialResult: A closure that combines an accumulating
  ///   result and an element of the sequence into a new accumulating result.
  /// - Returns: The final accumulated result, or `nil` if the sequence is
  ///   empty.
  ///
  /// - Complexity: O(*n*), where *n* is the length of the sequence.
  @inlinable
  public func reduce(
    _ nextPartialResult: (Element, Element) throws -> Element
  ) rethrows -> Element? {
    var iterator = makeIterator()
    guard var result = iterator.next() else { return nil }
    while let element = iterator.next() {
      result = try nextPartialResult(result, element)
    }
    return result
  }
}
