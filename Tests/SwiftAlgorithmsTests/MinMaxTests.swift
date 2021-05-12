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
  func testMinCount() {
    // Replacement at start and end
    let input = [10, 11, 12, 1, 13, 2, 14, 3, 4, 5, 6, 0, 7, 8, 9]
    let min = input.min(count: 5)
    XCTAssertEqualSequences(min, 0..<5)

    // Stability with all equal values
    let maxZeroes = Array(repeating: 0, count: 100)
      .enumerated()
      .max(count: 5, sortedBy: { $0.element < $1.element })
    XCTAssertEqualSequences(maxZeroes.map { $0.offset }, 95..<100)
  }
  
  func testMaxCount() {
    // Replacement at start and end
    let input = [0, 11, 12, 1, 13, 2, 14, 3, 4, 5, 6, 7, 8, 9, 10]
    let max = input.max(count: 5)
    XCTAssertEqualSequences(max, 10..<15)

    // Stability with all equal values
    let maxZeroes = Array(repeating: 0, count: 100)
      .enumerated()
      .max(count: 5, sortedBy: { $0.element < $1.element })
    XCTAssertEqualSequences(maxZeroes.map { $0.offset }, 95..<100)
  }
  
  func testEmpty() {
    let array = [Int]()
    XCTAssertEqual(array.min(count: 0), [])
    XCTAssertEqual(array.min(count: 100), [])
    
    XCTAssertEqual(array.max(count: 0), [])
    XCTAssertEqual(array.max(count: 100), [])
  }

  func testMinMaxSequences() {
    let input = (1...100).shuffled().interspersed(with: 50)
    let seq = AnySequence(input)
    
    XCTAssertEqualSequences(seq.min(count: 0), [])
    XCTAssertEqualSequences(seq.min(count: 5), 1...5)
    
    XCTAssertEqualSequences(seq.max(count: 0), [])
    XCTAssertEqualSequences(seq.max(count: 5), 96...100)
  }
  
  func testSortedPrefixComparable() {
    let array: [Int] = [20, 1, 4, 70, 100, 2, 3, 7, 90]

    XCTAssertEqual(array.min(count: 0), [])
    XCTAssertEqual(array.min(count: 1), [1])
    XCTAssertEqualSequences(array.min(count: 5), array.sorted().prefix(5))
    XCTAssertEqual(array.min(count: 10), array.sorted())
  }
  
  func testMinMaxWithHugeCount() {
    XCTAssertEqual([4, 2, 1, 3].min(count: .max), [1, 2, 3, 4])
    XCTAssertEqual([4, 2, 1, 3].max(count: .max), [1, 2, 3, 4])
  }

  func testMinCountWithHugeInput() {
    let range = 1...1000
    let input = range.shuffled()

    XCTAssertEqual(input.min(count: 0, sortedBy: <), [])
    XCTAssertEqual(input.min(count: 0, sortedBy: >), [])

    XCTAssertEqual(input.min(count: 1, sortedBy: <), [range.lowerBound])
    XCTAssertEqual(input.min(count: 1, sortedBy: >), [range.upperBound])

    XCTAssertEqualSequences(input.min(count: 5, sortedBy: <), range.prefix(5))
    XCTAssertEqualSequences(
      input.min(count: 5, sortedBy: >),
      range.suffix(5).reversed())

    XCTAssertEqualSequences(
      input.min(count: 500, sortedBy: <),
      range.prefix(500))
    XCTAssertEqualSequences(
      input.min(count: 500, sortedBy: >),
      range.suffix(500).reversed())

    XCTAssertEqualSequences(input.min(count: 1000, sortedBy: <), range)
    XCTAssertEqualSequences(
      input.min(count: 1000, sortedBy: >),
      range.reversed())
  }

  func testMaxCountWithHugeInput() {
    let range = 1...1000
    let input = range.shuffled()

    XCTAssertEqual(input.max(count: 0, sortedBy: <), [])
    XCTAssertEqual(input.max(count: 0, sortedBy: >), [])

    XCTAssertEqual(input.max(count: 1, sortedBy: <), [range.upperBound])
    XCTAssertEqual(input.max(count: 1, sortedBy: >), [range.lowerBound])

    XCTAssertEqualSequences(input.max(count: 5, sortedBy: <), range.suffix(5))
    XCTAssertEqualSequences(
      input.max(count: 5, sortedBy: >),
      range.prefix(5).reversed())

    XCTAssertEqualSequences(
      input.max(count: 500, sortedBy: <),
      range.suffix(500))
    XCTAssertEqualSequences(
      input.max(count: 500, sortedBy: >),
      range.prefix(500).reversed())

    XCTAssertEqualSequences(input.max(count: 1000, sortedBy: <), range)
    XCTAssertEqualSequences(
      input.max(count: 1000, sortedBy: >),
      range.reversed())
  }

  func testStability() {
    assertStability([1,1,1,2,5,7,3,6,2,5,7,3,6], withCount: 3)
    assertStability([1,1,1,2,5,7,3,6,2,5,7,3,6], withCount: 6)
    assertStability([1,1,1,2,5,7,3,6,2,5,7,3,6], withCount: 20)
    assertStability([1,1,1,2,5,7,3,6,2,5,7,3,6], withCount: 1000)
    assertStability(Array(repeating: 0, count: 100), withCount: 0)
    assertStability(Array(repeating: 0, count: 100), withCount: 1)
    assertStability(Array(repeating: 0, count: 100), withCount: 2)
    assertStability(Array(repeating: 0, count: 100), withCount: 5)
    assertStability(Array(repeating: 0, count: 100), withCount: 20)
    assertStability(Array(repeating: 0, count: 100), withCount: 100)
    assertStability(Array(repeating: 1, count: 50) + Array(repeating: 0, count: 50), withCount: 2)
    assertStability(Array(repeating: 1, count: 50) + Array(repeating: 0, count: 50), withCount: 5)
    assertStability(Array(repeating: 1, count: 50) + Array(repeating: 0, count: 50), withCount: 20)
    assertStability(Array(repeating: 1, count: 50) + Array(repeating: 0, count: 50), withCount: 50)
    assertStability([0,0], withCount: 1)
    assertStability([0,0], withCount: 2)
    assertStability([0,1,0,1,0,1], withCount: 2)
    assertStability([0,1,0,1,0,1], withCount: 6)
    assertStability([0,0,0,1,1,1], withCount: 1)
    assertStability([0,0,0,1,1,1], withCount: 3)
    assertStability([0,0,0,1,1,1], withCount: 4)
    assertStability([0,0,0,1,1,1], withCount: 6)
    assertStability([1,1,1,0,0,0], withCount: 1)
    assertStability([1,1,1,0,0,0], withCount: 3)
    assertStability([1,1,1,0,0,0], withCount: 4)
    assertStability([1,1,1,0,0,0], withCount: 6)
    assertStability([1,1,1,0,0,0], withCount: 5)
  }

  func assertStability(
    _ actual: [Int],
    withCount count: Int
  ) {
    func stableOrder(
      a: (offset: Int, element: Int),
      b: (offset: Int, element: Int)) -> Bool
    {
      a.element == b.element
        ? a.offset < b.offset
        : a.element < b.element
    }
    
    do {
      let sorted = actual.enumerated()
        .min(count: count) { $0.element < $1.element }
      XCTAssert(sorted.isSorted(by: stableOrder))
    }
    
    do {
      let sorted = actual.enumerated()
        .max(count: count) { $0.element < $1.element }
      XCTAssert(sorted.isSorted(by: stableOrder))
    }
  }
}

