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

final class MergePartitionsTests: XCTestCase {
  /// Check mergers with collections shorter than 2 elements.
  func testDegenerateCases() {
    var empty = EmptyCollection<Int>()
    XCTAssertEqualSequences(empty, [])
    empty.mergePartitions(across: empty.startIndex)
    XCTAssertEqualSequences(empty, [])
    empty.mergePartitions(across: empty.endIndex)
    XCTAssertEqualSequences(empty, [])

    var single = CollectionOfOne(2)
    XCTAssertEqualSequences(single, [2])
    single.mergePartitions(across: single.startIndex)
    XCTAssertEqualSequences(single, [2])
    single.mergePartitions(across: single.endIndex)
    XCTAssertEqualSequences(single, [2])
  }

  /// Check the regular merging cases.
  func testNonThrowingCases() {
    // No sub-partitions empty.
    var sample1 = [0, 2, 4, 6, 8, 10, 1, 3, 5, 7, 9]
    sample1.mergePartitions(across: 6)
    XCTAssertEqualSequences(sample1, 0...10)

    // No pre-pivot elements less than or equal to the pivot element.
    var sample2 = [4, 6, 8, 3, 5, 7]
    sample2.mergePartitions(across: 3)
    XCTAssertEqualSequences(sample2, 3...8)

    // No pre-pivot elements greater than the pivot element.
    var sample3 = [3, 4, 5, 6, 7, 8]
    sample3.mergePartitions(across: 3)
    XCTAssertEqualSequences(sample3, 3...8)

    // The greatest elements are in the pre-pivot partition.
    var sample4 = [3, 7, 8, 9, 4, 5, 6]
    sample4.mergePartitions(across: 4)
    XCTAssertEqualSequences(sample4, 3...9)
  }

  /// Check what happens when the predicate throws.
  func testThrowingCases() {
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
    XCTAssertThrowsError(try sample5.mergePartitions(across: 1,
                                                     sortedBy: compare))

    // Interrupted comparisons.
    sample5 = [2, 2, 4, 20, 3, 3, 5, 7]
    counter = 0 ; limit = 6
    XCTAssertThrowsError(try sample5.mergePartitions(across: 4,
                                                     sortedBy: compare))
    XCTAssertEqualSequences(sample5, [2, 2, 4, 20, 3, 3, 5, 7])

    // No interruptions.
    counter = 0 ; limit = .max
    XCTAssertNoThrow(try sample5.mergePartitions(across: 4, sortedBy: compare))
    XCTAssertEqualSequences(sample5, [2, 2, 3, 3, 4, 5, 7, 20])
  }

  // MARK: - Sample Code

  // To be determined...
}
