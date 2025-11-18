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

final class MergeTests: XCTestCase {
  // MARK: Support Types for Set-Operation Mergers

  /// Check the convenience initializers for `MergerSubset`.
  func testMergerSubsetInitializers() {
    XCTAssertEqual(MergerSubset(), .sum)

    XCTAssertEqual(
      MergerSubset(keepExclusivesToFirst: false, keepExclusivesToSecond: false,
                   keepSharedElements: false),
      .none
    )
    XCTAssertEqual(
      MergerSubset(keepExclusivesToFirst: true, keepExclusivesToSecond: false,
                   keepSharedElements: false),
      .firstWithoutSecond
    )
    XCTAssertEqual(
      MergerSubset(keepExclusivesToFirst: false, keepExclusivesToSecond: true,
                   keepSharedElements: false),
      .secondWithoutFirst
    )
    XCTAssertEqual(
      MergerSubset(keepExclusivesToFirst: false, keepExclusivesToSecond: false,
                   keepSharedElements: true),
      .intersection
    )
    XCTAssertEqual(
      MergerSubset(keepExclusivesToFirst: true, keepExclusivesToSecond: true,
                   keepSharedElements: false),
      .symmetricDifference
    )
    XCTAssertEqual(
      MergerSubset(keepExclusivesToFirst: true, keepExclusivesToSecond: false,
                   keepSharedElements: true),
      .first
    )
    XCTAssertEqual(
      MergerSubset(keepExclusivesToFirst: false, keepExclusivesToSecond: true,
                   keepSharedElements: true),
      .second
    )
    XCTAssertEqual(
      MergerSubset(keepExclusivesToFirst: true, keepExclusivesToSecond: true,
                   keepSharedElements: true),
      .union
    )
  }

  /// Check the subset emission flags for `MergerSubset`.
  func testMergerSubsetFlags() {
    XCTAssertEqualSequences(
      MergerSubset.allCases,
      [.none, .firstWithoutSecond, .secondWithoutFirst, .symmetricDifference,
       .intersection, .first, .second, .union, .sum]
    )

    XCTAssertEqualSequences(
      MergerSubset.allCases.map(\.emitsExclusivesToFirst),
      [false, true, false, true, false, true, false, true, true]
    )
    XCTAssertEqualSequences(
      MergerSubset.allCases.map(\.emitsExclusivesToSecond),
      [false, false, true, true, false, false, true, true, true]
    )
    XCTAssertEqualSequences(
      MergerSubset.allCases.map(\.emitsSharedElements),
      [false, false, false, false, true, true, true, true, true]
    )
  }

  // MARK: - Set-Operation Mergers

