//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift Algorithms open source project
//
// Copyright (c) 2021 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

extension Sequence {
  /// Returns the number of elements in the sequence that satisfy the given
  /// predicate.
  ///
  /// You can use this method to count the number of elements that pass a test.
  /// For example, this code finds the number of names that are fewer than
  /// five characters long:
  ///
  ///     let names = ["Jacqueline", "Ian", "Amy", "Juan", "Soroush", "Tiffany"]
  ///     let shortNameCount = names.countAll(where: { $0.count < 5 })
  ///     // shortNameCount == 3
  ///
  /// To find the number of times a specific element appears in the sequence,
  /// use the `countAll(_:)` method.
  ///
  ///     let birds = ["duck", "duck", "duck", "duck", "goose"]
  ///     let duckCount = birds.countAll("duck")
  ///     // duckCount == 4
  ///
  /// The sequence must be finite.
  ///
  /// - Parameter predicate: A closure that takes each element of the sequence
  ///   as its argument and returns a Boolean value indicating whether
  ///   the element should be included in the count.
  /// - Returns: The number of elements in the sequence that satisfy
  ///   `predicate`.
  @inlinable
  public func countAll(where predicate: (Element) throws -> Bool) rethrows -> Int {
    try reduce(0) { try $0 + (predicate($1) ? 1 : 0) }
  }
}

extension Sequence where Element: Equatable {
  /// Returns the number of elements in the sequence that are equal to the given
  /// value.
  ///
  /// This example finds the number of times that the string `"duck"` appears
  /// in an array:
  ///
  ///     let birds = ["duck", "duck", "duck", "duck", "goose"]
  ///     let duckCount = birds.countAll("duck")
  ///     // duckCount == 4
  ///
  /// The sequence must be finite.
  ///
  /// - Parameter element: The element to count instances of in this sequence.
  /// - Returns: The number of elements in the sequence that are equal to
  ///   `element`.
  @inlinable
  public func countAll(_ element: Element) -> Int {
    reduce(0) { $0 + ((element == $1) ? 1 : 0) }
  }
}
