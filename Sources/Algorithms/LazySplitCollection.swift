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

/// A collection that lazily splits a base collection into subsequences separated by elements that satisfy the given `whereSeparator` predicate.
///
/// - Note: This type is the result of `x.split(maxSplits:omittingEmptySubsequences:whereSeparator)` and
/// `x.split(separator:maxSplits:omittingEmptySubsequences)`, where `x` conforms to `LazyCollection`.
public struct LazySplitCollection<Base: LazyCollectionProtocol> where Base.Element: Equatable, Base.Elements.Index == Base.Index {
  internal let base: Base
  internal let whereSeparator: (Base.Element) -> Bool
  internal let maxSplits: Int
  internal let omittingEmptySubsequences: Bool
}

extension LazySplitCollection {
  public struct Iterator {
    internal let base: Base
    internal let whereSeparator: (Base.Element) -> Bool
    internal let maxSplits: Int
    internal let omittingEmptySubsequences: Bool
    internal var subSequenceStart: Base.Index
    internal var splitCount = 0

    internal init(
      base: Base,
      whereSeparator: @escaping (Base.Element) -> Bool,
      maxSplits: Int,
      omittingEmptySubsequences: Bool
    ) {
      self.base = base
      self.whereSeparator = whereSeparator
      self.maxSplits = maxSplits
      self.omittingEmptySubsequences = omittingEmptySubsequences
      self.subSequenceStart = self.base.startIndex
    }
  }
}

extension LazySplitCollection.Iterator: IteratorProtocol, Sequence {
  public typealias Element = Base.Elements.SubSequence

  public mutating func next() -> Element? {
    guard subSequenceStart < base.endIndex else { return nil }

    var subSequenceEnd: Base.Index
    var lastAdjacentSeparator: Base.Index

    if splitCount < maxSplits {
      splitCount += 1
      subSequenceEnd = base[subSequenceStart...].firstIndex(where: whereSeparator) ?? base.endIndex
      lastAdjacentSeparator = subSequenceEnd

      while omittingEmptySubsequences && lastAdjacentSeparator < base.endIndex {
        let next = base.index(after: lastAdjacentSeparator)
        if next < base.endIndex && whereSeparator(base[next]) {
          lastAdjacentSeparator = next
        } else {
          break
        }
      }
    } else {
      subSequenceEnd = base.endIndex
      lastAdjacentSeparator = subSequenceEnd
    }

    defer {
      if lastAdjacentSeparator < base.endIndex {
        subSequenceStart = base.index(after: lastAdjacentSeparator)
      } else {
        subSequenceStart = base.endIndex
      }
    }

    return base.elements[subSequenceStart..<subSequenceEnd]
  }
}

extension LazySplitCollection: LazySequenceProtocol {
  public func makeIterator() -> Iterator {
    return Iterator(
      base: self.base,
      whereSeparator: self.whereSeparator,
      maxSplits: self.maxSplits,
      omittingEmptySubsequences: self.omittingEmptySubsequences
    )
  }
}

extension LazyCollection where Element: Equatable {
  /// Lazily returns the longest possible subsequences of the collection, in order,
  /// that don't contain elements satisfying the given predicate.
  ///
  /// The resulting lazy sequence consists of at most `maxSplits + 1` subsequences.
  /// Elements that are used to split the sequence are not returned as part of
  /// any subsequence.
  ///
  /// The following examples show the effects of the `maxSplits` and
  /// `omittingEmptySubsequences` parameters when lazily splitting a string using a
  /// closure that matches spaces. The first use of `split` returns each word
  /// that was originally separated by one or more spaces.
  ///
  ///     let line = "BLANCHE:   I don't want realism. I want magic!"
  ///     for spaceless in line.lazy.split(whereSeparator: { $0 == " " }) {
  ///       print(spaceless)
  ///     }
  ///     // Prints
  ///     // BLANCHE:
  ///     // I
  ///     // don't
  ///     // want
  ///     // realism.
  ///     // I
  ///     // want
  ///     // magic!
  ///
  /// The second example passes `1` for the `maxSplits` parameter, so the
  /// original string is split just once, into two new strings.
  ///
  ///     for spaceless in line.lazy.split(maxSplits: 1, whereSeparator: { $0 == " " }) {
  ///       print(spaceless)
  ///     }
  ///     // Prints
  ///     // BLANCHE:
  ///     // I don't want realism. I want magic!
  ///
  /// The final example passes `false` for the `omittingEmptySubsequences`
  /// parameter, so the returned array contains empty strings where spaces
  /// were repeated.
  ///
  ///     for spaceless in line.lazy.split(omittingEmptySubsequences: false, whereSeparator: { $0 == " " }) {
  ///       print(spaceless)
  ///     }
  ///     // Prints
  ///     // BLANCHE:
  ///     //
  ///     //
  ///     // I
  ///     // don't
  ///     // want
  ///     // realism.
  ///     // I
  ///     // want
  ///     // magic!
  ///
  /// - Parameters:
  ///   - maxSplits: The maximum number of times to split the collection, or
  ///     one less than the number of subsequences to return. If
  ///     `maxSplits + 1` subsequences are returned, the last one is a suffix
  ///     of the original collection containing the remaining elements.
  ///     `maxSplits` must be greater than or equal to zero. The default value
  ///     is `Int.max`.
  ///   - omittingEmptySubsequences: If `false`, an empty subsequence is
  ///     returned in the result for each pair of consecutive elements
  ///     satisfying the `isSeparator` predicate and for each element at the
  ///     start or end of the collection satisfying the `isSeparator`
  ///     predicate. The default value is `true`.
  ///   - whereSeparator: A closure that takes an element as an argument and
  ///     returns a Boolean value indicating whether the collection should be
  ///     split at that element.
  /// - Returns: A lazy sequence of subsequences, split from this collection's
  ///   elements.
  ///
  /// - Complexity: O(*n*), where *n* is the length of the collection.
  func split(
    maxSplits: Int = Int.max,
    omittingEmptySubsequences: Bool = true,
    whereSeparator: @escaping (Base.Element) -> Bool
  ) -> LazySplitCollection<Self> {
    LazySplitCollection(
      base: self,
      whereSeparator: whereSeparator,
      maxSplits: maxSplits,
      omittingEmptySubsequences: omittingEmptySubsequences
    )
  }