  /// Test subset sequence results, no matter if lazy or eager generation.
  func mergerTests<U: Sequence>(
    converter: (Range<Int>, Range<Int>, MergerSubset) -> U
  ) where U.Element == Int {
    let first = 0..<7, second = 3..<10
    let expectedNone = EmptyCollection<Int>(), expectedFirstOnly = 0..<3,
        expectedSecondOnly = 7..<10, expectedDiff = [0, 1, 2, 7, 8, 9],
        expectedIntersection = 3..<7, expectedFirst = first,
        expectedSecond = second, expectedUnion = 0..<10,
        expectedSum = [0, 1, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 8, 9]
    do {
      let sequences = Dictionary(uniqueKeysWithValues: MergerSubset.allCases.map {
        return ($0, converter(first, second, $0))
      })
      XCTAssertEqualSequences(sequences[.none]!, expectedNone)
      XCTAssertEqualSequences(sequences[.firstWithoutSecond]!, expectedFirstOnly)
      XCTAssertEqualSequences(sequences[.secondWithoutFirst]!, expectedSecondOnly)
      XCTAssertEqualSequences(sequences[.symmetricDifference]!, expectedDiff)
      XCTAssertEqualSequences(sequences[.intersection]!, expectedIntersection)
      XCTAssertEqualSequences(sequences[.first]!, expectedFirst)
      XCTAssertEqualSequences(sequences[.second]!, expectedSecond)
      XCTAssertEqualSequences(sequences[.union]!, expectedUnion)
      XCTAssertEqualSequences(sequences[.sum]!, expectedSum)

      XCTAssertLessThanOrEqual(sequences[.none]!.underestimatedCount,
                               expectedNone.count)
      XCTAssertLessThanOrEqual(sequences[.firstWithoutSecond]!.underestimatedCount,
                               expectedFirstOnly.count)
      XCTAssertLessThanOrEqual(sequences[.secondWithoutFirst]!.underestimatedCount,
                               expectedSecondOnly.count)
      XCTAssertLessThanOrEqual(sequences[.symmetricDifference]!.underestimatedCount,
                               expectedDiff.count)
      XCTAssertLessThanOrEqual(sequences[.intersection]!.underestimatedCount,
                               expectedIntersection.count)
      XCTAssertLessThanOrEqual(sequences[.first]!.underestimatedCount,
                               expectedFirst.count)
      XCTAssertLessThanOrEqual(sequences[.second]!.underestimatedCount,
                               expectedSecond.count)
      XCTAssertLessThanOrEqual(sequences[.union]!.underestimatedCount,
                               expectedUnion.count)
      XCTAssertLessThanOrEqual(sequences[.sum]!.underestimatedCount,
                               expectedSum.count)
    }

    do {
      // This exercises code missed by the `sequences` tests.
      let flipped = Dictionary(uniqueKeysWithValues: MergerSubset.allCases.map {
        return ($0, converter(second, first, $0))
      })
      XCTAssertEqualSequences(flipped[.none]!, expectedNone)
      XCTAssertEqualSequences(flipped[.firstWithoutSecond]!, expectedSecondOnly)
      XCTAssertEqualSequences(flipped[.secondWithoutFirst]!, expectedFirstOnly)
      XCTAssertEqualSequences(flipped[.symmetricDifference]!, expectedDiff)
      XCTAssertEqualSequences(flipped[.intersection]!, expectedIntersection)
      XCTAssertEqualSequences(flipped[.first]!, expectedSecond)
      XCTAssertEqualSequences(flipped[.second]!, expectedFirst)
      XCTAssertEqualSequences(flipped[.union]!, expectedUnion)
      XCTAssertEqualSequences(flipped[.sum]!, expectedSum)
    }

  }

  /// Check the lazily-generated subset sequences.
  func testLazySetMergers() {
    mergerTests(converter: { lazilyMerge($0, $1, keeping: $2) })
  }

  /// Check the eagerly-generated subset sequences.
  func testEagerSetMergers() {
    mergerTests(converter: { merge($0, $1, keeping: $2) })
  }

  // MARK: - Sample Code

  /// Check the code from documentation.
  func testSampleCode() {
    // From the guide.
    do {
      let merged = lazilyMerge([10, 4, 0, 0, -3], [20, 6, 1, -1, -5],
                               keeping: .sum, sortedBy: >)
      XCTAssertEqualSequences(merged, [20, 10, 6, 4, 1, 0, 0, -1, -3, -5])
    }

    do {
      let first = [0, 1, 1, 2, 5, 10], second = [-1, 0, 1, 2, 2, 7, 10, 20]
      XCTAssertEqualSequences(merge(first, second, keeping: .union),
                              [-1, 0, 1, 1, 2, 2, 5, 7, 10, 20])
      XCTAssertEqualSequences(merge(first, second, keeping: .intersection),
                              [0, 1, 2, 10])
      XCTAssertEqualSequences(merge(first, second, keeping: .secondWithoutFirst),
                              [-1, 2, 7, 20])
      XCTAssertEqualSequences(merge(first, second, keeping: .sum),
                              [-1, 0, 0, 1, 1, 1, 2, 2, 2, 5, 7, 10, 10, 20])
    }
  }
}
