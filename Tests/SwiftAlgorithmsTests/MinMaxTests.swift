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

final class SortedPrefixTests: XCTestCase {
  func testMaxCount() {
    // Replacement at startIndex
    let input = [0, 11, 12, 1, 13, 2, 14, 3, 4, 5, 6, 7, 8, 9]
    let max = input.max(count: 5)
    XCTAssertEqual(max, [9, 11, 12, 13, 14])

    // Replacement at endIndex
    let max2 = (input + [15]).max(count: 5)
    XCTAssertEqual(max2, [11, 12, 13, 14, 15])

    // Stability with all equal values
    let zeroes = Array(repeating: 0, count: 100)
    let maxZeroes = Array(zeroes.enumerated()).max(count: 5, sortedBy: { $0.1 < $1.1 })
    XCTAssertEqualSequences(maxZeroes.map { $0.0 }, 95..<100)
  }
  
  func testEmpty() {
    let array = [Int]()
    XCTAssertEqual(array.min(count: 0), [])
  }

  func testSortedPrefixWithOrdering() {
    let array: [Int] = [20, 1, 4, 70, 100, 2, 3, 7, 90]

    XCTAssertEqual(array.min(count: 0, sortedBy: >), [])
    XCTAssertEqual(
      array.min(count: 1, sortedBy: >),
      [100]
    )

    XCTAssertEqual(
      array.min(count: 5, sortedBy: >),
      [100, 90, 70, 20, 7]
    )

    XCTAssertEqual(
      array.min(count: 9, sortedBy: >),
      [100, 90, 70, 20, 7, 4, 3, 2, 1]
    )

    XCTAssertEqual([1].min(count: 0, sortedBy: <), [])
    XCTAssertEqual([1].min(count: 0, sortedBy: >), [])
    XCTAssertEqual([1].min(count: 1, sortedBy: <), [1])
    XCTAssertEqual([1].min(count: 1, sortedBy: >), [1])
    XCTAssertEqual([0, 1].min(count: 1, sortedBy: <), [0])
    XCTAssertEqual([1, 0].min(count: 1, sortedBy: <), [0])
    XCTAssertEqual([1, 0].min(count: 2, sortedBy: <), [0, 1])
    XCTAssertEqual([0, 1].min(count: 1, sortedBy: >), [1])
    XCTAssertEqual([1, 0].min(count: 1, sortedBy: >), [1])
    XCTAssertEqual([1, 0].min(count: 2, sortedBy: >), [1, 0])

    XCTAssertEqual(
      [1, 2, 3, 4, 7, 20, 70, 90, 100].min(count: 5, sortedBy: <),
      [1, 2, 3, 4, 7]
    )

    XCTAssertEqual(
      [1, 2, 3, 4, 7, 20, 70, 90, 100].min(count: 5, sortedBy: >),
      [100, 90, 70, 20, 7]
    )

    XCTAssertEqual(
      [1, 2, 3, 4, 7, 20, 70, 90, 100].min(count: 5, sortedBy: >),
      [100, 90, 70, 20, 7]
    )

    XCTAssertEqual(
      [1, 2, 3, 4, 7, 20, 70, 90, 100].min(count: 5, sortedBy: <),
      [1, 2, 3, 4, 7]
    )

    XCTAssertEqual(
      [4, 5, 6, 1, 2, 3].min(count: 3, sortedBy: <),
      [1, 2, 3]
    )

    XCTAssertEqual(
      [4, 5, 9, 8, 7, 6].min(count: 3, sortedBy: <),
      [4, 5, 6]
    )

    XCTAssertEqual(
      [4, 3, 2, 1].min(count: 1, sortedBy: <),
      [1]
    )

    XCTAssertEqual(
      [4, 2, 1, 3].min(count: 3, sortedBy: >),
      [4, 3, 2]
    )

    XCTAssertEqual(
      [4, 2, 1, 3].min(count: 3, sortedBy: <),
      [1, 2, 3]
    )
  }

  func testSortedPrefixComparable() {
    let array: [Int] = [20, 1, 4, 70, 100, 2, 3, 7, 90]

    XCTAssertEqual(array.min(count: 0), [])

    XCTAssertEqual(
      array.min(count: 1),
      [1]
    )

    XCTAssertEqual(
      array.min(count: 5),
      [1, 2, 3, 4, 7]
    )

    XCTAssertEqual(
      array.min(count: 9),
      [1, 2, 3, 4, 7, 20, 70, 90, 100]
    )
  }
  
  func testSortedPrefixWithHugePrefix() {
    XCTAssertEqual(
      [4, 2, 1, 3].min(count: .max),
      [1, 2, 3, 4]
    )
  }