final class MinAndMaxTests: XCTestCase {
  /// Confirms that empty sequences yield no results.
  func testEmpty() {
    XCTAssertNil(EmptyCollection<Int>().minAndMax())
  }

  /// Confirms the same element is used when there is only one.
  func testSingleElement() {
    let result = CollectionOfOne(2).minAndMax()
    XCTAssertEqual(result?.min, 2)
    XCTAssertEqual(result?.max, 2)
  }

  /// Confirms the same value is used when all the elements have it.
  func testSingleValueMultipleElements() {
    let result = repeatElement(3.3, count: 5).minAndMax()
    XCTAssertEqual(result?.min, 3.3)
    XCTAssertEqual(result?.max, 3.3)

    // Even count
    let result2 = repeatElement("c" as Character, count: 6).minAndMax()
    XCTAssertEqual(result2?.min, "c")
    XCTAssertEqual(result2?.max, "c")
  }

  /// Confirms when the minimum value is constantly updated, but the maximum
  /// never is.
  func testRampDown() {
    let result = (1...5).reversed().minAndMax()
    XCTAssertEqual(result?.min, 1)
    XCTAssertEqual(result?.max, 5)

    // Even count
    let result2 = "fedcba".minAndMax()
    XCTAssertEqual(result2?.min, "a")
    XCTAssertEqual(result2?.max, "f")
  }

  /// Confirms when the maximum value is constantly updated, but the minimum
  /// never is.
  func testRampUp() {
    let result = (1...5).minAndMax()
    XCTAssertEqual(result?.min, 1)
    XCTAssertEqual(result?.max, 5)

    // Even count
    let result2 = "abcdef".minAndMax()
    XCTAssertEqual(result2?.min, "a")
    XCTAssertEqual(result2?.max, "f")
  }

  /// Confirms when the maximum and minimum change during a run.
  func testUpsAndDowns() {
    let result = [4, 3, 3, 5, 2, 0, 7, 6].minAndMax()
    XCTAssertEqual(result?.min, 0)
    XCTAssertEqual(result?.max, 7)

    // Odd count
    let result2 = "gfabdec".minAndMax()
    XCTAssertEqual(result2?.min, "a")
    XCTAssertEqual(result2?.max, "g")
  }

  /// Confirms that the given predicate is used to find the min/max.
  func testPredicate() {
    let result = (1...5).minAndMax(by: >)
    XCTAssertEqual(result?.min, 5)
    XCTAssertEqual(result?.max, 1)

    // Odd count
    let result2 = "gfabdec".minAndMax(by: >)
    XCTAssertEqual(result2?.min, "g")
    XCTAssertEqual(result2?.max, "a")
  }

  /// Confirms that the min and max are "stable" as defined for minAndMax.
  func testStability() {
    for n in 1...10 {
      let result = repeatElement(0, count: n)
        .enumerated()
        .minAndMax(by: { $0.element < $1.element })
      XCTAssertEqual(result?.min.offset, 0)
      XCTAssertEqual(result?.max.offset, n - 1)
    }
  }
}
