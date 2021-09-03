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
// SplitSequence
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
public struct SplitSequence<Base: Sequence> {
  @usableFromInline
  internal let base: Base

  @usableFromInline
  internal let isSeparator: (Base.Element) -> Bool

  @usableFromInline
  internal let maxSplits: Int

  @usableFromInline
  internal let omittingEmptySubsequences: Bool

  @inlinable
  internal init(
    base: Base,
    isSeparator: @escaping (Base.Element) -> Bool,
    maxSplits: Int,
    omittingEmptySubsequences: Bool
  ) {
    self.base = base
    self.isSeparator = isSeparator
    self.maxSplits = maxSplits
    self.omittingEmptySubsequences = omittingEmptySubsequences
  }
}

extension SplitSequence: Sequence {
  public struct Iterator {
    public typealias Element = [Base.Element]

    @usableFromInline
    internal var base: Base.Iterator

    @usableFromInline
    internal let isSeparator: (Base.Element) -> Bool

    @usableFromInline
    internal let maxSplits: Int

    @usableFromInline
    internal let omittingEmptySubsequences: Bool

    /// The number of splits performed.
    @usableFromInline
    internal var splitCount = 0

    /// The number of subsequences returned.
    @usableFromInline
    internal var sequenceLength = 0

    @inlinable
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
  
