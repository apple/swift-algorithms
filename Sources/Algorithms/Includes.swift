//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift Algorithms open source project
//
// Copyright (c) 2024 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// MARK: OverlapDegree
//-------------------------------------------------------------------------===//

/// The amount of overlap between two sets.
public enum OverlapDegree: UInt, CaseIterable {
  /// Both sets are empty (degenerate).
  case bothEmpty
  /// Have a nonempty first set, empty second (degenerate).
  case onlyFirstNonempty
  /// Have an empty first set, nonempty second (degenerate).
  case onlySecondNonempty
  /// Have two nonempty sets with no overlap.
  case disjoint
  /// The two sets are equivalent and nonempty.
  case identical
  /// The first set is a strict superset of a nonempty second.
  case firstIncludesNonemptySecond
  /// The first set is a nonempty strict subset of the second.
  case secondIncludesNonemptyFirst
  /// The sets overlap but each still have exclusive elements.
  case partialOverlap
}

extension OverlapDegree {
  /// The bit mask checking if there are elements exclusive to the first set.
  @usableFromInline
  static var firstOnlyMask: RawValue { 1 << 0 }
  /// The bit mask checking if there are elements exclusive to the second set.
  @usableFromInline
  static var secondOnlyMask: RawValue { 1 << 1 }
  /// The bit mask checking if there are elements shared by both sets.
  @usableFromInline
  static var sharedMask: RawValue { 1 << 2 }
}

extension OverlapDegree {
  /// Whether there are any elements in the first set that are not in
  /// the second.
  @inlinable
  public var hasElementsExclusiveToFirst: Bool
  { rawValue & Self.firstOnlyMask != 0 }
  /// Whether there are any elements in the second set that are not in
  /// the first.
  @inlinable
  public var hasElementsExclusiveToSecond: Bool
  { rawValue & Self.secondOnlyMask != 0 }
  /// Whether there are any elements that occur in both sets.
  @inlinable
  public var hasSharedElements: Bool
  { rawValue & Self.sharedMask != 0 }
}

//===----------------------------------------------------------------------===//
// MARK: - Sequence.includes(sorted:sortedBy:)
//-------------------------------------------------------------------------===//

extension Sequence {
  /// Assuming that this sequence and the given sequence are sorted according
  /// to the given predicate, determine whether the given sequence is contained
  /// within this one.
  ///
  ///     let base = [9, 8, 7, 6, 6, 3, 2, 1, 0]
  ///     assert(base.includes(sorted: [8, 7, 6, 2, 1], sortedBy: >))
  ///     assert(!base.includes(sorted: [8, 7, 5, 2, 1], sortedBy: >))
  ///
  /// The elements of the argument need not be contiguous in the receiver.
  ///
  /// - Precondition: Both the receiver and `other` must be sorted according to
  ///   `areInIncreasingOrder`, which must be a strict weak ordering over
  ///   its arguments. Either the receiver, `other`, or both must be finite.
  ///
  /// - Parameters:
  ///   - other: The sequence that is compared against the receiver.
  ///   - areInIncreasingOrder: The sorting criteria.
  /// - Returns: Whether the entirety of `other` is contained within this
  ///   sequence.
  ///
  /// - Complexity: O(*n*), where `n` is the length of the shorter sequence.
  @inlinable
  public func includes<T: Sequence>(
    sorted other: T,
    sortedBy areInIncreasingOrder: (Element, Element) throws -> Bool
  ) rethrows -> Bool
  where T.Element == Element {
    return try !overlap(
      withSorted: other,
      bailAfterOtherExclusive: true,
      sortedBy: areInIncreasingOrder
    ).hasElementsExclusiveToSecond
  }
}

