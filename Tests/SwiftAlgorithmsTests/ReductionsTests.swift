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
    XCTAssertEqualSequences(reductions, [1, 3, 6, 10, 15])
  }

  func testLazySequenceEmpty() {
    let reductions = (1...).prefix(0).lazy.reductions(0, +)
    XCTAssertEqualSequences(reductions, [])
  }

  func testLazyCollection() {
    let reductions = [3, 4, 2, 3, 1].lazy.reductions(.max, min)
    XCTAssertEqualSequences(reductions, [3, 3, 2, 2, 1])
//    validateIndexTraversals(reductions)
  }

  func testLazyCollectionEmpty() {
    let reductions = EmptyCollection<Int>().lazy.reductions(.max, min)
    XCTAssertEqualSequences(reductions, [])
//    validateIndexTraversals(reductions)
  }

  func testEager() {
    let initial: [Int] = [6, 3, 2, 4, 1].reductions(10, +)
    XCTAssertEqualSequences(initial, [10, 16, 19, 21, 25, 26])
    validateIndexTraversals(initial)

    let noInitial: [Int] = [3, 4, 2, 3, 1].reductions(+)
    XCTAssertEqualSequences(noInitial, [3, 7, 9, 12, 13])
    validateIndexTraversals(noInitial)
  }

  func testEagerThrows() {
    struct E: Error {}
    XCTAssertNoThrow(try [].reductions(0, { _, _ in throw E() }))
    XCTAssertThrowsError(try [1].reductions(0, { _, _ in throw E() }))

    XCTAssertNoThrow(try [].reductions({ _, _ in throw E() }))
    XCTAssertNoThrow(try [1].reductions({ _, _ in throw E() }))
    XCTAssertThrowsError(try [1, 1].reductions({ _, _ in throw E() }))
  }
}
