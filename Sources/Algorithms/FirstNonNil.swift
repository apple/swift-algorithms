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
// firstNonNil(_:)
//===----------------------------------------------------------------------===//

extension Sequence {
  /// Returns the first non-`nil` result obtained from applying the given
  /// transformation to the elements of the sequence.
  ///
  ///     let strings = ["three", "3.14", "-5", "2"]
  ///     if let firstInt = strings.firstNonNil({ Int($0) }) {
  ///         print(firstInt)
  ///         // -5
  ///     }
  ///
  /// - Parameter transform: A closure that takes an element of the sequence as
  ///   its argument and returns an optional transformed value.
  /// - Returns: The first non-`nil` return value of the transformation, or
  ///   `nil` if no transformation is successful.
  ///
  /// - Complexity: O(*n*), where *n* is the number of elements at the start of
  ///   the sequence that result in `nil` when applying the transformation.
  @inlinable
  public func firstNonNil<Result>(
    _ transform: (Element) throws -> Result?
  ) rethrows -> Result? {
    for value in self {
      if let value = try transform(value) {
        return value
      }
    }
    return nil
  }
}
