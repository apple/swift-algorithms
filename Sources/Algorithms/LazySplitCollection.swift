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

/// A collection that lazily splits a base collection into subsequences separated by elements that satisfy the
/// given `whereSeparator` predicate.
///
/// - Note: This type is the result of
///
///     x.split(maxSplits:omittingEmptySubsequences:whereSeparator)
///     x.split(separator:maxSplits:omittingEmptySubsequences)
///
///   where `x` conforms to `LazyCollectionProtocol`.
public struct LazySplitCollection<Base: LazyCollectionProtocol>
where Base.Elements.Index == Base.Index {
  internal let base: Base
  internal let isSeparator: (Base.Element) -> Bool
  internal let maxSplits: Int
  internal let omittingEmptySubsequences: Bool
}

extension LazySplitCollection {
  public struct Iterator {
    public typealias Index = Base.Index

    internal let base: Base
    internal let isSeparator: (Base.Element) -> Bool
    internal let maxSplits: Int
    internal let omittingEmptySubsequences: Bool
    internal var subsequenceStart: Base.Index
    internal var separatorCount = 0
    internal var sequenceLength = 0

    internal init(
      base: Base,
      whereSeparator: @escaping (Base.Element) -> Bool,
      maxSplits: Int,
      omittingEmptySubsequences: Bool
    ) {
      self.base = base
      self.isSeparator = whereSeparator
      self.maxSplits = maxSplits
      self.omittingEmptySubsequences = omittingEmptySubsequences
      self.subsequenceStart = self.base.startIndex
    }
  }
}

extension LazySplitCollection.Iterator: IteratorProtocol {
  public typealias Element = Base.Elements.SubSequence

  public mutating func next() -> Element? {
    /// Separators mark the points where we want to split (cut in two) the base collection, removing
    /// the separator in the process.
    ///
    /// Each split yields two subsequences, though splitting at the start or end of a sequence yields
    /// an empty subsequence where there were no elements adjacent to the cut.
    ///
    /// Thus the maximum number of subsequences returned after iterating the entire base collection
    /// (including empty ones, if they are not omitted) will be at most one more than the number of
    /// splits made (equivalently, one more than the number of separators encountered).
    ///
    /// The number of splits is limited by `maxSplits`, and thus may be less than the total number
    /// of separators in the base collection.
    ///
    ///     [1, 2, 42, 3, 4, 42, 5].split(separator: 42,
    ///                                   omittingEmptySubsequences: false)
    ///     // first split -> [1, 2], [3, 4, 42, 5]
    ///     // last split  -> [1, 2], [3, 4], [5]
    ///
    ///     [1, 2, 42, 3, 4, 42, 5, 42].split(separator: 42,
    ///                                       maxSplits: 2,
    ///                                       omittingEmptySubsequences: false)
    ///     // first split -> [1, 2], [3, 4, 42, 5, 42]
    ///     // last split  -> [1, 2], [3, 4], [5, 42]
    ///
    ///     [42, 1, 42].split(separator: 42, omittingEmptySubsequences: false)
    ///     // first split -> [], [1, 42]
    ///     // last split  -> [], [1], []
    ///
    ///     [42, 42].split(separator: 42, omittingEmptySubsequences: false)
    ///     // first split -> [], [42]
    ///     // last split  -> [], [], []
    ///
    /// Preconditions:
    /// `subsequenceStart` points to the beginning of the next subsequence to return (which may
    /// turn out to be empty), or the end of the base collection.

    guard subsequenceStart < base.endIndex else {
      if !omittingEmptySubsequences && sequenceLength < separatorCount + 1 {
        /// We've reached the end of the base collection, and we're returning empty subsequences, but we
        /// haven't yet returned one more subsequence than the number of splits we've performed (i.e., the
        /// number of separators we've encountered). This happens when the last element of the base
        /// collection is a separator. Return one last empty subsequence.
        sequenceLength += 1
        return base.elements[subsequenceStart..<subsequenceStart]
      } else {
        return nil
      }
    }

    /// The non-inclusive end of the next subsequence is marked by the next separator, or the end of the base collection.
    var subsequenceEnd: Base.Index

    /// The number of separators encountered thus far is identical to the number of splits performed thus far.
    if separatorCount < maxSplits {
      subsequenceEnd = base[subsequenceStart...].firstIndex(where: isSeparator) ?? base.endIndex

      if omittingEmptySubsequences && base[subsequenceStart..<subsequenceEnd].isEmpty {
        /// Find the next sequence of non-separators.
        subsequenceStart = base[subsequenceEnd...].firstIndex(where: { !isSeparator($0) }) ?? base.endIndex
        if subsequenceStart == base.endIndex {
          /// No non-separators left in the base collection, so we're done.
          return nil
        }
        subsequenceEnd = base[subsequenceStart...].firstIndex(where: isSeparator) ?? base.endIndex
      }
    } else {
      /// We've performed the requested number of splits. Return all remaining elements in the base collection as one final subsequence.
      subsequenceEnd = base.endIndex
    }

    defer {
      separatorCount += subsequenceEnd < base.endIndex ? 1 : 0
      sequenceLength += 1
      subsequenceStart = subsequenceEnd < base.endIndex ? base.index(after: subsequenceEnd) : base.endIndex
    }

    return base.elements[subsequenceStart..<subsequenceEnd]
  }
}

extension LazySplitCollection: LazySequenceProtocol {
  public func makeIterator() -> Iterator {
    return Iterator(
      base: self.base,
      whereSeparator: self.isSeparator,
      maxSplits: self.maxSplits,
      omittingEmptySubsequences: self.omittingEmptySubsequences
    )
  }
}

extension LazyCollectionProtocol where Elements.Index == Index {
  /// Lazily returns the longest possible subsequences of the collection, in order,
  /// that don't contain elements satisfying the given predicate.
  ///
  /// The resulting lazy sequence consists of at most `maxSplits + 1` subsequences.
  /// Elements that are used to split the collection are not returned as part of any
  /// subsequence (except possibly the last one, in the case where `maxSplits` is
  /// less than the number of separators in the collection).
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
    whereSeparator isSeparator: @escaping (Element) -> Bool
  ) -> LazySplitCollection<Self> {
    precondition(maxSplits >= 0, "Must take zero or more splits")

    return LazySplitCollection(
      base: self,
      isSeparator: isSeparator,
      maxSplits: maxSplits,
      omittingEmptySubsequences: omittingEmptySubsequences
    )
  }
}

extension LazyCollectionProtocol where Element: Equatable, Elements.Index == Index {
  /// Lazily returns the longest possible subsequences of the collection, in order,
  /// around elements equal to the given element.
  ///
  /// The resulting lazy sequence consists of at most `maxSplits + 1` subsequences.
  /// Elements that are used to split the collection are not returned as part of any
  /// subsequence (except possibly the last one, in the case where `maxSplits` is
  /// less than the number of separators in the collection).
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
    precondition(maxSplits >= 0, "Must take zero or more splits")

    return LazySplitCollection(
      base: self,
      isSeparator: { $0 == separator },
      maxSplits: maxSplits,
      omittingEmptySubsequences: omittingEmptySubsequences
    )
  }
}
