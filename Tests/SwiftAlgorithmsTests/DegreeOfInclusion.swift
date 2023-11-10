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

import XCTest
import Algorithms

/// Unit tests for the `sortedOverlap` method and `SetInclusion` type.
final class SortedInclusionTests: XCTestCase {
  /// Check the `SetInclusion` type's properties.
  func testInclusion() {
    XCTAssertEqualSequences(SetInclusion.allCases, [
      .bothUninhabited, .onlyFirstInhabited, .onlySecondInhabited,
      .dualExclusivesOnly, .sharedOnly, .firstExtendsSecond,
      .secondExtendsFirst, .dualExclusivesAndShared
    ])

    XCTAssertEqualSequences(SetInclusion.allCases.map(\.hasExclusivesToFirst), [
      false, true, false, true, false, true, false, true
    ])
    XCTAssertEqualSequences(SetInclusion.allCases.map(\.hasExclusivesToSecond), [
      false, false, true, true, false, false, true, true
    ])
    XCTAssertEqualSequences(SetInclusion.allCases.map(\.hasSharedElements), [
      false, false, false, false, true, true, true, true
    ])

    XCTAssertEqualSequences(SetInclusion.allCases.map(\.areIdentical), [
      true, false, false, false, true, false, false, false
    ])
    XCTAssertEqualSequences(SetInclusion.allCases.map(\.doesFirstIncludeSecond), [
      true, true, false, false, true, true, false, false
    ])
    XCTAssertEqualSequences(SetInclusion.allCases.map(\.doesSecondIncludeFirst), [
      true, false, true, false, true, false, true, false
    ])
  }

  /// Check when both sources are empty.
  func testEmpty() {
    let empty = EmptyCollection<Int>()
    XCTAssertEqual(empty.degreeOfInclusion(with: empty), .bothUninhabited)
  }

  /// Check when exactly one source is empty.
  func testOnlyOneEmpty() {
    let empty = EmptyCollection<Int>(), single = CollectionOfOne(1)
    XCTAssertEqual(single.degreeOfInclusion(with: empty), .onlyFirstInhabited)
    XCTAssertEqual(empty.degreeOfInclusion(with: single), .onlySecondInhabited)
  }

  /// Check when there are no common elements.
  func testDisjoint() {
    let one = CollectionOfOne(1), two = CollectionOfOne(2)
    XCTAssertEqual(one.degreeOfInclusion(with: two), .dualExclusivesOnly)
    XCTAssertEqual(two.degreeOfInclusion(with: one), .dualExclusivesOnly)
    // The order changes which comparison branch is used and which versus-nil
    // case is used.
  }

  /// Check when there are only common elements.
  func testIdentical() {
    let single = CollectionOfOne(1)
    XCTAssertEqual(single.degreeOfInclusion(with: single), .sharedOnly)
  }

  /// Check when the first source is a superset of the second.
  func testFirstIncludesSecond() {
    XCTAssertEqual([1, 2, 3, 5, 7].degreeOfInclusion(with: [1, 3, 5, 7]),
                   .firstExtendsSecond)
    XCTAssertEqual([2, 4, 6, 8].degreeOfInclusion(with: [2, 4, 6]),
                   .firstExtendsSecond)
    // The logic path differs if the last elements tie, or the first source's
    // last element is bigger.  (The second's last element can't be biggest.)
  }

  /// Check when the second source is a superset of the first.
  func testSecondIncludesFirst() {
    XCTAssertEqual([1, 3, 5, 7].degreeOfInclusion(with: [1, 2, 3, 5, 7]),
                   .secondExtendsFirst)
    XCTAssertEqual([2, 4, 6].degreeOfInclusion(with: [2, 4, 6, 8]),
                   .secondExtendsFirst)
    // The logic path differs if the last elements tie, or the second source's
    // last element is bigger.  (The first's last element can't be biggest.)
  }

  /// Check when there are shared and two-way exclusive elements.
  func testPartialOverlap() {
    XCTAssertEqual([3, 6, 9].degreeOfInclusion(with: [2, 4, 6, 8]),
                   .dualExclusivesAndShared)
    XCTAssertEqual([1, 2, 4].degreeOfInclusion(with: [1, 4, 16]),
                   .dualExclusivesAndShared)
    // For the three categories; exclusive to first, exclusive to second, and
    // shared; if the third one encountered isn't from the last element(s) from
    // a sequence(s), then the iteration will end early.  The first example
    // uses the short-circuit condition.
  }
}
