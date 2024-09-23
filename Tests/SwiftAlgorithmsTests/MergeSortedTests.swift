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

  /// Check the lazily-generated subset sequences.
  func testLazySetMergers() {
    let low = 0..<7, high = 3..<10
    let sequences = Dictionary(uniqueKeysWithValues: MergerSubset.allCases.map {
      return ($0, mergeSortedSets(low, high, retaining: $0))
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
      ($0, mergeSortedSets(high, low, retaining: $0))
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

  /// Check the eagerly-generated subset sequences.
  func testEagerSetMergers() {
    let low = 0..<7, high = 3..<10
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

  // MARK: - Direct Mergers

  /// Check lazily-generated mergers.
  func testLazyMergers() {
    let low = 0..<7, high = 3..<10, result = mergeSorted(low, high)
    XCTAssertEqualSequences(result, [0, 1, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 8, 9])
  }

  /// Check eagerly-generated mergers.
  func testEagerMergers() {
    let low = 0..<7, high = 3..<10, result = Array(mergeSorted: low, and: high)
    XCTAssertEqualSequences(result, [0, 1, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 8, 9])
  }

  /// Test mergers for any number of arguments (one day).
  @available(macOS 13.0.0, *)
  func testMoreMergers() {
    let low = 0..<7, high = 3..<10,
    result = MergeSortedSequence(low, high, sortedBy: <)
    XCTAssertEqualSequences(result, [0, 1, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 8, 9])
  }

  // MARK: - Partition Mergers

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

  /// Check the in-place version of merging two sorted partitions.
  func testSlowPartitionMerge() {
    // Degenerate cases.
    var empty = EmptyCollection<Int>()
    XCTAssertEqualSequences(empty, [])
    empty.mergeSortedPartitionsInPlace(across: empty.startIndex)
    XCTAssertEqualSequences(empty, [])
    empty.mergeSortedPartitionsInPlace(across: empty.endIndex)
    XCTAssertEqualSequences(empty, [])

    var single = CollectionOfOne(2)
    XCTAssertEqualSequences(single, [2])
    single.mergeSortedPartitionsInPlace(across: single.startIndex)
    XCTAssertEqualSequences(single, [2])
    single.mergeSortedPartitionsInPlace(across: single.endIndex)
    XCTAssertEqualSequences(single, [2])

    // No sub-partitions empty.
    var sample1 = [0, 2, 4, 6, 8, 10, 1, 3, 5, 7, 9]
    sample1.mergeSortedPartitionsInPlace(across: 6)
    XCTAssertEqualSequences(sample1, 0...10)

    // No pre-pivot elements less than or equal to the pivot element.
    var sample2 = [4, 6, 8, 3, 5, 7]
    sample2.mergeSortedPartitionsInPlace(across: 3)
    XCTAssertEqualSequences(sample2, 3...8)

    // No pre-pivot elements greater than the pivot element.
    var sample3 = [3, 4, 5, 6, 7, 8]
    sample3.mergeSortedPartitionsInPlace(across: 3)
    XCTAssertEqualSequences(sample3, 3...8)

    // The greatest elements are in the pre-pivot partition.
    var sample4 = [3, 7, 8, 9, 4, 5, 6]
    sample4.mergeSortedPartitionsInPlace(across: 4)
    XCTAssertEqualSequences(sample4, 3...9)

    /// An error type.
    enum MyError: Error {
      /// An error state.
      case anError
    }

    // Test throwing.
    var sample5 = [5, 3], counter = 0, limit = 1
    let compare: (Int, Int) throws -> Bool = {
      guard counter < limit else { throw MyError.anError }
      defer { counter += 1 }

      return $0 < $1
    }
    XCTAssertThrowsError(try sample5.mergeSortedPartitionsInPlace(across: 1, sortedBy: compare))

    sample5 = [2, 2, 4, 20, 3, 3, 5, 7]
    counter = 0 ; limit = 6
    XCTAssertThrowsError(try sample5.mergeSortedPartitionsInPlace(across: 4, sortedBy: compare))
    XCTAssertEqualSequences(sample5, [2, 2, 4, 20, 3, 3, 5, 7])
    counter = 0 ; limit = .max
    XCTAssertNoThrow(try sample5.mergeSortedPartitionsInPlace(across: 4, sortedBy: compare))
    XCTAssertEqualSequences(sample5, [2, 2, 3, 3, 4, 5, 7, 20])
  }

  // MARK: - Sample Code

  /// Check the code from documentation.
  func testSampleCode() {
    // From the guide.
    let guide1 = [10, 4, 0, 0, -3], guide2 = [20, 6, 1, -1, -5]
    let mergedGuides = mergeSorted(guide1, guide2, sortedBy: >)
    XCTAssertEqualSequences(mergedGuides, [20, 10, 6, 4, 1, 0, 0, -1, -3, -5])

    let guide3 = [0, 1, 1, 2, 5, 10], guide4 = [-1, 0, 1, 2, 2, 7, 10, 20]
    XCTAssertEqualSequences(mergeSortedSets(guide3, guide4, retaining: .union),
                            [-1, 0, 1, 1, 2, 2, 5, 7, 10, 20])
    XCTAssertEqualSequences(mergeSortedSets(guide3, guide4, retaining: .intersection),
                            [0, 1, 2, 10])
    XCTAssertEqualSequences(mergeSortedSets(guide3, guide4, retaining: .firstWithoutSecond),
                            [1, 5])
    XCTAssertEqualSequences(mergeSortedSets(guide3, guide4, retaining: .secondWithoutFirst),
                            [-1, 2, 7, 20])
    XCTAssertEqualSequences(mergeSortedSets(guide3, guide4, retaining: .symmetricDifference),
                            [-1, 1, 2, 5, 7, 20])
    XCTAssertEqualSequences(mergeSortedSets(guide3, guide4, retaining: .sum),
                            [-1, 0, 0, 1, 1, 1, 2, 2, 2, 5, 7, 10, 10, 20])
  }
}
