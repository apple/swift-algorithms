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

final class ScanTests: XCTestCase {
  func testSequence() {
    let scan = (1...).prefix(5).scan(0, +)
    XCTAssertEqualSequences(scan, [1, 3, 6, 10, 15])
  }

  func testSequenceEmpty() {
    let scan = (1...).prefix(0).scan(0, +)
    XCTAssertEqualSequences(scan, [])
  }

  func testCollection() {
    let scan = [3, 4, 2, 3, 1].scan(.max, min)
    XCTAssertEqualSequences(scan, [3, 3, 2, 2, 1])
    validateIndexTraversals(scan)
  }

  func testCollectionEmpty() {
    let scan = EmptyCollection<Int>().scan(.max, min)
    XCTAssertEqualSequences(scan, [])
    validateIndexTraversals(scan)
  }

  func testBidirectionalCollection() {
    let reversed = [1,2,3,4,5].scan(0, +).reversed()
    XCTAssertEqualSequences(reversed, [15, 10, 6, 3, 1])
    validateIndexTraversals(reversed)
  }
}
