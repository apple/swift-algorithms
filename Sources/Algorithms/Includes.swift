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
// MARK: Sequence.includes(sorted:sortedBy:)
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
    return try !overlap(withSorted: other, bailAfterOtherExclusive: true,
                        sortedBy: areInIncreasingOrder).elementsFromOther!
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
  ///     assert(test1.elementsFromSelf!)
  ///     assert(test1.sharedElements!)
  ///     assert(!test1.elementsFromOther!)
  ///     assert(test2.elementsFromSelf!)
  ///     assert(test2.sharedElements!)
  ///     assert(test2.elementsFromOther!)
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
  /// - Returns: A tuple of three `Bool` members indicating whether there are
  ///   elements exclusive to `self`,
  ///   there are elements shared between the sequences,
  ///   and there are elements exclusive to `other`.
  ///   If a member is `true`,
  ///   then at least one element in that category exists.
  ///   If a member is `false`,
  ///   then there are no elements in that category.
  ///   If a member is `nil`,
  ///   then the function aborted before its category's status could be
  ///   determined.
  ///
  /// - Complexity: O(*n*), where `n` is the length of the shorter sequence.
  public func overlap<T: Sequence>(
    withSorted other: T,
    bailAfterSelfExclusive: Bool = false,
    bailAfterShared: Bool = false,
    bailAfterOtherExclusive: Bool = false,
    sortedBy areInIncreasingOrder: (Element, Element) throws -> Bool
  ) rethrows -> (
    elementsFromSelf: Bool?,
    sharedElements: Bool?,
    elementsFromOther: Bool?
  )
  where T.Element == Element {
    var firstElement, secondElement: Element?
    var iterator = makeIterator(), otherIterator = other.makeIterator()
    var result: (fromSelf: Bool?, shared: Bool?, fromOther: Bool?)
  loop:
    while result != (true, true, true) {
      firstElement = firstElement ?? iterator.next()
      secondElement = secondElement ?? otherIterator.next()
      switch (firstElement, secondElement) {
      case let (s?, o?) where try areInIncreasingOrder(s, o):
        // Exclusive to self
        result.fromSelf = true
        guard !bailAfterSelfExclusive else { break loop }

        // Move to the next element in self.
        firstElement = nil
      case let (s?, o?) where try areInIncreasingOrder(o, s):
        // Exclusive to other
        result.fromOther = true
        guard !bailAfterOtherExclusive else { break loop }

        // Move to the next element in other.
        secondElement = nil
      case (_?, _?):
        // Shared
        result.shared = true
        guard !bailAfterShared else { break loop }

        // Iterate to the next element for both sequences.
        firstElement = nil
        secondElement = nil
      case (_?, nil):
        // Never bail, just finalize after finding an exclusive to self.
        result.fromSelf = true
        result.shared = result.shared ?? false
        result.fromOther = result.fromOther ?? false
        break loop
      case (nil, _?):
        // Never bail, just finalize after finding an exclusive to other.
        result.fromSelf = result.fromSelf ?? false
        result.shared = result.shared ?? false
        result.fromOther = true
        break loop
      case (nil, nil):
        // Finalize everything instead of bailing
        result.fromSelf = result.fromSelf ?? false
        result.shared = result.shared ?? false
        result.fromOther = result.fromOther ?? false
        break loop
      }
    }
    return (result.fromSelf, result.shared, result.fromOther)
  }
}

extension Sequence where Element: Comparable {
  /// Assuming that this sequence and the given sequence are sorted,
  /// check if the sequences have overlap and/or exclusive elements.
  ///
  ///     let base = [0, 1, 2, 3, 6, 6, 7, 8, 9]
  ///     let test1 = base.overlap(withSorted: [1, 2, 6, 7, 8])
  ///     let test2 = base.overlap(withSorted: [1, 2, 5, 7, 8])
  ///     assert(test1.elementsFromSelf!)
  ///     assert(test1.sharedElements!)
  ///     assert(!test1.elementsFromOther!)
  ///     assert(test2.elementsFromSelf!)
  ///     assert(test2.sharedElements!)
  ///     assert(test2.elementsFromOther!)
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
  /// - Returns: A tuple of three `Bool` members indicating whether there are
  ///   elements exclusive to `self`,
  ///   elements shared between the sequences,
  ///   and elements exclusive to `other`.
  ///   If a member is `true`,
  ///   then at least one element in that category exists.
  ///   If a member is `false`,
  ///   then there are no elements in that category.
  ///   If a member is `nil`,
  ///   then the function aborted before its category's status could be
  ///   determined.
  ///
  /// - Complexity: O(*n*), where `n` is the length of the shorter sequence.
  @inlinable
  public func overlap<T: Sequence>(
    withSorted other: T,
    bailAfterSelfExclusive: Bool = false,
    bailAfterShared: Bool = false,
    bailAfterOtherExclusive: Bool = false
  ) -> (
    elementsFromSelf: Bool?,
    sharedElements: Bool?,
    elementsFromOther: Bool?
  )
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
