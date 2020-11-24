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

  func testBidirectionalCollection() {
    let reversed = [1,2,3,4,5].reductions(0, +).reversed()
    XCTAssertEqualSequences(reversed, [15, 10, 6, 3, 1])
    validateIndexTraversals(reversed)
  }
}
