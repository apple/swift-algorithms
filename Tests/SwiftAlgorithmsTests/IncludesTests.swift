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

import XCTest
import Algorithms

final class IncludesTests: XCTestCase {
  /// Confirm the operations for `OverlapDegree`.
  func testOverlapDegree() {
    XCTAssertEqualSequences(
      OverlapDegree.allCases,
      [
        .bothEmpty, .onlyFirstNonempty, .onlySecondNonempty, .disjoint,
        .identical, .firstIncludesNonemptySecond, .secondIncludesNonemptyFirst,
        .partialOverlap
      ]
    )

    XCTAssertEqualSequences(
      OverlapDegree.allCases.map(\.hasElementsExclusiveToFirst),
      [false, true, false, true, false, true, false, true]
    )
    XCTAssertEqualSequences(
      OverlapDegree.allCases.map(\.hasElementsExclusiveToSecond),
      [false, false, true, true, false, false, true, true]
    )
    XCTAssertEqualSequences(
      OverlapDegree.allCases.map(\.hasSharedElements),
      [false, false, false, false, true, true, true, true]
    )
  }

  /// Confirm the operations for `OverlapHaltCondition`.
  func testOverlapHaltCondition() {
    XCTAssertEqualSequences(
      OverlapHaltCondition.allCases,
      [.nothing, .anyExclusiveToFirst, .anyExclusiveToSecond, .anyExclusive,
       .anythingShared, .anyFromFirst, .anyFromSecond, .anything]
    )

    XCTAssertEqualSequences(
      OverlapHaltCondition.allCases.map(\.stopsOnElementsExclusiveToFirst),
      [false, true, false, true, false, true, false, true]
    )
    XCTAssertEqualSequences(
      OverlapHaltCondition.allCases.map(\.stopsOnElementsExclusiveToSecond),
      [false, false, true, true, false, false, true, true]
    )
    XCTAssertEqualSequences(
      OverlapHaltCondition.allCases.map(\.stopsOnSharedElements),
      [false, false, false, false, true, true, true, true]
    )
  }

  /// Check if one empty set includes another.
  func testBothSetsEmpty() {
    XCTAssertTrue(EmptyCollection<Int>().includes(sorted: EmptyCollection()))
  }

  /// Check if a non-empty set contains an empty one.
  func testNonemptyIncludesEmpty() {
    XCTAssertTrue(CollectionOfOne(2).includes(sorted: EmptyCollection()))
  }

  /// Check if an empty set contains a non-empty one.
  func testEmptyIncludesNonempty() {
    XCTAssertFalse(EmptyCollection().includes(sorted: CollectionOfOne(2)))
  }

  /// Check for inclusion between disjoint (non-empty) sets.
  func testDisjointSets() {
    XCTAssertFalse("abc".includes(sorted: "DEF"))
  }

  /// Check if a non-empty set includes an identical one.
  func testIdenticalSets() {
    XCTAssertTrue([0, 1, 2, 3].includes(sorted: 0..<4))
  }

  /// Check if a set includes a strict non-empty subset.
  func testStrictSubset() {
    XCTAssertTrue([0, 1, 2, 3].includes(sorted: 1..<3))
    XCTAssertTrue([0, 1, 2, 3].includes(sorted: 0..<2))
    XCTAssertTrue([0, 1, 2, 3].includes(sorted: 2..<4))
  }

  /// Check if a non-empty set incudes a strict superset.
  func testStrictSuperset() {
    XCTAssertFalse([0, 1, 2, 3].includes(sorted: -1..<5))
    XCTAssertFalse([0, 1, 2, 3].includes(sorted: -1..<4))
    XCTAssertFalse([0, 1, 2, 3].includes(sorted:  0..<5))
  }

  /// Check if a non-empty set includes another that shares just some elements.
  func testOverlap() {
    XCTAssertFalse([0, 1, 2, 3].includes(sorted:  2..<5))
    XCTAssertFalse([0, 1, 2, 3].includes(sorted: -1..<2))
  }

