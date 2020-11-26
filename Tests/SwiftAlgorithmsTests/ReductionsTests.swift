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

final class ReductionsTests: XCTestCase {
  func testSequence() {
    let reductions = (1...).prefix(5).reductions(0, +)
    XCTAssertEqualSequences(reductions, [1, 3, 6, 10, 15])
  }

  func testSequenceEmpty() {
    let reductions = (1...).prefix(0).reductions(0, +)
    XCTAssertEqualSequences(reductions, [])
  }

  func testEager() {
    let reductions: [Int] = [3, 4, 2, 3, 1].reductions(.max, min)
    XCTAssertEqualSequences(reductions, [3, 3, 2, 2, 1])
    validateIndexTraversals(reductions)

    let including: [Int] = [6, 3, 2, 4, 1].reductions(including: 10, +)
    XCTAssertEqualSequences(including, [10, 16, 19, 21, 25, 26])
    validateIndexTraversals(including)
  }

  func testEagerThrows() {
    struct E: Error {}
    XCTAssertNoThrow(try [].reductions(0, { _, _ in throw E() }))
    XCTAssertThrowsError(try [1].reductions(0, { _, _ in throw E() }))

    XCTAssertNoThrow(try [].reductions(including: 0, { _, _ in throw E() }))
    XCTAssertThrowsError(try [1].reductions(including: 0, { _, _ in throw E() }))
  }

  func testCollection() {
    let reductions = [3, 4, 2, 3, 1].reductions(.max, min)
    XCTAssertEqualSequences(reductions, [3, 3, 2, 2, 1])
    validateIndexTraversals(reductions)
  }

  func testCollectionEmpty() {
    let reductions = EmptyCollection<Int>().reductions(.max, min)
    XCTAssertEqualSequences(reductions, [])
    validateIndexTraversals(reductions)
  }
}
