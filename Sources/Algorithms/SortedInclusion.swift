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

/// The manner two (multi-)sets may overlap, including degenerate cases.
public enum Inclusion: UInt, CaseIterable {
  /// Neither source had any elements.
  case bothUninhabited
  /// Only the first source had any elements.
  case onlyFirstInhabited
  /// Only the second source had any elements.
  case onlySecondInhabited
  /// Each source has its own elements, without any shared.
  case dualExclusivesOnly
  /// Each source has elements, all of them shared.
  case sharedOnly
  /// The second source has elements, but the first has those and some more.
  case firstExtendsSecond
  /// The first source has elements, but the second has those and some more.
  case secondExtendsFirst
  /// Each source has exclusive elements, and there are some shared ones.
  case dualExclusivesAndShared
}

extension Inclusion {
  /// Whether there are elements exclusive to the first source.
  @inlinable public var hasExclusivesToFirst: Bool { rawValue & 0x01 != 0 }
  /// Whether there are elements exclusive to the second source.
  @inlinable public var hasExclusivesToSecond: Bool { rawValue & 0x02 != 0 }
  /// Whether there are elements shared by both sources.
  @inlinable public var hasSharedElements: Bool { rawValue & 0x04 != 0 }

  /// Whether the sources are identical.
  @inlinable public var areIdentical: Bool { rawValue & 0x03 == 0 }
  /// Whether the first source contains everything from the second.
  @inlinable public var doesFirstIncludeSecond: Bool { !hasExclusivesToSecond }
  /// Whether the second source contains everything from the first.
  @inlinable public var doesSecondIncludeFirst: Bool { !hasExclusivesToFirst }
}

//===----------------------------------------------------------------------===//
// sortedOverlap(with: by:)
//===----------------------------------------------------------------------===//

extension Sequence {
  /// Returns how this sequence and the given sequence overlap, assuming both
  /// are sorted according to the given predicate that can compare elements.
  ///
  /// The predicate must be a *strict weak ordering* over the elements. That
  /// is, for any elements `a`, `b`, and `c`, the following conditions must
  /// hold:
  ///
  /// - `areInIncreasingOrder(a, a)` is always `false`. (Irreflexivity)
  /// - If `areInIncreasingOrder(a, b)` and `areInIncreasingOrder(b, c)` are
  ///   both `true`, then `areInIncreasingOrder(a, c)` is also
  ///   `true`. (Transitive comparability)
  /// - Two elements are *incomparable* if neither is ordered before the other
  ///   according to the predicate. If `a` and `b` are incomparable, and `b`
  ///   and `c` are incomparable, then `a` and `c` are also incomparable.
  ///   (Transitive incomparability)
  ///
  /// - Parameters:
  ///   - other: A sequence to compare to this sequence.
  ///   - areInIncreasingOrder:  A predicate that returns `true` if its first
  ///     argument should be ordered before its second argument; otherwise,
  ///     `false`.
  /// - Returns: The degree of inclusion between the sequences.
  ///
  /// - Complexity: O(*m*), where *m* is the lesser of the length of the
  ///   sequence and the length of `other`.
  public func sortedOverlap<S: Sequence>(
    with other: S,
    by areInIncreasingOrder: (Element, Element) throws -> Bool
  ) rethrows -> Inclusion where S.Element == Element {
    var rawResult: UInt = 0, cache, otherCache: Element?, isDone = false
    var iterator = makeIterator(), otherIterator = other.makeIterator()
    while !isDone {
      cache = cache ?? iterator.next()
      otherCache = otherCache ?? otherIterator.next()
      switch (cache, otherCache) {
      case (nil, nil):
        isDone = true
      case (_?, nil):
        rawResult |= 0x01
        isDone = true
      case (nil, _?):
        rawResult |= 0x02
        isDone = true
      case let (first?, second?):
        if try areInIncreasingOrder(first, second) {
          rawResult |= 0x01
          cache = nil
        } else if try areInIncreasingOrder(second, first) {
          rawResult |= 0x02
          otherCache = nil
        } else {
          rawResult |= 0x04
          cache = nil
          otherCache = nil
        }
        isDone = rawResult == 0x07
      }
    }
    return Inclusion(rawValue: rawResult)!
  }
}

//===----------------------------------------------------------------------===//
// sortedOverlap(with:)
//===----------------------------------------------------------------------===//

extension Sequence where Element: Comparable {
  /// Returns how this sequence and the given sequence overlap, assuming both
  /// are sorted.
  ///
  /// - Parameters:
  ///   - other: A sequence to compare to this sequence.
  /// - Returns: The degree of inclusion between the sequences.
  ///
  /// - Complexity: O(*m*), where *m* is the lesser of the length of the
  ///   sequence and the length of `other`.
  @inlinable
  public func sortedOverlap<S: Sequence>(with other: S) -> Inclusion
  where S.Element == Element {
    return sortedOverlap(with: other, by: <)
  }
}
