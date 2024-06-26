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

//===----------------------------------------------------------------------===//
// EndsWith
//===----------------------------------------------------------------------===//

extension BidirectionalCollection where Element: Equatable {


  /// Returns a Boolean value indicating whether the final elements of the
  /// collection are the same as the elements in another collection.
  ///
  /// This example tests whether one countable range ends with the elements
  /// of another countable range.
  ///
  ///     let a = 8...10
  ///     let b = 1...10
  ///
  ///     print(b.ends(with: a))
  ///     // Prints "true"
  ///
  /// Passing a collection with no elements or an empty collection as
  /// `possibleSuffix` always results in `true`.
  ///
  ///     print(b.ends(with: []))
  ///     // Prints "true"
  ///
  /// - Parameter possibleSuffix: A collection to compare to this collection.
  /// - Returns: `true` if the initial elements of the collection are the same as
  ///   the elements of `possibleSuffix`; otherwise, `false`. If
  ///   `possibleSuffix` has no elements, the return value is `true`.
  ///
  /// - Complexity: O(*m*), where *m* is the lesser of the length of the
  ///   collection and the length of `possibleSuffix`.
  @inlinable
  public func ends<PossibleSuffix: BidirectionalCollection>(
    with possibleSuffix: PossibleSuffix
  ) -> Bool where PossibleSuffix.Element == Element {
    return self.ends(with: possibleSuffix, by: ==)
  }
}

extension BidirectionalCollection {
  /// Returns a Boolean value indicating whether the final elements of the
  /// collection are equivalent to the elements in another collection, using
  /// the given predicate as the equivalence test.
  ///
  /// The predicate must be an *equivalence relation* over the elements. That
  /// is, for any elements `a`, `b`, and `c`, the following conditions must
  /// hold:
  ///
  /// - `areEquivalent(a, a)` is always `true`. (Reflexivity)
  /// - `areEquivalent(a, b)` implies `areEquivalent(b, a)`. (Symmetry)
  /// - If `areEquivalent(a, b)` and `areEquivalent(b, c)` are both `true`, then
  ///   `areEquivalent(a, c)` is also `true`. (Transitivity)
  ///
  /// - Parameters:
  ///   - possibleSuffix: A collection to compare to this collection.
  ///   - areEquivalent: A predicate that returns `true` if its two arguments
  ///     are equivalent; otherwise, `false`.
  /// - Returns: `true` if the initial elements of the collection are equivalent
  ///   to the elements of `possibleSuffix`; otherwise, `false`. If
  ///   `possibleSuffix` has no elements, the return value is `true`.
  ///
  /// - Complexity: O(*m*), where *m* is the lesser of the length of the
  ///   collection and the length of `possibleSuffix`.
  @inlinable
  public func ends<PossibleSuffix: BidirectionalCollection>(
    with possibleSuffix: PossibleSuffix,
    by areEquivalent: (Element, PossibleSuffix.Element) throws -> Bool
  ) rethrows -> Bool {
    try self.reversed().starts(with: possibleSuffix.reversed(), by: areEquivalent)
  }
}

