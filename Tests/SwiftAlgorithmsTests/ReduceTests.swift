//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift Algorithms open source project
//
// Copyright (c) 2026 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

import Algorithms
import XCTest

final class ReduceTests: XCTestCase {
  struct TestError: Error {}

  func testReduce() {
    XCTAssertEqual([1, 2, 3, 4].reduce(+), 10)
    XCTAssertEqual([4].reduce(+), 4)
    XCTAssertNil(EmptyCollection<Int>().reduce(+))

    // matches the final element of the corresponding reductions
    let sequence = [3, 1, 4, 1, 5]
    XCTAssertEqual(sequence.reduce(+), sequence.reductions(+).last)
  }

  func testReduceNonCommutative() {
    // combines left-to-right, seeded with the first element
    XCTAssertEqual([100, 10, 5].reduce(-), 85)
    XCTAssertEqual(["a", "b", "c"].reduce(+), "abc")
  }

  func testReduceSinglePassSequence() {
    // consumes a single-pass sequence exactly once
    XCTAssertEqual((1...).prefix(4).reduce(+), 10)
  }

  func testReduceThrows() {
    XCTAssertThrowsError(
      try [1, 2].reduce { _, _ in throw TestError() }
    )

    // the closure is never called for empty or single-element sequences
    XCTAssertNil(try EmptyCollection<Int>().reduce { _, _ in throw TestError() })
    XCTAssertEqual(try [7].reduce { _, _ in throw TestError() }, 7)
  }
}