extension Sequence where Element: Comparable {
  /// Assuming that this sequence and the given sequence are sorted,
  /// determine whether the given sequence is contained within this one.
  ///
  ///     let base = [0, 1, 2, 3, 6, 6, 7, 8, 9]
  ///     assert(base.includes(sorted: [1, 2, 6, 7, 8]))
  ///     assert(!base.includes(sorted: [1, 2, 5, 7, 8]))
  ///
  /// The elements of the argument need not be contiguous in the receiver.
  ///
  /// - Precondition: Both the receiver and `other` must be sorted.
  ///   At least one of the involved sequences must be finite.
  ///
  /// - Parameter other: The sequence that is compared against the receiver.
  /// - Returns: Whether the entirety of `other` is contained within this
  ///   sequence.
  ///
  /// - Complexity: O(*n*), where `n` is the length of the shorter sequence.
  @inlinable
  public func includes<T: Sequence>(sorted other: T) -> Bool
  where T.Element == Element {
    return includes(sorted: other, sortedBy: <)
  }
}

//===----------------------------------------------------------------------===//
// MARK: - Sequence.overlap(withSorted:sortedBy:)
//-------------------------------------------------------------------------===//

extension Sequence {
  /// Assuming that this sequence and the given sequence are sorted according
  /// to the given predicate, check if the sequences have overlap and/or
  /// exclusive elements.
  ///
  ///     let base = [9, 8, 7, 6, 6, 3, 2, 1, 0]
  ///     let test1 = base.overlap(withSorted: [8, 7, 6, 2, 1], sortedBy: >)
  ///     let test2 = base.overlap(withSorted: [8, 7, 5, 2, 1], sortedBy: >)
  ///     assert(test1.hasElementsExclusiveToFirst)
  ///     assert(test1.hasSharedElements)
  ///     assert(!test1.hasElementsExclusiveToSecond)
  ///     assert(test2.hasElementsExclusiveToFirst!)
  ///     assert(test2.hasSharedElements)
  ///     assert(test2.hasElementsExclusiveToSecond)
  ///
  /// - Precondition: Both the receiver and `other` must be sorted according to
  ///   `areInIncreasingOrder`,
  ///   which must be a strict weak ordering over its arguments.
  ///   Either the receiver, `other`, or both must be finite.
  ///
  /// - Parameters:
  ///   - other: The sequence that is compared against the receiver.
  ///   - areInIncreasingOrder: The sorting criteria.
  ///   - bailAfterSelfExclusive: Indicate that this function should abort as
  ///     soon as one element that is exclusive to this sequence is found.
  ///     If not given, defaults to `false`.
  ///   - bailAfterShared: Indicate that this function should abort as soon as
  ///     an element that both sequences share is found.
  ///     If not given, defaults to `false`.
  ///   - bailAfterOtherExclusive: Indicate that this function should abort as
  ///     soon as one element that is exclusive to `other` is found.
  ///     If not given, defaults to `false`.
  /// - Returns: A value representing the categories of overlap found.
  ///   If none of the abort arguments were `true`,
  ///   or otherwise none of their corresponding categories were found,
  ///   then all of the category flags from the returned value are accurate.
  ///   Otherwise,
  ///   the returned value has exactly one of the flags in the
  ///   short-circuit subset as `true`,
  ///   and the flags outside that set may have invalid values.
  ///   The receiver is considered the first set, and `other` as the second.
  ///
  /// - Complexity: O(*n*), where `n` is the length of the shorter sequence.
  public func overlap<T: Sequence>(
    withSorted other: T,
    bailAfterSelfExclusive: Bool = false,
    bailAfterShared: Bool = false,
    bailAfterOtherExclusive: Bool = false,
    sortedBy areInIncreasingOrder: (Element, Element) throws -> Bool
  ) rethrows -> OverlapDegree
  where T.Element == Element {
    var firstElement, secondElement: Element?
    var iterator = makeIterator(), otherIterator = other.makeIterator()
    var fromSelf, shared, fromOther: Bool?
  loop:
    while (fromSelf, shared, fromOther) != (true, true, true) {
      firstElement = firstElement ?? iterator.next()
      secondElement = secondElement ?? otherIterator.next()
      switch (firstElement, secondElement) {
      case let (s?, o?) where try areInIncreasingOrder(s, o):
        // Exclusive to self
        fromSelf = true
        guard !bailAfterSelfExclusive else { break loop }

        // Move to the next element in self.
        firstElement = nil
      case let (s?, o?) where try areInIncreasingOrder(o, s):
        // Exclusive to other
        fromOther = true
        guard !bailAfterOtherExclusive else { break loop }

        // Move to the next element in other.
        secondElement = nil
      case (_?, _?):
        // Shared
        shared = true
        guard !bailAfterShared else { break loop }

        // Iterate to the next element for both sequences.
        firstElement = nil
        secondElement = nil
      case (_?, nil):
        // Never bail, just finalize after finding an exclusive to self.
        fromSelf = true
        shared = shared ?? false
        fromOther = fromOther ?? false
        break loop
      case (nil, _?):
        // Never bail, just finalize after finding an exclusive to other.
        fromSelf = fromSelf ?? false
        shared = shared ?? false
        fromOther = true
        break loop
      case (nil, nil):
        // Finalize everything instead of bailing
        fromSelf = fromSelf ?? false
        shared = shared ?? false
        fromOther = fromOther ?? false
        break loop
      }
    }

    let selfBit  = fromSelf  == true ? OverlapDegree.firstOnlyMask  : 0,
        shareBit = shared    == true ? OverlapDegree.sharedMask     : 0,
        otherBit = fromOther == true ? OverlapDegree.secondOnlyMask : 0
    return .init(rawValue: selfBit | shareBit | otherBit)!
  }
}

