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

/// Unit tests for `sortedRange(for:)` and related binary search methods.
final class BinarySearchTests: XCTestCase {
  /// Check for empty results from an empty source.
  func testEmpty() {
    let empty = EmptyCollection<Double>()
    XCTAssertEqual(empty.sortedRange(for: 3.14), 0..<0)
  }

  /// Check when the target is too small for a single-element source.
  func testBelowSourceValue() {
    let single = CollectionOfOne(0.0)
    XCTAssertEqual(single.sortedRange(for: -1.1), 0..<0)
  }

  /// Check when the target is too large for a single-element source.
  func testAboveSourceValue() {
    let single = CollectionOfOne(0.0)
    XCTAssertEqual(single.sortedRange(for: +1.1), 1..<1)
  }

  /// Check when the target matches the sole element.
  func testOneElementOneMatch() {
    let single = CollectionOfOne(0.0)
    XCTAssertEqual(single.sortedRange(for: 0), 0..<1)
  }

  /// Check when the target matches all the elements.
  func testMultipleElementsAllMatch() {
    let repeated = repeatElement(5.5, count: 5)
    XCTAssertEqual(repeated.sortedRange(for: 5.5), 0..<5)
  }

  /// Check when the target is too small for a multiple-element source.
  func testBelowSourceValues() {
    let sample = [2.2, 3.3, 4.4]
    XCTAssertEqual(sample.sortedRange(for: 1.1), 0..<0)
  }

  /// Check when the target is too large for a multiple-element source.
  func testAboveSourceValues() {
    let sample = [2.2, 3.3, 4.4]
    XCTAssertEqual(sample.sortedRange(for: 5.5), 3..<3)
  }

  /// Check when the target fails in the middle of some values.
  func testInternalMiss() {
    let sample = [2.2, 3.3, 4.4]
    XCTAssertEqual(sample.sortedRange(for: 3.14), 1..<1)
  }

  /// Check when the target succeeds the first time within values.
  func testMultipleElementsFirstCheck() {
    let sample = [1.1, 2.2, 3.3, 4.4, 5.5]
    XCTAssertEqual(sample.sortedRange(for: 3.3), 2..<3)
  }

  /// Check when the target succeeds after some lowering.
  func testMultipleElementsNarrowDownPrefixes() {
    let sample = [1.1, 2.2, 3.3, 4.4, 5.5, 6.6, 7.7, 8.8, 9.9, 10.10, 11.11,
                  12.12, 13.13, 14.14, 15.15, 16.16, 17.17]
    XCTAssertEqual(sample.sortedRange(for: 3.3), 2..<3)
  }

  /// Check when the target succeeds after some raising.
  func testMultipleElementsNarrowDownSuffixes() {
    let sample = [1.1, 2.2, 3.3, 4.4, 5.5, 6.6, 7.7, 8.8, 9.9, 10.10, 11.11,
                  12.12, 13.13, 14.14, 15.15, 16.16, 17.17]
    XCTAssertEqual(sample.sortedRange(for: 15.15), 14..<15)
  }

  /// Check when the target succeeds after some lowering and raising.
  func testMultipleElementsJumpingAround() {
    let sample = [1.1, 2.2, 3.3, 4.4, 5.5, 6.6, 7.7, 8.8, 9.9, 10.10, 11.11,
                  12.12, 13.13, 14.14, 15.15, 16.16, 17.17]
    XCTAssertEqual(sample.sortedRange(for: 7.7), 6..<7)
    XCTAssertEqual(sample.sortedRange(for: 11.11), 10..<11)
  }
}
