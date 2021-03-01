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

/// A sequence that lazily splits a base sequence into subsequences separated by
/// elements that satisfy the given `whereSeparator` predicate.
///
/// - Note: This type is the result of
///
///     x.split(maxSplits:omittingEmptySubsequences:whereSeparator)
///     x.split(separator:maxSplits:omittingEmptySubsequences)
///
///   where `x` conforms to `LazySequenceProtocol`.
public struct LazySplitSequence<Base: Sequence> {
  internal let base: Base
  internal let isSeparator: (Base.Element) -> Bool
  internal let maxSplits: Int
  internal let omittingEmptySubsequences: Bool
}

extension LazySplitSequence {
  public struct Iterator {
    public typealias Element = [Base.Element]

    internal var base: Base.Iterator
    internal let isSeparator: (Base.Element) -> Bool
    internal let maxSplits: Int
    internal let omittingEmptySubsequences: Bool

    /// The number of separators found and used to make a split.
    internal var separatorCount = 0

    /// The number of subsequences returned.
    internal var sequenceLength = 0

    internal init(
      base: Base.Iterator,
      whereSeparator: @escaping (Base.Element) -> Bool,
      maxSplits: Int,
      omittingEmptySubsequences: Bool
    ) {
      self.base = base
      self.isSeparator = whereSeparator
      self.maxSplits = maxSplits
      self.omittingEmptySubsequences = omittingEmptySubsequences
    }
  }
}

extension LazySplitSequence.Iterator: IteratorProtocol {
  public mutating func next() -> Element? {
    var currentElement = base.next()
    var subsequence: Element = []

    // Add the next elements of the base sequence to this subsequence, until we
    // reach a separator, unless we've already split the maximum number of
    // times. In all cases, stop at the end of the base sequence.
    while currentElement != nil {
      if separatorCount < maxSplits && isSeparator(currentElement!) {
        separatorCount += 1

        if omittingEmptySubsequences && subsequence.isEmpty {
          // Keep going if we don't want to return an empty subsequence.
          currentElement = base.next()
          continue
        } else {
          break
        }
      } else {
        subsequence.append(currentElement!)
        currentElement = base.next()
      }
    }

    // We're done iterating when we've reached the end of the base sequence,
    // and we've either returned the maximum number of subsequences (one more
    // than the number of separators), or the only subsequence left to return is
    // empty and we're omitting those.
    if currentElement == nil
        && (sequenceLength == separatorCount + 1
              || omittingEmptySubsequences && subsequence.isEmpty) {
      return nil
    } else {
      sequenceLength += 1
      return subsequence
    }
  }
}

extension LazySplitSequence: LazySequenceProtocol {
  public func makeIterator() -> Iterator {
    return Iterator(
      base: base.makeIterator(),
      whereSeparator: self.isSeparator,
      maxSplits: self.maxSplits,
      omittingEmptySubsequences: self.omittingEmptySubsequences
    )
  }
}

extension LazySequenceProtocol {
  /// Lazily returns the longest possible subsequences of the sequence, in
  /// order, that don't contain elements satisfying the given predicate.
  ///
  /// The resulting lazy sequence consists of at most `maxSplits + 1`
  /// subsequences. Elements that are used to split the sequence are not
  /// returned as part of any subsequence (except possibly the last one, in the
  /// case where `maxSplits` is less than the number of separators in the
  /// sequence).
  ///
  /// The following examples show the effects of the `maxSplits` and
  /// `omittingEmptySubsequences` parameters when lazily splitting a string
  /// using a closure that matches spaces. The first use of `split` returns each
  /// word that was originally separated by one or more spaces.
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
  ///     for spaceless in line.lazy.split(
  ///       maxSplits: 1,
  ///       whereSeparator: { $0 == " " }
  ///     ) {
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
  ///     for spaceless in line.lazy.split(
  ///       omittingEmptySubsequences: false,
  ///       whereSeparator: { $0 == " " }
  ///     ) {
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
  ///   - maxSplits: The maximum number of times to split the sequence, or
  ///     one less than the number of subsequences to return. If
  ///     `maxSplits + 1` subsequences are returned, the last one is a suffix
  ///     of the original sequence containing the remaining elements.
  ///     `maxSplits` must be greater than or equal to zero. The default value
  ///     is `Int.max`.
  ///   - omittingEmptySubsequences: If `false`, an empty subsequence is
  ///     returned in the result for each pair of consecutive elements
  ///     satisfying the `isSeparator` predicate and for each element at the
  ///     start or end of the sequence satisfying the `isSeparator`
  ///     predicate. The default value is `true`.
  ///   - whereSeparator: A closure that takes an element as an argument and
  ///     returns a Boolean value indicating whether the sequence should be
  ///     split at that element.
  /// - Returns: A lazy sequence of subsequences, split from this sequence's
  ///   elements.
  ///
  /// - Complexity: O(*n*), where *n* is the length of the sequence.
  public func split(
    maxSplits: Int = Int.max,
    omittingEmptySubsequences: Bool = true,
    whereSeparator isSeparator: @escaping (Element) -> Bool
  ) -> LazySplitSequence<Elements> {
    precondition(maxSplits >= 0, "Must take zero or more splits")

    return LazySplitSequence(
      base: elements,
      isSeparator: isSeparator,
      maxSplits: maxSplits,
      omittingEmptySubsequences: omittingEmptySubsequences
    )
  }
}

extension LazySequenceProtocol where Element: Equatable {
  /// Lazily returns the longest possible subsequences of the sequence, in
  /// order, around elements equal to the given element.
  ///
  /// The resulting lazy sequence consists of at most `maxSplits + 1`
  /// subsequences. Elements that are used to split the sequence are not
  /// returned as part of any subsequence (except possibly the last one, in the
  /// case where `maxSplits` is less than the number of separators in the
  /// sequence).
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
  ///     for spaceless in line.lazy.split(
  ///       separator: " ",
  ///       omittingEmptySubsequences: false
  ///     ) {
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
  ///   - maxSplits: The maximum number of times to split the sequence, or
  ///     one less than the number of subsequences to return. If
  ///     `maxSplits + 1` subsequences are returned, the last one is a suffix
  ///     of the original sequence containing the remaining elements.
  ///     `maxSplits` must be greater than or equal to zero. The default value
  ///     is `Int.max`.
  ///   - omittingEmptySubsequences: If `false`, an empty subsequence is
  ///     returned in the result for each consecutive pair of `separator`
  ///     elements in the sequence and for each instance of `separator` at
  ///     the start or end of the sequence. If `true`, only nonempty
  ///     subsequences are returned. The default value is `true`.
  /// - Returns: A lazy sequence of subsequences, split from this sequence's
  ///   elements.
  ///
  /// - Complexity: O(*n*), where *n* is the length of the sequence.
  public func split(
    separator: Element,
    maxSplits: Int = Int.max,
    omittingEmptySubsequences: Bool = true
  ) -> LazySplitSequence<Elements> {
    precondition(maxSplits >= 0, "Must take zero or more splits")

    return LazySplitSequence(
      base: elements,
      isSeparator: { $0 == separator },
      maxSplits: maxSplits,
      omittingEmptySubsequences: omittingEmptySubsequences
    )
  }
}
