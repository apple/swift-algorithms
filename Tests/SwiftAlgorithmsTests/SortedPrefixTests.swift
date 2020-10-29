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

/// Unit tests for `sortedEndIndex` and `rampedEndIndex`.
final class SortedPrefixTests: XCTestCase {
  /// Check that empty sequences are always increasing.
  func testEmpty() {
    let empty = EmptyCollection<Double>()
    XCTAssertEqual(empty.sortedEndIndex(), empty.endIndex)
    XCTAssertEqual(empty.rampedEndIndex(), empty.endIndex)
    XCTAssertEqual(empty.firstVariance(), empty.endIndex)
  }

  /// Check that single-element sequences are always increasing.
  func testSingleElement() {
    let single = CollectionOfOne(1.1)
    XCTAssertEqual(single.sortedEndIndex(), single.endIndex)
    XCTAssertEqual(single.rampedEndIndex(), single.endIndex)
    XCTAssertEqual(single.firstVariance(), single.endIndex)
  }

  /// Test for failures at second element.
  func testFailSecond() {
    let sample = [4.4, -2.2, 0, 5.5]
    XCTAssertEqual(sample.sortedEndIndex(), sample.dropFirst().startIndex)
    XCTAssertEqual(sample.rampedEndIndex(), sample.dropFirst().startIndex)
    XCTAssertEqual(sample.firstVariance(), sample.dropFirst().startIndex)
  }

  /// Test for failures after the second element.
  func testFailAfterElementIteration() {
    let sample = [-2.2, 4.4, 0, 5.5]
    XCTAssertEqual(sample.sortedEndIndex(), sample.dropFirst(2).startIndex)
    XCTAssertEqual(sample.rampedEndIndex(), sample.dropFirst(2).startIndex)
  }

  /// Check that unchanging sequences are always sorted, but never increase.
  func testSteadyState() {
    let repeated = repeatElement(5.5, count: 5)
    XCTAssertEqual(repeated.sortedEndIndex(), repeated.endIndex)
    XCTAssertEqual(repeated.rampedEndIndex(), repeated.dropFirst().startIndex)
    XCTAssertEqual(repeated.firstVariance(), repeated.endIndex)
  }

  /// Check that a range is always increasing.
  func testRange() {
    let range = -10...10
    XCTAssertEqual(range.sortedEndIndex(), range.endIndex)
    XCTAssertEqual(range.rampedEndIndex(), range.endIndex)
  }
}
