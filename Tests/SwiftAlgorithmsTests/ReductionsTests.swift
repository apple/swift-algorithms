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
    let reductions = (1...).prefix(5).reductions(excluding: 0, +)
    XCTAssertEqualSequences(reductions, [1, 3, 6, 10, 15])
  }

  func testSequenceEmpty() {
    let reductions = (1...).prefix(0).reductions(excluding: 0, +)
    XCTAssertEqualSequences(reductions, [])
  }

  func testEager() {
    let excluding: [Int] = [3, 4, 2, 3, 1].reductions(excluding: .max, min)
    XCTAssertEqualSequences(excluding, [3, 3, 2, 2, 1])
    validateIndexTraversals(excluding)

    let including: [Int] = [6, 3, 2, 4, 1].reductions(including: 10, +)
    XCTAssertEqualSequences(including, [10, 16, 19, 21, 25, 26])
    validateIndexTraversals(including)

    let noInitial: [Int] = [3, 4, 2, 3, 1].reductions(+)
    XCTAssertEqualSequences(noInitial, [3, 7, 9, 12, 13])
    validateIndexTraversals(noInitial)
  }

  func testEagerThrows() {
    struct E: Error {}
    XCTAssertNoThrow(try [].reductions(excluding: 0, { _, _ in throw E() }))
    XCTAssertThrowsError(try [1].reductions(excluding: 0, { _, _ in throw E() }))

    XCTAssertNoThrow(try [].reductions(including: 0, { _, _ in throw E() }))
    XCTAssertThrowsError(try [1].reductions(including: 0, { _, _ in throw E() }))

    XCTAssertNoThrow(try [].reductions({ _, _ in throw E() }))
    XCTAssertNoThrow(try [1].reductions({ _, _ in throw E() }))
    XCTAssertThrowsError(try [1, 1].reductions({ _, _ in throw E() }))
  }

  func testCollection() {
    let reductions = [3, 4, 2, 3, 1].reductions(excluding: .max, min)
    XCTAssertEqualSequences(reductions, [3, 3, 2, 2, 1])
    validateIndexTraversals(reductions)
  }

  func testCollectionEmpty() {
    let reductions = EmptyCollection<Int>().reductions(excluding: .max, min)
    XCTAssertEqualSequences(reductions, [])
    validateIndexTraversals(reductions)
  }
}
