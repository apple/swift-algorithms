//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift Algorithms open source project
//
// Copyright (c) 2021 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

import XCTest
import Algorithms

final class AdjacentPairsTests: XCTestCase {
  func testEmptySequence() {
    let pairs = (0...).prefix(0).adjacentPairs()
    XCTAssertEqualSequences(pairs, [], by: ==)
  }
  
  func testOneElementSequence() {
    let pairs = (0...).prefix(1).adjacentPairs()
    XCTAssertEqualSequences(pairs, [], by: ==)
  }
  
  func testTwoElementSequence() {
    let pairs = (0...).prefix(2).adjacentPairs()
    XCTAssertEqualSequences(pairs, [(0, 1)], by: ==)
  }
  
  func testThreeElementSequence() {
    let pairs = (0...).prefix(3).adjacentPairs()
    XCTAssertEqualSequences(pairs, [(0, 1), (1, 2)], by: ==)
  }
  
  func testManySequences() {
    for n in 4...100 {
      let pairs = (0...).prefix(n).adjacentPairs()
      XCTAssertEqualSequences(pairs, zip(0..., 1...).prefix(n - 1), by: ==)
    }
  }
  
  func testZeroElements() {
    let pairs = (0..<0).adjacentPairs()
    XCTAssertEqual(pairs.startIndex, pairs.endIndex)
    XCTAssertEqualSequences(pairs, [], by: ==)
  }

  func testOneElement() {
    let pairs = (0..<1).adjacentPairs()
    XCTAssertEqual(pairs.startIndex, pairs.endIndex)
    XCTAssertEqualSequences(pairs, [], by: ==)
  }

  func testTwoElements() {
    let pairs = (0..<2).adjacentPairs()
    XCTAssertEqualSequences(pairs, [(0, 1)], by: ==)
  }

  func testThreeElements() {
    let pairs = (0..<3).adjacentPairs()
    XCTAssertEqualSequences(pairs, [(0, 1), (1, 2)], by: ==)
  }

  func testManyElements() {
    for n in 4...100 {
      let pairs = (0..<n).adjacentPairs()
      XCTAssertEqualSequences(pairs, zip(0..., 1...).prefix(n - 1), by: ==)
    }
  }

  func testIndexTraversals() {
    let validator = IndexValidator<AdjacentPairsCollection<Range<Int>>>()
    validator.validate((0..<0).adjacentPairs(), expectedCount: 0)
    validator.validate((0..<1).adjacentPairs(), expectedCount: 0)
    validator.validate((0..<2).adjacentPairs(), expectedCount: 1)
    validator.validate((0..<5).adjacentPairs(), expectedCount: 4)
  }
  
  func testLaziness() {
    XCTAssertLazySequence((0...).lazy.adjacentPairs())
    XCTAssertLazyCollection((0..<100).lazy.adjacentPairs())
  }
}
