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

extension Sequence {
  /// Creates a new Dictionary from the elements of `self`, keyed by the
  /// results returned by the given `keyForValue` closure.
  ///
  /// If the key derived for a new element collides with an existing key from a previous element,
  /// the latest value will be kept.
  ///
  /// - Parameters:
  ///   - keyForValue: A closure that returns a key for each element in `self`.
  @inlinable
  public func keyed<Key>(
    by keyForValue: (Element) throws -> Key
  ) rethrows -> [Key: Element] {
    return try self.keyed(by: keyForValue, resolvingConflictsWith: { _, old, new in new })
  }

  /// Creates a new Dictionary from the elements of `self`, keyed by the
  /// results returned by the given `keyForValue` closure. As the dictionary is
  /// built, the initializer calls the `resolve` closure with the current and
  /// new values for any duplicate keys. Pass a closure as `resolve` that
  /// returns the value to use in the resulting dictionary: The closure can
  /// choose between the two values, combine them to produce a new value, or
  /// even throw an error.
  ///
  /// - Parameters:
  ///   - keyForValue: A closure that returns a key for each element in `self`.
  ///   - resolve: A closure that is called with the values for any duplicate
  ///     keys that are encountered. The closure returns the desired value for
  ///     the final dictionary.
  @inlinable
  public func keyed<Key>(
    by keyForValue: (Element) throws -> Key,
    resolvingConflictsWith resolve: (Key, Element, Element) throws -> Element
  ) rethrows -> [Key: Element] {
    var result = [Key: Element]()

    for element in self {
      let key = try keyForValue(element)

      if let oldValue = result.updateValue(element, forKey: key) {
        let valueToKeep = try resolve(key, oldValue, element)

        // This causes a second look-up for the same key. The standard library can avoid that
        // by calling `mutatingFind` to get access to the bucket where the value will end up,
        // and updating in place.
        // Swift Algorithms doesn't have access to that API, so we make do.
        // When this gets merged into the standard library, we should optimize this.
        result[key] = valueToKeep
      }
    }

    return result
  }
}
