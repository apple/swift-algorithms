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
  /// results returned by the given `keyForValue` closure. As the dictionary is
  /// built, the initializer calls the `combine` closure with the current and
  /// new values for any duplicate keys. Pass a closure as `combine` that
  /// returns the value to use in the resulting dictionary: The closure can
  /// choose between the two values, combine them to produce a new value, or
  /// even throw an error.
  ///
  /// If no `combine` closure is provided, deriving the same duplicate key for
  /// more than one element of self results in a runtime error.
  ///
  /// - Parameters:
  ///   - keyForValue: A closure that returns a key for each element in
  ///     `self`.
  ///   - combine: A closure that is called with the values for any duplicate
  ///     keys that are encountered. The closure returns the desired value for
  ///     the final dictionary.
  @inlinable
  public func keyed<Key>(
    by keyForValue: (Element) throws -> Key,
    uniquingKeysWith combine: ((Key, Element, Element) throws -> Element)? = nil
  ) rethrows -> [Key: Element] {
    var result = [Key: Element]()

    if combine != nil {
      // We have a `combine` closure. Use it to resolve duplicate keys.

      for element in self {
        let key = try keyForValue(element)
        
        if let oldValue = result.updateValue(element, forKey: key) {
          // Can't use a conditional binding to unwrap this, because the newly bound variable
          // doesn't play nice with the `rethrows` system.
          let valueToKeep = try combine!(key, oldValue, element)
          
          // This causes a second look-up for the same key. The standard library can avoid that
          // by calling `mutatingFind` to get access to the bucket where the value will end up,
          // and updating in place.
          // Swift Algorithms doesn't have access to that API, so we make due.
          // When this gets merged into the standard library, we should optimize this.
          result[key] = valueToKeep
        }
      }
    } else {
      // There's no `combine` closure. Duplicate keys are disallowed.

      for element in self {
        let key = try keyForValue(element)

        guard result.updateValue(element, forKey: key) == nil else {
          fatalError("Duplicate values for key: '\(key)'")
        }
      }
    }

    return result
  }
}
