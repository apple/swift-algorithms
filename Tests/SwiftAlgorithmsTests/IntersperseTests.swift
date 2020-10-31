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

final class IntersperseTests: XCTestCase {
  func testString() {
    let interspersed = "ABCDE".interspersed(with: "-")
    XCTAssertEqualSequences(interspersed, "A-B-C-D-E")
    validateIndexTraversals(interspersed)
  }

  func testStringEmpty() {
    let interspersed = "".interspersed(with: "-")
    XCTAssertEqualSequences(interspersed, "")
    validateIndexTraversals(interspersed)
  }

  func testArray() {
    let interspersed = [1,2,3,4].interspersed(with: 0)
    XCTAssertEqualSequences(interspersed, [1,0,2,0,3,0,4])
    validateIndexTraversals(interspersed)
  }

  func testArrayEmpty() {
    let interspersed = [].interspersed(with: 0)
    XCTAssertEqualSequences(interspersed, [])
    validateIndexTraversals(interspersed)
  }

  func testCollection() {
    let interspersed = ["A","B","C","D"].interspersed(with: "-")
    XCTAssertEqual(interspersed.count, 7)
  }

  func testBidirectionalCollection() {
    let reversed = "ABCDE".interspersed(with: "-").reversed()
    XCTAssertEqualSequences(reversed, "E-D-C-B-A")
    validateIndexTraversals(reversed)
  }
}
