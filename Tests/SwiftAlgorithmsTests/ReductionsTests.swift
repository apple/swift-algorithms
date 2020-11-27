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

  func testLazySequence() {
    let reductions = (1...).prefix(5).lazy.reductions(0, +)
    XCTAssertEqualSequences(reductions, [0, 1, 3, 6, 10, 15])

    let empty = (1...).prefix(0).lazy.reductions(0, +)
    XCTAssertEqualSequences(empty, [0])
  }

  func testLazyCollection() {
    let reductions = [1, 2, 3, 4, 5].lazy.reductions(0, +)
    XCTAssertEqualSequences(reductions, [0, 1, 3, 6, 10, 15])
//    validateIndexTraversals(reductions)

    let empty = EmptyCollection<Int>().lazy.reductions(0, +)
    XCTAssertEqualSequences(empty, [0])
//    validateIndexTraversals(reductions)
  }

  func testEagerInitial() {
    let reductions: [Int] = [1, 2, 3, 4, 5].reductions(0, +)
    XCTAssertEqualSequences(reductions, [0, 1, 3, 6, 10, 15])

    let empty: [Int] = EmptyCollection<Int>().reductions(0, +)
    XCTAssertEqualSequences(empty, [0])
  }

  func testEagerNoInitial() {
    let reductions: [Int] = [1, 2, 3, 4, 5].reductions(+)
    XCTAssertEqualSequences(reductions, [1, 3, 6, 10, 15])

    let empty: [Int] = EmptyCollection<Int>().reductions(+)
    XCTAssertEqualSequences(empty, [])
  }

  func testEagerThrows() {
    struct E: Error {}

    XCTAssertNoThrow(try [].reductions(0) { _, _ in throw E() })
    XCTAssertThrowsError(try [1].reductions(0) { _, _ in throw E() })

    XCTAssertNoThrow(try [].reductions { _, _ in throw E() })
    XCTAssertNoThrow(try [1].reductions { _, _ in throw E() })
    XCTAssertThrowsError(try [1, 1].reductions { _, _ in throw E() })
  }
}
