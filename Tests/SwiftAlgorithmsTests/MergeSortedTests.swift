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

final class MergeSortedTests: XCTestCase {
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

  /// Check the lazily-generated merger/subset sequences.
  func testLazyMergers() {
    let low = 0..<7, high = 3..<10
    XCTAssertEqualSequences(mergeSorted(low, high),
                            [0, 1, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 8, 9])
    XCTAssertLazySequence(mergeSorted(low, high))

    let sequences = Dictionary(uniqueKeysWithValues: MergerSubset.allCases.map {
      ($0, mergeSorted(low, high, retaining: $0))
    })
    XCTAssertEqualSequences(sequences[.none]!, EmptyCollection())
    XCTAssertEqualSequences(sequences[.firstWithoutSecond]!, 0..<3)
    XCTAssertEqualSequences(sequences[.secondWithoutFirst]!, 7..<10)
    XCTAssertEqualSequences(sequences[.symmetricDifference]!, [0, 1, 2, 7, 8, 9])
    XCTAssertEqualSequences(sequences[.intersection]!, 3..<7)
    XCTAssertEqualSequences(sequences[.first]!, low)
    XCTAssertEqualSequences(sequences[.second]!, high)
    XCTAssertEqualSequences(sequences[.union]!, 0..<10)
    XCTAssertEqualSequences(sequences[.sum]!, [0, 1, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 8, 9])

    XCTAssertLessThanOrEqual(sequences[.none]!.underestimatedCount, 0)
    XCTAssertLessThanOrEqual(sequences[.firstWithoutSecond]!.underestimatedCount, 3)
    XCTAssertLessThanOrEqual(sequences[.secondWithoutFirst]!.underestimatedCount, 3)
    XCTAssertLessThanOrEqual(sequences[.symmetricDifference]!.underestimatedCount, 6)
    XCTAssertLessThanOrEqual(sequences[.intersection]!.underestimatedCount, 4)
    XCTAssertLessThanOrEqual(sequences[.first]!.underestimatedCount, 7)
    XCTAssertLessThanOrEqual(sequences[.second]!.underestimatedCount, 7)
    XCTAssertLessThanOrEqual(sequences[.union]!.underestimatedCount, 7)
    XCTAssertLessThanOrEqual(sequences[.sum]!.underestimatedCount, 14)

    // This exercises code missed by the `sequences` tests.
    let reversed = Dictionary(uniqueKeysWithValues: MergerSubset.allCases.map {
      ($0, mergeSorted(high, low, retaining: $0))
    })
    XCTAssertEqualSequences(reversed[.none]!, EmptyCollection())
    XCTAssertEqualSequences(reversed[.firstWithoutSecond]!, 7..<10)
    XCTAssertEqualSequences(reversed[.secondWithoutFirst]!, 0..<3)
    XCTAssertEqualSequences(reversed[.symmetricDifference]!, [0, 1, 2, 7, 8, 9])
    XCTAssertEqualSequences(reversed[.intersection]!, 3..<7)
    XCTAssertEqualSequences(reversed[.first]!, high)
    XCTAssertEqualSequences(reversed[.second]!, low)
    XCTAssertEqualSequences(reversed[.union]!, 0..<10)
    XCTAssertEqualSequences(reversed[.sum]!, [0, 1, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 8, 9])
  }

  /// Check the eager merger/subset sequences.
  func testEagerMergers() {
    let low = 0..<7, high = 3..<10
    XCTAssertEqualSequences(Array(mergeSorted: low, and: high),
                            [0, 1, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 8, 9])

    let sequences = Dictionary(uniqueKeysWithValues: MergerSubset.allCases.map {
      ($0, Array(mergeSorted: low, and: high, retaining: $0))
    })
    XCTAssertEqualSequences(sequences[.none]!, EmptyCollection())
    XCTAssertEqualSequences(sequences[.firstWithoutSecond]!, 0..<3)
    XCTAssertEqualSequences(sequences[.secondWithoutFirst]!, 7..<10)
    XCTAssertEqualSequences(sequences[.symmetricDifference]!, [0, 1, 2, 7, 8, 9])
    XCTAssertEqualSequences(sequences[.intersection]!, 3..<7)
    XCTAssertEqualSequences(sequences[.first]!, low)
    XCTAssertEqualSequences(sequences[.second]!, high)
    XCTAssertEqualSequences(sequences[.union]!, 0..<10)
    XCTAssertEqualSequences(sequences[.sum]!, [0, 1, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 8, 9])
  }

  /// Check the more-memory version of merging two sorted partitions.
  func testFastPartitionMerge() {
    // Degenerate count of elements.
    var empty = EmptyCollection<Int>(), single = CollectionOfOne(1)
    XCTAssertEqualSequences(empty, [])
    XCTAssertEqualSequences(single, [1])
    empty.mergeSortedPartitions(across: empty.startIndex)
    single.mergeSortedPartitions(across: single.startIndex)
    XCTAssertEqualSequences(empty, [])
    XCTAssertEqualSequences(single, [1])

    // Each side has multiple elements.
    let low = 0..<7, high = 3..<10, pivot = low.count
    var multiple = Array(chain(low, high))
    XCTAssertEqualSequences(multiple, [0, 1, 2, 3, 4, 5, 6, 3, 4, 5, 6, 7, 8, 9])
    multiple.mergeSortedPartitions(across: pivot)
    XCTAssertEqualSequences(multiple, [0, 1, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 8, 9])
  }
}