  @inlinable
  public func makeIterator() -> Iterator {
    Iterator(
      base: base.makeIterator(),
      whereSeparator: self.isSeparator,
      maxSplits: self.maxSplits,
      omittingEmptySubsequences: self.omittingEmptySubsequences
    )
  }
}

extension SplitSequence.Iterator: IteratorProtocol {
  @inlinable
  public mutating func next() -> Element? {
    var currentElement = base.next()
    var subsequence: Element = []

    // Add the next elements of the base sequence to this subsequence, until we
    // reach a separator, unless we've already split the maximum number of
    // times. In all cases, stop at the end of the base sequence.
    while currentElement != nil {
      if splitCount < maxSplits && isSeparator(currentElement!) {
        if omittingEmptySubsequences && subsequence.isEmpty {
          // Keep going if we don't want to return an empty subsequence.
          currentElement = base.next()
          continue
        } else {
          splitCount += 1
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
      && (sequenceLength == splitCount + 1
        || omittingEmptySubsequences && subsequence.isEmpty)
    {
      return nil
    } else {
      sequenceLength += 1
      return subsequence
    }
  }
}

extension SplitSequence: LazySequenceProtocol {}

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
  /// `omittingEmptySubsequences` parameters when lazily splitting a sequence of
  /// integers using a closure that matches numbers evenly divisible by 3 or 5.
  /// The first use of `split` returns each subsequence that was originally
  /// separated by one or more such numbers.
  ///
  ///     let numbers = stride(from: 1, through: 16, by: 1)
  ///     for subsequence in numbers.lazy.split(
  ///       whereSeparator: { $0 % 3 == 0 || $0 % 5 == 0 }
  ///     ) {
  ///       print(subsequence)
  ///     }
  ///     /* Prints:
  ///     [1, 2]
  ///     [4]
  ///     [7, 8]
  ///     [11]
  ///     [13, 14]
  ///     [16]
  ///     */
  ///
  /// The second example passes `1` for the `maxSplits` parameter, so the
  /// original sequence is split just once, into two subsequences.
  ///
  ///     for subsequence in numbers.lazy.split(
  ///       maxSplits: 1,
  ///       whereSeparator: { $0 % 3 == 0 || $0 % 5 == 0 }
  ///     ) {
  ///       print(subsequence)
  ///     }
  ///     /* Prints:
  ///     [1, 2]
  ///     [4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16]
  ///     */
  ///
  /// The final example passes `false` for the `omittingEmptySubsequences`
  /// parameter, so the sequence of returned subsequences contains empty
  /// subsequences where numbers evenly divisible by 3 or 5 were repeated.
  ///
  ///     for subsequence in numbers.lazy.split(
  ///         omittingEmptySubsequences: false,
  ///         whereSeparator: { $0 % 3 == 0 || $0 % 5 == 0 }
  ///     ) {
  ///       print(subsequence)
  ///     }
  ///     /* Prints:
  ///     [1, 2]
  ///     [4]
  ///     []
  ///     [7, 8]
  ///     []
  ///     [11]
  ///     [13, 14]
  ///     [16]
  ///     */
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
  @inlinable
  public func split(
    maxSplits: Int = Int.max,
    omittingEmptySubsequences: Bool = true,
    whereSeparator isSeparator: @escaping (Element) -> Bool
  ) -> SplitSequence<Elements> {
    precondition(maxSplits >= 0, "Must take zero or more splits")

    return SplitSequence(
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
  /// `omittingEmptySubsequences` parameters when splitting a sequence of
  /// integers at each zero (`0`). The first use of `split` returns each
  /// subsequence that was originally separated by one or more zeros.
  ///
  ///     let numbers = AnySequence([1, 2, 0, 3, 4, 0, 0, 5])
  ///     for subsequence in numbers.lazy.split(separator: 0) {
  ///       print(subsequence)
  ///     }
  ///     /* Prints:
  ///     [1, 2]
  ///     [3, 4]
  ///     [5]
  ///     */
  ///
  /// The second example passes `1` for the `maxSplits` parameter, so the
  /// original sequence is split just once, into two subsequences.
  ///
  ///     for subsequence in numbers.lazy.split(
  ///         separator: 0,
  ///         maxSplits: 1
  ///     ) {
  ///       print(subsequence)
  ///     }
  ///     /* Prints:
  ///     [1, 2]
  ///     [3, 4, 0, 0, 5]
  ///     */
  ///
  /// The final example passes `false` for the `omittingEmptySubsequences`
  /// parameter, so the sequence of returned subsequences contains empty
  /// subsequences where zeros were repeated.
  ///
  ///     for subsequence in numbers.lazy.split(
  ///         separator: 0,
  ///         omittingEmptySubsequences: false
  ///     ) {
  ///       print(subsequence)
  ///     }
  ///     /* Prints:
  ///     [1, 2]
  ///     [3, 4]
  ///     []
  ///     [5]
  ///     */
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
  @inlinable
  public func split(
    separator: Element,
    maxSplits: Int = Int.max,
    omittingEmptySubsequences: Bool = true
  ) -> SplitSequence<Elements> {
    precondition(maxSplits >= 0, "Must take zero or more splits")

    return SplitSequence(
      base: elements,
      isSeparator: { $0 == separator },
      maxSplits: maxSplits,
      omittingEmptySubsequences: omittingEmptySubsequences
    )
  }
}

//===----------------------------------------------------------------------===//
// SplitCollection
//===----------------------------------------------------------------------===//

/// A collection that lazily splits a base collection into subsequences
/// separated by elements that satisfy the given `whereSeparator` predicate.
///
/// - Note: This type is the result of
///
///     x.split(maxSplits:omittingEmptySubsequences:whereSeparator)
///     x.split(separator:maxSplits:omittingEmptySubsequences)
///
///   where `x` conforms to `LazySequenceProtocol` and `Collection`.
public struct SplitCollection<Base: Collection> {
  @usableFromInline
  internal let base: Base

  @usableFromInline
  internal let isSeparator: (Base.Element) -> Bool

  @usableFromInline
  internal let maxSplits: Int

  @usableFromInline
  internal let omittingEmptySubsequences: Bool

  @usableFromInline
  internal var _startIndex: Index

  @inlinable
  internal init(
    base: Base,
    isSeparator: @escaping (Base.Element) -> Bool,
    maxSplits: Int,
    omittingEmptySubsequences: Bool
  ) {
    self.base = base
    self.isSeparator = isSeparator
    self.maxSplits = maxSplits
    self.omittingEmptySubsequences = omittingEmptySubsequences

    // We precalculate `startIndex`. There are three possibilities:
    // 1. `base` is empty and we're _not_ omitting empty subsequences, in which
    // case the following index describes the sole element of this collection;
    self._startIndex = Index(
      baseRange: base.startIndex..<base.startIndex,
      sequenceLength: 1,
      splitCount: 0
    )
    if base.isEmpty {
      if omittingEmptySubsequences {
        // 2. `base` is empty and we _are_ omitting empty subsequences, so this
        // collection has no elements;
        _startIndex = endIndex
      }
    } else {
      // 3. `base` isn't empty, so we must iterate it to determine the start
      // index.
      _startIndex = indexForSubsequence(
        atOrAfter: base.startIndex,
        sequenceLength: 0,
        splitCount: 0
      )
    }
  }
}

extension SplitCollection: Collection {
  /// Position of a subsequence in a split collection.
  public struct Index: Comparable {
    /// The range corresponding to the subsequence at this position.
    @usableFromInline
    internal let baseRange: Range<Base.Index>

    /// The number of subsequences up to and including this position in the
    /// collection.
    @usableFromInline
    internal let sequenceLength: Int

    /// The number splits performed up to and including this position in the
    /// collection.
    @usableFromInline
    internal let splitCount: Int

    @inlinable
    internal init(
      baseRange: Range<Base.Index>,
      sequenceLength: Int,
      splitCount: Int
    ) {
      self.baseRange = baseRange
      self.sequenceLength = sequenceLength
      self.splitCount = splitCount
    }

    @inlinable
    public static func == (lhs: Index, rhs: Index) -> Bool {
      // `sequenceLength` is equivalent to the index's 1-based position in the
      // collection of indices.
      lhs.sequenceLength == rhs.sequenceLength
    }

    @inlinable
    public static func < (lhs: Index, rhs: Index) -> Bool {
      lhs.sequenceLength < rhs.sequenceLength
    }
  }

  /// Returns the index of the subsequence starting at or after the given base
  /// collection index.
  @inlinable
  internal func indexForSubsequence(
    atOrAfter lowerBound: Base.Index,
    sequenceLength: Int,
    splitCount: Int
  ) -> Index {
    var start = lowerBound
    // If we don't have any more splits to do (which we'll determine shortly),
    // the end of this subsequence will be the end of the base collection.
    var end = base.endIndex

    if splitCount < maxSplits {
      // The non-inclusive end of this subsequence is marked by the next
      // separator, or the end of the base collection.
      end =
        base[start...].firstIndex(where: isSeparator)
        ?? base.endIndex

      if base[start..<end].isEmpty {
        if omittingEmptySubsequences {
          // Find the next subsequence of non-separators.
          start =
            base[end...].firstIndex(where: { !isSeparator($0) })
            ?? base.endIndex
          if start == base.endIndex {
            // No non-separators left in the base collection. We're done.
            return endIndex
          }
          end = base[start...].firstIndex(where: isSeparator) ?? base.endIndex
        }
      }
    }

    var updatedSplitCount = splitCount
    if end != base.endIndex {
      // This subsequence ends on a separator (and perhaps includes other
      // separators, if we're omitting empty subsequences), so we've performed
      // another split.
      updatedSplitCount += 1
    }

    return Index(
      baseRange: start..<end,
      sequenceLength: sequenceLength + 1,
      splitCount: updatedSplitCount
    )
  }

  @inlinable
  public var startIndex: Index {
    _startIndex
  }

  @inlinable
  public var endIndex: Index {
    Index(
      baseRange: base.endIndex..<base.endIndex,
      sequenceLength: Int.max,
      splitCount: Int.max
    )
  }

  @inlinable
  public func index(after i: Index) -> Index {
    precondition(i != endIndex, "Can't advance past endIndex")

    var subsequenceStart = i.baseRange.upperBound
    if subsequenceStart < base.endIndex {
      // If we're not already at the end of the base collection, the previous
      // susequence ended with a separator. Start searching for the next
      // subsequence at the following element.
      subsequenceStart = base.index(after: i.baseRange.upperBound)
    }

    guard subsequenceStart != base.endIndex else {
      if !omittingEmptySubsequences
        && i.sequenceLength < i.splitCount + 1
      {
        // The base collection ended with a separator, so we need to emit one
        // more empty subsequence. This one differs from `endIndex` in its
        // `sequenceLength` (except in an extreme edge case!), which is the
        // sole property tested for equality and comparison.
        return Index(
          baseRange: base.endIndex..<base.endIndex,
          sequenceLength: i.sequenceLength + 1,
          splitCount: i.splitCount
        )
      } else {
        return endIndex
      }
    }

    return indexForSubsequence(
      atOrAfter: subsequenceStart,
      sequenceLength: i.sequenceLength,
      splitCount: i.splitCount
    )
  }

  @inlinable
  public subscript(position: Index) -> Base.SubSequence {
    precondition(position != endIndex, "Can't subscript using endIndex")
    return base[position.baseRange]
  }
}

extension SplitCollection.Index: Hashable {
  @inlinable
  public func hash(into hasher: inout Hasher) {
    hasher.combine(sequenceLength)
  }
}

extension SplitCollection: LazyCollectionProtocol {}

extension LazySequenceProtocol where Self: Collection, Elements: Collection {
  /// Lazily returns the longest possible subsequences of the collection, in
  /// order, that don't contain elements satisfying the given predicate.
  ///
  /// The resulting lazy collection consists of at most `maxSplits + 1`
  /// subsequences. Elements that are used to split the collection are not
  /// returned as part of any subsequence (except possibly the last one, in the
  /// case where `maxSplits` is less than the number of separators in the
  /// collection).
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
  /// - Returns: A lazy collection of subsequences, split from this collection's
  ///   elements.
  ///
  /// - Complexity: O(*n*), where *n* is the length of the collection.
  @inlinable
  public func split(
    maxSplits: Int = Int.max,
    omittingEmptySubsequences: Bool = true,
    whereSeparator isSeparator: @escaping (Element) -> Bool
  ) -> SplitCollection<Elements> {
    precondition(maxSplits >= 0, "Must take zero or more splits")

    return SplitCollection(
      base: elements,
      isSeparator: isSeparator,
      maxSplits: maxSplits,
      omittingEmptySubsequences: omittingEmptySubsequences
    )
  }
}

extension LazySequenceProtocol
  where Self: Collection, Elements: Collection, Element: Equatable
{
  /// Lazily returns the longest possible subsequences of the collection, in
  /// order, around elements equal to the given element.
  ///
  /// The resulting lazy collection consists of at most `maxSplits + 1`
  /// subsequences. Elements that are used to split the collection are not
  /// returned as part of any subsequence (except possibly the last one, in the
  /// case where `maxSplits` is less than the number of separators in the
  /// collection).
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
  /// - Returns: A lazy collection of subsequences split from this collection's
  ///   elements.
  ///
  /// - Complexity: O(*n*), where *n* is the length of the collection.
  @inlinable
  public func split(
    separator: Element,
    maxSplits: Int = Int.max,
    omittingEmptySubsequences: Bool = true
  ) -> SplitCollection<Elements> {
    precondition(maxSplits >= 0, "Must take zero or more splits")

    return SplitCollection(
      base: elements,
      isSeparator: { $0 == separator },
      maxSplits: maxSplits,
      omittingEmptySubsequences: omittingEmptySubsequences
    )
  }
}
