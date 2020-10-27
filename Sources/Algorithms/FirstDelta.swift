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
// firstDelta(against: by:)
//===----------------------------------------------------------------------===//

extension Sequence {
  /// Returns the first non-matching element pair found when comparing this
  /// sequence to the given sequence element-wise, using the given predicate as
  /// the equivalence test.
  ///
  /// The predicate must be a *equivalence relation* over the elements. That
  /// is, for any elements `a`, `b`, and `c`, the following conditions must
  /// hold:
  ///
  /// - `areEquivalent(a, a)` is always `true`. (Reflexivity)
  /// - `areEquivalent(a, b)` implies `areEquivalent(b, a)`. (Symmetry)
  /// - If `areEquivalent(a, b)` and `areEquivalent(b, c)` are both `true`, then
  ///   `areEquivalent(a, c)` is also `true`. (Transitivity)
  ///
  /// If one sequence is a proper prefix of the other, its corresponding member
  /// in the emitted result will be `nil`.  If the two sequences are equivalent,
  /// both members of the emitted result will be `nil`.
  ///
  /// - Parameters:
  ///   - possibleMirror: A sequence to compare to this sequence.
  ///   - areEquivalent: A predicate that returns `true` if its two arguments
  ///     are equivalent; otherwise, `false`.
  /// - Returns: A two-element tuple containing, upon finding the earliest
  ///   diverging elements between this sequence and `possibleMirror`, those
  ///   differing elements.  If at least one of the sequences ends before a
  ///   difference is found, the corresponding member of the returned tuple is
  ///   `nil`.
  ///
  /// - Complexity: O(*m*), where *m* is the lesser of the length of this
  ///   sequence and the length of `possibleMirror`.
  public func firstDelta<PossibleMirror: Sequence>(
    against possibleMirror: PossibleMirror,
    by areEquivalent: (Element, PossibleMirror.Element) throws -> Bool
  ) rethrows -> (Element?, PossibleMirror.Element?) {
    var iterator1 = makeIterator(), iterator2 = possibleMirror.makeIterator()
    while true {
      switch (iterator1.next(), iterator2.next()) {
      case let (element1?, element2?) where try areEquivalent(element1, element2):
        continue
      case let (next1, next2):
        return (next1, next2)
      }
    }
  }
}

//===----------------------------------------------------------------------===//
// firstDelta(against:)
//===----------------------------------------------------------------------===//

extension Sequence where Element: Equatable {
  /// Returns the first non-equal element pair found when comparing this
  /// sequence to the given sequence element-wise.
  ///
  /// If one sequence is a proper prefix of the other, its corresponding member
  /// in the emitted result will be `nil`.  If the two sequences are equal, both
  /// members of the emitted result will be `nil`.
  ///
  /// - Parameters:
  ///   - possibleMirror: A sequence to compare to this sequence.
  /// - Returns: A two-element tuple containing, upon finding the earliest
  ///   diverging elements between this sequence and `possibleMirror`, those
  ///   differing elements.  If at least one of the sequences ends before a
  ///   difference is found, the corresponding member of the returned tuple is
  ///   `nil`.
  ///
  /// - Complexity: O(*m*), where *m* is the lesser of the length of this
  ///   sequence and the length of `possibleMirror`.
  @inlinable
  public func firstDelta<PossibleMirror: Sequence>(
    against possibleMirror: PossibleMirror
  ) -> (Element?, Element?) where PossibleMirror.Element == Element {
    return firstDelta(against: possibleMirror, by: ==)
  }
}

//===----------------------------------------------------------------------===//
// diverges(from: by:)
//===----------------------------------------------------------------------===//

extension Collection {
  /// Finds the longest common prefix between this collection and the given
  /// collection, using the given predicate as the equivalence test, returning
  /// the past-the-end indexes of the respective subsequences.
  ///
  /// The predicate must be a *equivalence relation* over the elements. That
  /// is, for any elements `a`, `b`, and `c`, the following conditions must
  /// hold:
  ///
  /// - `areEquivalent(a, a)` is always `true`. (Reflexivity)
  /// - `areEquivalent(a, b)` implies `areEquivalent(b, a)`. (Symmetry)
  /// - If `areEquivalent(a, b)` and `areEquivalent(b, c)` are both `true`, then
  ///   `areEquivalent(a, c)` is also `true`. (Transitivity)
  ///
  /// If one collection is a proper prefix of the other, its corresponding
  /// member in the emitted result will be its source's `endIndex`.  If the two
  /// collections are equivalent, both members of the emitted result will be
  /// their sources' respective `endIndex`.
  ///
  /// - Parameters:
  ///   - possibleMirror: A collection to compare to this collection.
  ///   - areEquivalent: A predicate that returns `true` if its two arguments
  ///     are equivalent; otherwise, `false`.
  /// - Returns:  A two-element tuple `(x, y)` where *x* and *y* are the largest
  ///   indices such that
  ///   `self[..<x].elementsEqual(possibleMirror[..<y], by: areEquivalent)` is
  ///   `true`.  Either one or both members may be its source's `endIndex`.
  ///
  /// - Complexity: O(*m*), where *m* is the lesser of the length of this
  ///   collection and the length of `possibleMirror`.
  @inlinable
  public func diverges<PossibleMirror: Collection>(
    from possibleMirror: PossibleMirror,
    by areEquivalent: (Element, PossibleMirror.Element) throws -> Bool
  ) rethrows -> (Index, PossibleMirror.Index) {
    let (index1, index2) = try indices.firstDelta(against: possibleMirror.indices) {
      try areEquivalent(self[$0], possibleMirror[$1])
    }
    return (index1 ?? endIndex, index2 ?? possibleMirror.endIndex)
  }
}

//===----------------------------------------------------------------------===//
// diverges(from:)
//===----------------------------------------------------------------------===//

extension Collection where Element: Equatable {
  /// Finds the longest common prefix between this collection and the given
  /// collection, returning the past-the-end indexes of the respective
  /// subsequences.
  ///
  /// If one collection is a proper prefix of the other, its corresponding
  /// member in the emitted result will be its source's `endIndex`.  If the two
  /// collections are equal, both members of the emitted result will be their
  /// sources' respective `endIndex`.
  ///
  /// - Parameters:
  ///   - possibleMirror: A collection to compare to this collection.
  /// - Returns: A two-element tuple containing, upon finding the earliest
  ///   diverging elements between this sequence and `possibleMirror`, those
  ///   differing elements.  If at least one of the sequences ends before a
  ///   difference is found, the corresponding member of the returned tuple is
  ///   `nil`.
  /// - Returns:  A two-element tuple `(x, y)` where *x* and *y* are the largest
  ///   indices such that `self[..<x].elementsEqual(possibleMirror[..<y])` is
  ///   `true`.  Either one or both members may be its source's `endIndex`.
  ///
  /// - Complexity: O(*m*), where *m* is the lesser of the length of this
  ///   collection and the length of `possibleMirror`.
  @inlinable
  public func diverges<PossibleMirror: Collection>(
    from possibleMirror: PossibleMirror
  ) -> (Index, PossibleMirror.Index) where PossibleMirror.Element == Element {
    return diverges(from: possibleMirror, by: ==)
  }
}
