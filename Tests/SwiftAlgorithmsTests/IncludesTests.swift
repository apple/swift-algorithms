//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift Algorithms open source project
//
// Copyright (c) 2024 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

import XCTest
import Algorithms

final class IncludesTests: XCTestCase {
  /// Check if one empty set includes another.
  func testBothSetsEmpty() {
    XCTAssertTrue(EmptyCollection<Int>().includes(sorted: EmptyCollection()))
  }

  /// Check if a non-empty set contains an empty one.
  func testNonemptyIncludesEmpty() {
    XCTAssertTrue(CollectionOfOne(2).includes(sorted: EmptyCollection()))
  }

  /// Check if an empty set contains a non-empty one.
  func testEmptyIncludesNonempty() {
    XCTAssertFalse(EmptyCollection().includes(sorted: CollectionOfOne(2)))
  }

  /// Check for inclusion between disjoint (non-empty) sets.
  func testDisjointSets() {
    XCTAssertFalse("abc".includes(sorted: "DEF"))
  }

  /// Check if a non-empty set includes an identical one.
  func testIdenticalSets() {
    XCTAssertTrue([0, 1, 2, 3].includes(sorted: 0..<4))
  }

  /// Check if a set includes a strict non-empty subset.
  func testStrictSubset() {
    XCTAssertTrue([0, 1, 2, 3].includes(sorted: 1..<3))
    XCTAssertTrue([0, 1, 2, 3].includes(sorted: 0..<2))
    XCTAssertTrue([0, 1, 2, 3].includes(sorted: 2..<4))
  }

  /// Check if a non-empty set incudes a strict superset.
  func testStrictSuperset() {
    XCTAssertFalse([0, 1, 2, 3].includes(sorted: -1..<5))
    XCTAssertFalse([0, 1, 2, 3].includes(sorted: -1..<4))
    XCTAssertFalse([0, 1, 2, 3].includes(sorted:  0..<5))
  }

  /// Check if a non-empty set includes another that shares just some elements.
  func testOverlap() {
    XCTAssertFalse([0, 1, 2, 3].includes(sorted:  2..<5))
    XCTAssertFalse([0, 1, 2, 3].includes(sorted: -1..<2))
  }
}
