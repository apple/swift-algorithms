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

  /// The bit mask covering all potential mask values.
  @usableFromInline
  static var allMask: RawValue
  { firstOnlyMask | secondOnlyMask | sharedMask }
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

extension OverlapDegree {
  /// Using the given description for which parts of a set operation result need
  /// to be detected,
  /// return whether this degree covers at least one of those parts.
  ///
  /// A set operation result part is considered to exist if the result has at
  /// least one element that can qualify to be within that part.
  /// This means that a degree of `.bothEmpty` never matches any part detection,
  /// and that a detection request of `.nothing` can never be found.
  ///
  /// - Parameter condition: The parts of a set operation result whose
  ///   existence needs to be tested for.
  /// - Returns: Whether this degree includes at least one
  ///   set operation result part that can match the `condition`.
  ///
  /// - Complexity: O(1).
  @inlinable
  public func canSatisfy(_ condition: OverlapHaltCondition) -> Bool {
    return rawValue & condition.rawValue != 0
  }
}

//===----------------------------------------------------------------------===//
// MARK: - OverlapHaltCondition
//-------------------------------------------------------------------------===//

/// The condition when determining overlap should stop early.
public enum OverlapHaltCondition: UInt, CaseIterable {
  /// Never stop reading elements if necessary.
  case nothing
  /// Stop when an element exclusive to the first set is found.
  case anyExclusiveToFirst
  /// Stop when an element exclusive to the second set is found.
  case anyExclusiveToSecond
  /// Stop when finding an element from exactly one set.
  case anyExclusive
  /// Stop when finding an element present in both sets.
  case anythingShared
  /// Stop when an element from the first set is found.
  case anyFromFirst
  /// Stop when an element from the second set is found.
  case anyFromSecond
  /// Stop on the first element found.
  case anything
}

extension OverlapHaltCondition {
  /// The bit mask checking if analysis stops at the first element exclusive to
  /// the first set.
  @usableFromInline
  static var firstOnlyMask: RawValue { 1 << 0 }
  /// The bit mask checking if analysis stops at the first element exclusive to
  /// the second set.
  @usableFromInline
  static var secondOnlyMask: RawValue { 1 << 1 }
  /// The bit mask checking if analysis stops at the first element shared by
  /// both sets.
  @usableFromInline
  static var sharedMask: RawValue { 1 << 2 }
}