extension Sequence where Element: Comparable {
  /// Assuming that this sequence and the given sequence are sorted,
  /// check if the sequences have overlap and/or exclusive elements.
  ///
  ///     let base = [0, 1, 2, 3, 6, 6, 7, 8, 9]
  ///     let test1 = base.overlap(withSorted: [1, 2, 6, 7, 8])
  ///     let test2 = base.overlap(withSorted: [1, 2, 5, 7, 8])
  ///     assert(test1.hasElementsExclusiveToFirst)
  ///     assert(test1.hasSharedElements)
  ///     assert(!test1.hasElementsExclusiveToSecond)
  ///     assert(test2.hasElementsExclusiveToFirst)
  ///     assert(test2.hasSharedElements)
  ///     assert(test2.hasElementsExclusiveToSecond)
  ///
  /// - Precondition: Both the receiver and `other` must be sorted.
  ///   At least one of the involved sequences must be finite.
  ///
  /// - Parameters:
  ///   - other: The sequence that is compared against the receiver.
  ///   - bailAfterSelfExclusive: Indicate that this function should abort as
  ///     soon as one element that is exclusive to this sequence is found.
  ///     If not given, defaults to `false`.
  ///   - bailAfterShared: Indicate that this function should abort as soon as
  ///     an element that both sequences share is found.
  ///     If not given, defaults to `false`.
  ///   - bailAfterOtherExclusive: Indicate that this function should abort as
  ///     soon as one element that is exclusive to `other` is found.
  ///     If not given, defaults to `false`.
  /// - Returns: A value representing the categories of overlap found.
  ///   If none of the abort arguments were `true`,
  ///   or otherwise none of their corresponding categories were found,
  ///   then all of the category flags from the returned value are accurate.
  ///   Otherwise,
  ///   the returned value has exactly one of the flags in the
  ///   short-circuit subset as `true`,
  ///   and the flags outside that set may have invalid values.
  ///   The receiver is considered the first set, and `other` as the second.
  ///
  /// - Complexity: O(*n*), where `n` is the length of the shorter sequence.
  @inlinable
  public func overlap<T: Sequence>(
    withSorted other: T,
    bailAfterSelfExclusive: Bool = false,
    bailAfterShared: Bool = false,
    bailAfterOtherExclusive: Bool = false
  ) -> OverlapDegree
  where T.Element == Element {
    return overlap(
      withSorted: other,
      bailAfterSelfExclusive: bailAfterSelfExclusive,
      bailAfterShared: bailAfterShared,
      bailAfterOtherExclusive: bailAfterOtherExclusive,
      sortedBy: <
    )
  }
}