  func testSortedPrefixWithHugeInput() {
    let input = (1...1000).shuffled()

    XCTAssertEqual(
      input.min(count: 0, sortedBy: <),
      []
    )

    XCTAssertEqual(
      input.min(count: 0, sortedBy: >),
      []
    )

    XCTAssertEqual(
      input.min(count: 1, sortedBy: <),
      [1]
    )

    XCTAssertEqual(
      input.min(count: 1, sortedBy: >),
      [1000]
    )

    XCTAssertEqual(
      input.min(count: 5, sortedBy: <),
      [1, 2, 3, 4, 5]
    )

    XCTAssertEqual(
      input.min(count: 5, sortedBy: >),
      [1000, 999, 998, 997, 996]
    )

    XCTAssertEqual(
      input.min(count: 10, sortedBy: <),
      [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    )

    XCTAssertEqual(
      input.min(count: 10, sortedBy: >),
      [1000, 999, 998, 997, 996, 995, 994, 993, 992, 991]
    )

    XCTAssertEqual(
      input.min(count: 50, sortedBy: <),
      Array((1...50))
    )

    XCTAssertEqual(
      input.min(count: 50, sortedBy: >),
      Array((1...1000).reversed().prefix(50))
    )

    XCTAssertEqual(
      input.min(count: 250, sortedBy: <),
      Array((1...250))
    )

    XCTAssertEqual(
      input.min(count: 250, sortedBy: >),
      Array((1...1000).reversed().prefix(250))
    )

    XCTAssertEqual(
      input.min(count: 500, sortedBy: <),
      Array((1...500))
    )

    XCTAssertEqual(
      input.min(count: 500, sortedBy: >),
      Array((1...1000).reversed().prefix(500))
    )

    XCTAssertEqual(
      input.min(count: 750, sortedBy: <),
      Array((1...750))
    )

    XCTAssertEqual(
      input.min(count: 750, sortedBy: >),
      Array((1...1000).reversed().prefix(750))
    )

    XCTAssertEqual(
      input.min(count: 1000, sortedBy: <),
      Array((1...1000))
    )

    XCTAssertEqual(
      input.min(count: 1000, sortedBy: >),
      (1...1000).reversed()
    )

    XCTAssertEqual(
      ([0] + Array(repeating: 1, count: 100)).min(count: 1, sortedBy: <),
      [0]
    )

    XCTAssertEqual(
      ([1] + Array(repeating: 0, count: 100)).min(count: 1, sortedBy: <),
      [0]
    )

    XCTAssertEqual(
      ([0] + Array(repeating: 1, count: 100)).min(count: 2, sortedBy: <),
      [0, 1]
    )

    XCTAssertEqual(
      ([1] + Array(repeating: 0, count: 100)).min(count: 2, sortedBy: <),
      [0, 0]
    )

    XCTAssertEqual(
      ([1] + Array(repeating: 1, count: 100)).min(count: 1, sortedBy: >),
      [1]
    )

    XCTAssertEqual(
      ([0] + Array(repeating: 1, count: 100)).min(count: 1, sortedBy: >),
      [1]
    )

    XCTAssertEqual(
      ([1] + Array(repeating: 0, count: 100)).min(count: 2, sortedBy: >),
      [1, 0]
    )

    XCTAssertEqual(
      ([0] + Array(repeating: 1, count: 100)).min(count: 2, sortedBy: >),
      [1, 1]
    )
  }

  func testStability() {
    assertStability([1,1,1,2,5,7,3,6,2,5,7,3,6], withPrefix: 3)
    assertStability([1,1,1,2,5,7,3,6,2,5,7,3,6], withPrefix: 6)
    assertStability([1,1,1,2,5,7,3,6,2,5,7,3,6], withPrefix: 20)
    assertStability([1,1,1,2,5,7,3,6,2,5,7,3,6], withPrefix: 1000)
    assertStability(Array(repeating: 0, count: 100), withPrefix: 0)
    assertStability(Array(repeating: 0, count: 100), withPrefix: 1)
    assertStability(Array(repeating: 0, count: 100), withPrefix: 2)
    assertStability(Array(repeating: 0, count: 100), withPrefix: 5)
    assertStability(Array(repeating: 0, count: 100), withPrefix: 20)
    assertStability(Array(repeating: 0, count: 100), withPrefix: 100)
    assertStability(Array(repeating: 1, count: 50) + Array(repeating: 0, count: 50), withPrefix: 2)
    assertStability(Array(repeating: 1, count: 50) + Array(repeating: 0, count: 50), withPrefix: 5)
    assertStability(Array(repeating: 1, count: 50) + Array(repeating: 0, count: 50), withPrefix: 20)
    assertStability(Array(repeating: 1, count: 50) + Array(repeating: 0, count: 50), withPrefix: 50)
    assertStability([0,0], withPrefix: 1)
    assertStability([0,0], withPrefix: 2)
    assertStability([0,1,0,1,0,1], withPrefix: 2)
    assertStability([0,1,0,1,0,1], withPrefix: 6)
    assertStability([0,0,0,1,1,1], withPrefix: 1)
    assertStability([0,0,0,1,1,1], withPrefix: 3)
    assertStability([0,0,0,1,1,1], withPrefix: 4)
    assertStability([0,0,0,1,1,1], withPrefix: 6)
    assertStability([1,1,1,0,0,0], withPrefix: 1)
    assertStability([1,1,1,0,0,0], withPrefix: 3)
    assertStability([1,1,1,0,0,0], withPrefix: 4)
    assertStability([1,1,1,0,0,0], withPrefix: 6)
    assertStability([1,1,1,0,0,0], withPrefix: 5)
  }

  func assertStability(
    _ actual: [Int],
    withPrefix prefixCount: Int
  ) {
    let indexed = actual.enumerated()
    let sorted = Array(indexed).min(count: prefixCount) { $0.element < $1.element }

    for element in Set(actual) {
      let filtered = sorted.filter { $0.element == element }.map(\.offset)
      XCTAssertEqual(filtered, filtered.sorted())
    }
  }
}
