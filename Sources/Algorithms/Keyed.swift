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
    // TODO: pass `Key` into `combine`: (Key, Element, Element) throws -> Element
    uniquingKeysWith combine: ((Element, Element) throws -> Element)? = nil
  ) rethrows -> [Key: Element] {
    // Note: This implementation is a bit convoluted, but it's just aiming to reuse the existing stdlib logic,
    // to ensure consistent behaviour, error messages, etc.
    // If this API ends up in the stdlib itself, it could just call the underlying `_NativeDictionary` methods.
    try withoutActuallyEscaping(keyForValue) { keyForValue in
      if let combine {
        return try Dictionary(self.lazy.map { (try keyForValue($0), $0) }, uniquingKeysWith: combine)
      } else {
        return try Dictionary(uniqueKeysWithValues: self.lazy.map { (try keyForValue($0), $0) } )
      }
    }
  }
}