extension OverlapHaltCondition {
  /// Whether analysis can stop on finding an element exclusive to the first set.
  @inlinable
  public var stopsOnElementsExclusiveToFirst: Bool
  { rawValue & Self.firstOnlyMask != 0 }
  /// Whether analysis can stop on finding an element exclusive to the second set.
  @inlinable
  public var stopsOnElementsExclusiveToSecond: Bool
  { rawValue & Self.secondOnlyMask != 0 }
  /// Whether analysis can stop on finding an element shared by both sets.
  @inlinable
  public var stopsOnSharedElements: Bool
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
      stoppingFor: .anyExclusiveToSecond,
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
// MARK: - Sequence.overlap(withSorted:stoppingFor:sortedBy:)
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
  /// When only the existence of specific kinds of overlap needs to be checked,
  /// an extra argument can be supplied to stop reading the sequences as
  /// soon as one confirmation has been found.
  ///
  ///     let test3 = base.overlap(withSorted: [8, 7, 5, 2, 1],
  ///                              stoppingFor: .anythingShared, sortedBy: >)
  ///     assert(test3.hasSharedElements)
  ///
  /// As soon as the value `8` is read from both `base` and the argument,
  /// a shared element has been detected,
  /// so the call ends early.
  /// With early returns,
  /// at most one of the searched-for overlap properties will be `true`;
  /// all others will be `false`,
  /// since the call ended before any other criteria could be checked.
  /// The status of overlap properties outside of the search set are not
  /// reliable to check.
  /// For this past example, only the `hasSharedElements` property is
  /// guaranteed to supply a valid value.
  ///
  /// Since triggering an early-end condition sets exactly one of the
  /// return value's flags among the potentially multiple ones that could
  /// match the condition,
  /// calling the return value's `canSatisfy(:)` function may be shorter than
  /// checking each potential flag individually.
  ///
  /// For both the return value and any possible early-end conditions,
  /// the receiver is considered the first sequence and `other` is
  /// considered the second sequence.
  ///
  /// - Precondition: Both the receiver and `other` must be sorted according to
  ///   `areInIncreasingOrder`,
  ///   which must be a strict weak ordering over its arguments.
  ///   Either the receiver, `other`, or both must be finite.
  ///
  /// - Parameters:
  ///   - other: The sequence that is compared against the receiver.
  ///   - condition: A specification of set operation result parts that will end
  ///     this call early if found.
  ///     If not given,
  ///     defaults to `.nothing`.
  ///   - areInIncreasingOrder: The sorting criteria.
  /// - Returns: The set operation result parts that would be present if
  ///   these sequence operands were merged ino a single sorted sequence and
  ///   all the sequences were treated as sets.
  ///   If at least one of the parts is in the `condition` filter,
  ///   this function call will end early,
  ///   and the return value may be a proper subset of the actual result.
  ///   Call `.canSatisfy(condition)` function on the returned value to check if
  ///   an early finish happened.
  ///
  /// - Complexity: O(*n*), where `n` is the length of the shorter sequence.
  public func overlap<T: Sequence>(
    withSorted other: T,
    stoppingFor condition: OverlapHaltCondition = .nothing,
    sortedBy areInIncreasingOrder: (Element, Element) throws -> Bool
  ) rethrows -> OverlapDegree
  where T.Element == Element {
    var firstElement, secondElement: Element?
    var selfIterator = makeIterator(), otherIterator = other.makeIterator()
    var result: OverlapDegree.RawValue = 0
  loop:
    while result & OverlapDegree.allMask != OverlapDegree.allMask {
      firstElement  = firstElement  ?? selfIterator.next()
      secondElement = secondElement ?? otherIterator.next()
      switch (firstElement, secondElement) {
      case let (first?, second?) where try areInIncreasingOrder(first, second):
        // Exclusive to self
        result |= OverlapDegree.firstOnlyMask
        guard !condition.stopsOnElementsExclusiveToFirst else { break loop }

        // Move to the next element in self.
        firstElement = nil
      case let (first?, second?) where try areInIncreasingOrder(second, first):
        // Exclusive to other
        result |= OverlapDegree.secondOnlyMask
        guard !condition.stopsOnElementsExclusiveToSecond else { break loop }

        // Move to the next element in other.
        secondElement = nil
      case (_?, _?):
        // Shared
        result |= OverlapDegree.sharedMask
        guard !condition.stopsOnSharedElements else { break loop }

        // Iterate to the next element for both sequences.
        firstElement = nil
        secondElement = nil
      case (_?, nil):
        // First exclusive to self after other ended
        result |= OverlapDegree.firstOnlyMask
        break loop
      case (nil, _?):
        // First exclusive to other after self ended
        result |= OverlapDegree.secondOnlyMask
        break loop
      case (nil, nil):
        // No exclusives since both sequences stopped
        break loop
      }
    }

    return .init(rawValue: result)!
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
  /// When only the existence of specific kinds of overlap needs to be checked,
  /// an extra argument can be supplied to stop reading the sequences as
  /// soon as one confirmation has been found.
  ///
  ///     let test3 = base.overlap(withSorted: [-1, 1, 2, 4, 7, 8],
  ///                              stoppingFor: .anythingShared)
  ///     assert(test3.hasSharedElements)
  ///
  /// As soon as the value `1` is read from both `base` and the argument,
  /// a shared element has been detected,
  /// so the call ends early.
  /// With early returns,
  /// at most one of the searched-for overlap properties will be `true`;
  /// all others will be `false`,
  /// since the call ended before any other criteria could be checked.
  /// The status of overlap properties outside of the search set are not
  /// reliable to check.
  /// For this past example, only the `hasSharedElements` property is
  /// guaranteed to supply a valid value.
  ///
  /// Since triggering an early-end condition sets exactly one of the
  /// return value's flags among the potentially multiple ones that could
  /// match the condition,
  /// calling the return value's `canSatisfy(:)` function may be shorter than
  /// checking each potential flag individually.
  ///
  /// For both the return value and any possible early-end conditions,
  /// the receiver is considered the first sequence and `other` is
  /// considered the second sequence.
  ///
  /// - Precondition: Both the receiver and `other` must be sorted.
  ///   At least one of the involved sequences must be finite.
  ///
  /// - Parameters:
  ///   - other: The sequence that is compared against the receiver.
  ///   - condition: A specification of set operation result parts that will end
  ///     this call early if found.
  ///     If not given,
  ///     defaults to `.nothing`.
  /// - Returns: The set operation result parts that would be present if
  ///   these sequence operands were merged ino a single sorted sequence and
  ///   all the sequences were treated as sets.
  ///   If at least one of the parts is in the `condition` filter,
  ///   this function call will end early,
  ///   and the return value may be a proper subset of the actual result.
  ///   Call `.canSatisfy(condition)` function on the returned value to check if
  ///   an early finish happened.
  ///
  /// - Complexity: O(*n*), where `n` is the length of the shorter sequence.
  @inlinable
  public func overlap<T: Sequence>(
    withSorted other: T,
    stoppingFor condition: OverlapHaltCondition = .nothing
  ) -> OverlapDegree
  where T.Element == Element {
    return overlap(withSorted: other, stoppingFor: condition, sortedBy: <)
  }
}
