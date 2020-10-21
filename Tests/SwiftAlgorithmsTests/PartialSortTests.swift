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

final class PartialSortTests: XCTestCase {
  func testEmpty() {
    let array = [Int]()
    XCTAssertEqual(array.sortedPrefix(0), [])
  }

  func testSortedPrefixWithOrdering() {
    let array: [Int] = [20, 1, 4, 70, 100, 2, 3, 7, 90]

    XCTAssertEqual(array.sortedPrefix(0, by: >), [])
    XCTAssertEqual(
      array.sortedPrefix(1, by: >),
      [100]
    )

    XCTAssertEqual(
      array.sortedPrefix(5, by: >),
      [100, 90, 70, 20, 7]
    )

    XCTAssertEqual(
      array.sortedPrefix(9, by: >),
      [100, 90, 70, 20, 7, 4, 3, 2, 1]
    )

    XCTAssertEqual([1].sortedPrefix(0, by: <), [])
    XCTAssertEqual([1].sortedPrefix(0, by: >), [])
    XCTAssertEqual([1].sortedPrefix(1, by: <), [1])
    XCTAssertEqual([1].sortedPrefix(1, by: >), [1])
    XCTAssertEqual([0, 1].sortedPrefix(1, by: <), [0])
    XCTAssertEqual([1, 0].sortedPrefix(1, by: <), [0])
    XCTAssertEqual([1, 0].sortedPrefix(2, by: <), [0, 1])
    XCTAssertEqual([0, 1].sortedPrefix(1, by: >), [1])
    XCTAssertEqual([1, 0].sortedPrefix(1, by: >), [1])
    XCTAssertEqual([1, 0].sortedPrefix(2, by: >), [1, 0])

    XCTAssertEqual(
      [1, 2, 3, 4, 7, 20, 70, 90, 100].sortedPrefix(5, by: <),
      [1, 2, 3, 4, 7]
    )

    XCTAssertEqual(
      [1, 2, 3, 4, 7, 20, 70, 90, 100].sortedPrefix(5, by: >),
      [100, 90, 70, 20, 7]
    )

    XCTAssertEqual(
      [1, 2, 3, 4, 7, 20, 70, 90, 100].sortedPrefix(5, by: >),
      [100, 90, 70, 20, 7]
    )

    XCTAssertEqual(
      [1, 2, 3, 4, 7, 20, 70, 90, 100].sortedPrefix(5, by: <),
      [1, 2, 3, 4, 7]
    )

    XCTAssertEqual(
      [4, 5, 6, 1, 2, 3].sortedPrefix(3, by: <),
      [1, 2, 3]
    )

    XCTAssertEqual(
      [4, 5, 9, 8, 7, 6].sortedPrefix(3, by: <),
      [4, 5, 6]
    )

    XCTAssertEqual(
      [4, 3, 2, 1].sortedPrefix(1, by: <),
      [1]
    )

    XCTAssertEqual(
      [4, 2, 1, 3].sortedPrefix(3, by: >),
      [4, 3, 2]
    )

    XCTAssertEqual(
      [4, 2, 1, 3].sortedPrefix(3, by: <),
      [1, 2, 3]
    )
  }

  func testSortedPrefixComparable() {
    let array: [Int] = [20, 1, 4, 70, 100, 2, 3, 7, 90]

    XCTAssertEqual(array.sortedPrefix(0), [])

    XCTAssertEqual(
      array.sortedPrefix(1),
      [1]
    )

    XCTAssertEqual(
      array.sortedPrefix(5),
      [1, 2, 3, 4, 7]
    )

    XCTAssertEqual(
      array.sortedPrefix(9),
      [1, 2, 3, 4, 7, 20, 70, 90, 100]
    )
  }
}