  /// Check the comprehensive tests for short-circuit matching.
  func testCanSatisfy() {
    XCTAssertEqualSequences(
      product(OverlapDegree.allCases, OverlapHaltCondition.allCases).map {
        $0.0.canSatisfy($0.1)
      },
      [
        false, //  bothEmpty, nothing
        false, //  bothEmpty, anyExclusiveToFirst
        false, //  bothEmpty, anyExclusiveToSecond
        false, //  bothEmpty, anyExclusive
        false, //  bothEmpty, anythingShared
        false, //  bothEmpty, anyFromFirst
        false, //  bothEmpty, anyFromSecond
        false, //  bothEmpty, anything
        false, //  onlyFirstNonempty, nothing
        true , //  onlyFirstNonempty, anyExclusiveToFirst
        false, //  onlyFirstNonempty, anyExclusiveToSecond
        true , //  onlyFirstNonempty, anyExclusive
        false, //  onlyFirstNonempty, anythingShared
        true , //  onlyFirstNonempty, anyFromFirst
        false, //  onlyFirstNonempty, anyFromSecond
        true , //  onlyFirstNonempty, anything
        false, //  onlySecondNonempty, nothing
        false, //  onlySecondNonempty, anyExclusiveToFirst
        true , //  onlySecondNonempty, anyExclusiveToSecond
        true , //  onlySecondNonempty, anyExclusive
        false, //  onlySecondNonempty, anythingShared
        false, //  onlySecondNonempty, anyFromFirst
        true , //  onlySecondNonempty, anyFromSecond
        true , //  onlySecondNonempty, anything
        false, //  disjoint, nothing
        true , //  disjoint, anyExclusiveToFirst
        true , //  disjoint, anyExclusiveToSecond
        true , //  disjoint, anyExclusive
        false, //  disjoint, anythingShared
        true , //  disjoint, anyFromFirst
        true , //  disjoint, anyFromSecond
        true , //  disjoint, anything
        false, //  identical, nothing
        false, //  identical, anyExclusiveToFirst
        false, //  identical, anyExclusiveToSecond
        false, //  identical, anyExclusive
        true , //  identical, anythingShared
        true , //  identical, anyFromFirst
        true , //  identical, anyFromSecond
        true , //  identical, anything
        false, //  firstIncludesNonemptySecond, nothing
        true , //  firstIncludesNonemptySecond, anyExclusiveToFirst
        false, //  firstIncludesNonemptySecond, anyExclusiveToSecond
        true , //  firstIncludesNonemptySecond, anyExclusive
        true , //  firstIncludesNonemptySecond, anythingShared
        true , //  firstIncludesNonemptySecond, anyFromFirst
        true , //  firstIncludesNonemptySecond, anyFromSecond
        true , //  firstIncludesNonemptySecond, anything
        false, //  secondIncludesNonemptyFirst, nothing
        false, //  secondIncludesNonemptyFirst, anyExclusiveToFirst
        true , //  secondIncludesNonemptyFirst, anyExclusiveToSecond
        true , //  secondIncludesNonemptyFirst, anyExclusive
        true , //  secondIncludesNonemptyFirst, anythingShared
        true , //  secondIncludesNonemptyFirst, anyFromFirst
        true , //  secondIncludesNonemptyFirst, anyFromSecond
        true , //  secondIncludesNonemptyFirst, anything
        false, //  partialOverlap, nothing
        true , //  partialOverlap, anyExclusiveToFirst
        true , //  partialOverlap, anyExclusiveToSecond
        true , //  partialOverlap, anyExclusive
        true , //  partialOverlap, anythingShared
        true , //  partialOverlap, anyFromFirst
        true , //  partialOverlap, anyFromSecond
        true , //  partialOverlap, anything
      ]
    )
  }

  /// Confirm the example code from `Sequence.includes(sorted:sortedBy:)`.
  func testIncludesWithCustomPredicate() {
    let base = [9, 8, 7, 6, 6, 3, 2, 1, 0]
    XCTAssertTrue(base.includes(sorted: [8, 7, 6, 2, 1], sortedBy: >))
    XCTAssertFalse(base.includes(sorted: [8, 7, 5, 2, 1], sortedBy: >))
  }

  /// Confirm the example code from `Sequence.includes(sorted:)`.
  func testIncludesWithComparable() {
    let base = [0, 1, 2, 3, 6, 6, 7, 8, 9]
    XCTAssertTrue(base.includes(sorted: [1, 2, 6, 7, 8]))
    XCTAssertFalse(base.includes(sorted: [1, 2, 5, 7, 8]))
  }

  /// Confirm the example code from `Sequence.overlap(withSorted:stoppingFor:`
  /// `sortedBy:)`.
  func testOverlapWithCustomPredicate() {
    let base = [9, 8, 7, 6, 6, 3, 2, 1, 0]
    let test1 = base.overlap(withSorted: [8, 7, 6, 2, 1], sortedBy: >)
    let test2 = base.overlap(withSorted: [8, 7, 5, 2, 1], sortedBy: >)
    XCTAssertTrue(test1.hasElementsExclusiveToFirst)
    XCTAssertTrue(test1.hasSharedElements)
    XCTAssertFalse(test1.hasElementsExclusiveToSecond)
    XCTAssertTrue(test2.hasElementsExclusiveToFirst)
    XCTAssertTrue(test2.hasSharedElements)
    XCTAssertTrue(test2.hasElementsExclusiveToSecond)

    let test3 = base.overlap(withSorted: [8, 7, 4, 2, 1],
                             stoppingFor: .anythingShared, sortedBy: >)
    XCTAssertTrue(test3.hasSharedElements)
  }

  /// Confirm the example code from `Sequence.overlap(withSorted:stoppingFor:)`.
  func testOverlapWithComparable() {
    let base = [0, 1, 2, 3, 6, 6, 7, 8, 9]
    let test1 = base.overlap(withSorted: [1, 2, 6, 7, 8])
    let test2 = base.overlap(withSorted: [1, 2, 5, 7, 8])
    XCTAssertTrue(test1.hasElementsExclusiveToFirst)
    XCTAssertTrue(test1.hasSharedElements)
    XCTAssertFalse(test1.hasElementsExclusiveToSecond)
    XCTAssertTrue(test2.hasElementsExclusiveToFirst)
    XCTAssertTrue(test2.hasSharedElements)
    XCTAssertTrue(test2.hasElementsExclusiveToSecond)

    let test3 = base.overlap(withSorted: [-1, 1, 2, 4, 7, 8],
                             stoppingFor: .anythingShared)
    XCTAssertTrue(test3.hasSharedElements)
  }
}
