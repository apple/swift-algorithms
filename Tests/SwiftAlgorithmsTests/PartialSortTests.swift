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

    XCTAssertEqual(array.partiallySorted(0), [])
  }

  func testPartialSortComparable() {
    let array: [Int] = [20, 1, 4, 70, 100, 2, 3, 7, 90]

    XCTAssertEqual(array.partiallySorted(0), array)

    XCTAssertEqual(
      array.partiallySorted(1),
      [1, 90, 4, 70, 100, 7, 3, 2, 20]
    )

    XCTAssertEqual(
      array.partiallySorted(5),
      [1, 2, 3, 4, 7, 90, 70, 20, 100]
    )

    XCTAssertEqual(
      array.partiallySorted(9),
      [1, 2, 3, 4, 7, 20, 70, 90, 100]
    )
  }

  func testPartialSortComparableWithCustomPriority() {
    let array: [Int] = [20, 1, 4, 70, 100, 2, 3, 7, 90]

    XCTAssertEqual(array.partiallySorted(0, by: >), array)
    XCTAssertEqual(
      array.partiallySorted(1, by: >),
      [100, 1, 4, 3, 7, 20, 70, 90, 2]
    )

    XCTAssertEqual(
      array.partiallySorted(5, by: >),
      [100, 90, 70, 20, 7, 2, 4, 3, 1]
    )

    XCTAssertEqual(
      array.partiallySorted(9, by: >),
      [100, 90, 70, 20, 7, 4, 3, 2, 1]
    )
  }

  func testPartialSortInPlaceComparable() {
    let originalArray: [Int] = [20, 1, 4, 70, 100, 2, 3, 7, 90]
    var array = originalArray

    array.partiallySort(0)
    XCTAssertEqual(array, originalArray)

    array = originalArray

    array.partiallySort(1)
    XCTAssertEqual(
      array,
      [1, 90, 4, 70, 100, 7, 3, 2, 20]
    )

    array = originalArray

    array.partiallySort(5)
    XCTAssertEqual(
      array,
      [1, 2, 3, 4, 7, 90, 70, 20, 100]
    )

    array = originalArray

    array.partiallySort(9)
    XCTAssertEqual(
      array,
      [1, 2, 3, 4, 7, 20, 70, 90, 100]
    )
  }

  func testPartialSortDescendingArray() {
    let array: [Int] = [100, 90, 70, 20, 7, 4, 3, 2, 1]

    XCTAssertEqual(array.partiallySorted(9, by: >), array)
  }

  func testPartialSortAscendingArray() {
    let array: [Int] = [1, 2, 3, 4, 7, 20, 70, 90, 100]

    XCTAssertEqual(array.partiallySorted(9, by: <), array)
  }
}
