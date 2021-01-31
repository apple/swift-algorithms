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
// uniqued()
//===----------------------------------------------------------------------===//

extension Sequence where Element: Hashable {
  /// Returns an array with only the unique elements of this sequence, in the
  /// order of the first occurrence of each unique element.
  ///
  ///     let animals = ["dog", "pig", "cat", "ox", "dog", "cat"]
  ///     let uniqued = animals.uniqued()
  ///     print(uniqued)
  ///     // Prints '["dog", "pig", "cat", "ox"]'
  ///
  /// - Returns: An array with only the unique elements of this sequence.
  ///  .
  /// - Complexity: O(*n*), where *n* is the length of the sequence.
  @inlinable
  public func uniqued() -> [Element] {
    uniqued(on: { $0 })
  }
}

extension Sequence {
  /// Returns an array with the unique elements of this sequence (as determined
  /// by the given projection), in the order of the first occurrence of each
  /// unique element.
  ///
  /// This example finds the elements of the `animals` array with unique
  /// first characters:
  ///
  ///     let animals = ["dog", "pig", "cat", "ox", "cow", "owl"]
  ///     let uniqued = animals.uniqued(on: {$0.first})
  ///     print(uniqued)
  ///     // Prints '["dog", "pig", "cat", "ox"]'
  ///
  /// - Parameter projection: A closure that transforms an element into the
  ///   value to use for uniqueness. If `projection` returns the same value
  ///   for two different elements, the second element will be excluded
  ///   from the resulting array.
  ///
  /// - Returns: An array with only the unique elements of this sequence, as
  ///   determined by the result of `projection` for each element.
  ///
  /// - Complexity: O(*n*), where *n* is the length of the sequence.
  @inlinable
  public func uniqued<Subject: Hashable>(
    on projection: (Element) throws -> Subject
  ) rethrows -> [Element] {
    var seen: Set<Subject> = []
    var result: [Element] = []
    for element in self {
      if seen.insert(try projection(element)).inserted {
        result.append(element)
      }
    }
    return result
  }

  /// Returns an array with the unique elements of this sequence (as determined
  /// by the given key path), in the order of the first occurrence of each
  /// unique element.
  ///
  /// This example finds the elements of the `animals` array with unique
  /// first characters:
  ///
  ///     let animals = ["dog", "pig", "cat", "ox", "cow", "owl"]
  ///     let uniqued = animals.uniqued(on: \.first)
  ///     print(uniqued)
  ///     // Prints '["dog", "pig", "cat", "ox"]'
  ///
  /// - Parameter keyPath: A key path from a specific root type to a specific
  ///   resulting value type.
  ///
  /// - Returns: An array with only the unique elements of this sequence, as
  ///   determined by the key path of each element.
  ///
  /// - Complexity: O(*n*), where *n* is the length of the sequence.
  @inlinable
  public func uniqued<Subject: Hashable>(
    on keyPath: KeyPath<Element, Subject>
  ) -> [Element] {
    var seen: Set<Subject> = []
    var result: [Element] = []
    for element in self {
      let value = element[keyPath: keyPath]
      if seen.insert(value).inserted {
        result.append(element)
      }
    }
    return result
  }
}
