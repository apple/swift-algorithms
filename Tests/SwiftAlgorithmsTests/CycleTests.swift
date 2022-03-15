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

final class CycleTests: XCTestCase {
  func testCycle() {
    let cycle = (1...4).cycled()
    XCTAssertEqualSequences(
      [1, 2, 3, 4, 1, 2, 3, 4, 1, 2, 3, 4, 1, 2, 3, 4, 1, 2, 3, 4],
      cycle.prefix(20)
    )
  }

  func testCycleClosedRangePrefix() {
    let a = Array((0..<17).cycled().prefix(10_000))
    XCTAssertEqual(10_000, a.count)
  }

  func testEmptyCycle() {
    let empty = Array("".cycled())
    XCTAssert(empty.isEmpty)
  }

  func testCycleLazy() {
    XCTAssertLazySequence((1...4).lazy.cycled())
  }

  func testRepeated() {
    let repeats = (1...4).cycled(times: 3)
    XCTAssertEqualSequences(
      [1, 2, 3, 4, 1, 2, 3, 4, 1, 2, 3, 4],
      repeats)
  }

  func testRepeatedClosedRange() {
    let repeats = Array((1..<5).cycled(times: 2500))
    XCTAssertEqual(10_000, repeats.count)
  }

  func testRepeatedEmptyCollection() {
    let empty1 = Array("".cycled(times: 100))
    XCTAssert(empty1.isEmpty)
  }

  func testRepeatedZeroTimesCycle() {
    let empty2 = Array("Hello".cycled(times: 0))
    XCTAssert(empty2.isEmpty)
  }

  func testRepeatedLazy() {
    XCTAssertLazySequence((1...4).lazy.cycled(times: 3))
  }

  func testRepeatedIndexMethods() {
    let cycle = (1..<5).cycled(times: 2)
    let startIndex = cycle.startIndex
    var nextIndex = cycle.index(after: startIndex)
    XCTAssertEqual(cycle.distance(from: startIndex, to: nextIndex), 1)

    nextIndex = cycle.index(nextIndex, offsetBy: 5)
    XCTAssertEqual(cycle.distance(from: startIndex, to: nextIndex), 6)

    nextIndex = cycle.index(nextIndex, offsetBy: 2, limitedBy: cycle.endIndex)!
    XCTAssertEqual(cycle.distance(from: startIndex, to: nextIndex), 8)

    let outOfBounds = cycle.index(nextIndex, offsetBy: 1,
                                  limitedBy: cycle.endIndex)
    XCTAssertNil(outOfBounds)

    let previousIndex = cycle.index(before: nextIndex)
    XCTAssertEqual(cycle.distance(from: startIndex, to: previousIndex), 7)
  }

  func testRepeatedCount() {
    let cycle = (1..<5).cycled(times: 2)
    XCTAssertEqual(cycle.count, 8)
  }
}
