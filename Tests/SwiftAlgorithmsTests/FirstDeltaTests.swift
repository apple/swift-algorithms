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

/// Unit tests for the `firstDelta` methods.
final class FirstDeltaTests: XCTestCase {
  /// Check two empty sequences.
  func testEmptyVsEmpty() {
    let empty = EmptyCollection<Double>()
    let dualEmptyDelta = empty.firstDelta(against: empty)
    XCTAssertNil(dualEmptyDelta.0)
    XCTAssertNil(dualEmptyDelta.1)
  }

  /// Check an empty sequence and a non-empty one.
  func testExactlyOneEmpty() {
    let empty = EmptyCollection<Double>(), single = CollectionOfOne(1.1)
    let emptySingleDelta = empty.firstDelta(against: single)
    XCTAssertNil(emptySingleDelta.0)
    XCTAssertEqual(emptySingleDelta.1, 1.1)

    let singleEmptyDelta = single.firstDelta(against: empty)
    XCTAssertEqual(singleEmptyDelta.0, 1.1)
    XCTAssertNil(singleEmptyDelta.1)
  }

  /// Check identical non-empty sequences.
  func testIdenticalNonempty() {
    let single = CollectionOfOne(2.2)
    let dualSingleDelta = single.firstDelta(against: single)
    XCTAssertNil(dualSingleDelta.0)
    XCTAssertNil(dualSingleDelta.1)

    let multiple = [3.3, 4.4, 5.5, 6.6, 7.7]
    let dualMultipleDelta = multiple.firstDelta(against: multiple)
    XCTAssertNil(dualMultipleDelta.0)
    XCTAssertNil(dualMultipleDelta.1)
  }

  /// Check a non-empty sequence and its prefix.
  func testPrefix() {
    let short = [1.1, 2.2, 3.3], long = short + [4.4, 5.5, 6.6, 7.7]
    let shortLongDelta = short.firstDelta(against: long)
    XCTAssertNil(shortLongDelta.0)
    XCTAssertEqual(shortLongDelta.1, 4.4)

    let longShortDelta = long.firstDelta(against: short)
    XCTAssertEqual(longShortDelta.0, 4.4)
    XCTAssertNil(longShortDelta.1)
  }

  /// Check non-empty sequences with a shared prefix.
  func testSharedPrefix() {
    let sample1 = [2.2, 4.4, 6.6, 8.8], sample2 = [2.2, 4.4, 8.8, 16.16]
    let samples12Delta = sample1.firstDelta(against: sample2)
    XCTAssertEqual(samples12Delta.0, 6.6)
    XCTAssertEqual(samples12Delta.1, 8.8)
  }

  /// Check non-empty sequences with nothing in common.
  func testUnrelatedNonempty() {
    let sample1 = [2.2, 4.4, 6.6, 8.8], sample2 = [1.1, 3.3, 9.9, 27.27]
    let samples12Delta = sample1.firstDelta(against: sample2)
    XCTAssertEqual(samples12Delta.0, 2.2)
    XCTAssertEqual(samples12Delta.1, 1.1)
  }
}