  /// Lazily returns the longest possible subsequences of the collection, in order,
  /// around elements equal to the given element.
  ///
  /// The resulting lazy sequence consists of at most `maxSplits + 1` subsequences.
  /// Elements that are used to split the collection are not returned as part
  /// of any subsequence.
  ///
  /// The following examples show the effects of the `maxSplits` and
  /// `omittingEmptySubsequences` parameters when splitting a string at each
  /// space character (" "). The first use of `split` returns each word that
  /// was originally separated by one or more spaces.
  ///
  ///     let line = "BLANCHE:   I don't want realism. I want magic!"
  ///     for spaceless in line.lazy.split(separator: " ") {
  ///       print(spaceless)
  ///     }
  ///     // Prints
  ///     // BLANCHE:
  ///     // I
  ///     // don't
  ///     // want
  ///     // realism.
  ///     // I
  ///     // want
  ///     // magic!
  ///
  /// The second example passes `1` for the `maxSplits` parameter, so the
  /// original string is split just once, into two new strings.
  ///
  ///     for spaceless in line.lazy.split(separator: " ", maxSplits: 1) {
  ///       print(spaceless)
  ///     }
  ///     // Prints
  ///     // BLANCHE:
  ///     // I don't want realism. I want magic!
  ///
  /// The final example passes `false` for the `omittingEmptySubsequences`
  /// parameter, so the returned array contains empty strings where spaces
  /// were repeated.
  ///
  ///     for spaceless in line.lazy.split(separator: " ", omittingEmptySubsequences: false) {
  ///       print(spaceless)
  ///     }
  ///     // Prints
  ///     // BLANCHE:
  ///     //
  ///     //
  ///     // I
  ///     // don't
  ///     // want
  ///     // realism.
  ///     // I
  ///     // want
  ///     // magic!
  ///
  /// - Parameters:
  ///   - separator: The element that should be split upon.
  ///   - maxSplits: The maximum number of times to split the collection, or
  ///     one less than the number of subsequences to return. If
  ///     `maxSplits + 1` subsequences are returned, the last one is a suffix
  ///     of the original collection containing the remaining elements.
  ///     `maxSplits` must be greater than or equal to zero. The default value
  ///     is `Int.max`.
  ///   - omittingEmptySubsequences: If `false`, an empty subsequence is
  ///     returned in the result for each consecutive pair of `separator`
  ///     elements in the collection and for each instance of `separator` at
  ///     the start or end of the collection. If `true`, only nonempty
  ///     subsequences are returned. The default value is `true`.
  /// - Returns: A lazy sequence of subsequences, split from this collection's
  ///   elements.
  ///
  /// - Complexity: O(*n*), where *n* is the length of the collection.
  func split(
    separator: Element,
    maxSplits: Int = Int.max,
    omittingEmptySubsequences: Bool = true
  ) -> LazySplitCollection<Self> {
    LazySplitCollection(
      base: self,
      whereSeparator: { $0 == separator },
      maxSplits: maxSplits,
      omittingEmptySubsequences: omittingEmptySubsequences
    )
  }
}
