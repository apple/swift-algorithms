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

/// Unit tests for the `firstDelta`, `diverges`, and `converges` methods.
final class FirstDeltaTests: XCTestCase {
  /// Check two empty sequences.
  func testEmptyVsEmpty() {
    let empty = EmptyCollection<Double>()
    let dualEmptyDelta = empty.firstDelta(against: empty)
    XCTAssertNil(dualEmptyDelta.0)
    XCTAssertNil(dualEmptyDelta.1)

    let dualEmptyDivergence = empty.diverges(from: empty)
    XCTAssertEqual(dualEmptyDivergence.0, 0)
    XCTAssertEqual(dualEmptyDivergence.1, 0)

    let dualEmptyConvergence = empty.converges(with: empty)
    XCTAssertEqual(dualEmptyConvergence.0, 0)
    XCTAssertEqual(dualEmptyConvergence.1, 0)
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

    let emptySingleDivergence = empty.diverges(from: single),
        singleEmptyDivergence = single.diverges(from: empty)
    XCTAssertEqual(emptySingleDivergence.0, empty.endIndex)
    XCTAssertEqual(emptySingleDivergence.1, single.startIndex)
    XCTAssertEqual(singleEmptyDivergence.0, single.startIndex)
    XCTAssertEqual(singleEmptyDivergence.1, empty.endIndex)

    let emptySingleConvergence = empty.converges(with: single),
        singleEmptyConvergence = single.converges(with: empty)
    XCTAssertEqual(emptySingleConvergence.0, empty.startIndex)
    XCTAssertEqual(emptySingleConvergence.1, single.endIndex)
    XCTAssertEqual(singleEmptyConvergence.0, single.endIndex)
    XCTAssertEqual(singleEmptyConvergence.1, empty.startIndex)
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

    let dualSingleDivergence = single.diverges(from: single),
        dualMultipleDivergence = multiple.diverges(from: multiple)
    XCTAssertEqual(dualSingleDivergence.0, single.endIndex)
    XCTAssertEqual(dualSingleDivergence.1, single.endIndex)
    XCTAssertEqual(dualMultipleDivergence.0, multiple.endIndex)
    XCTAssertEqual(dualMultipleDivergence.1, multiple.endIndex)

    let dualSingleConvergence = single.converges(with: single),
        dualMultipleConvergence = multiple.converges(with: multiple)
    XCTAssertEqual(dualSingleConvergence.0, single.startIndex)
    XCTAssertEqual(dualSingleConvergence.1, single.startIndex)
    XCTAssertEqual(dualMultipleConvergence.0, multiple.startIndex)
    XCTAssertEqual(dualMultipleConvergence.1, multiple.startIndex)
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

    let shortLongDivergence = short.diverges(from: long),
        longShortDivergence = long.diverges(from: short)
    XCTAssertEqual(shortLongDivergence.0, short.endIndex)
    XCTAssertEqual(shortLongDivergence.1, long.indices.dropFirst(3).first)
    XCTAssertEqual(longShortDivergence.0, long.indices.dropFirst(3).first)
    XCTAssertEqual(longShortDivergence.1, short.endIndex)
  }

  /// Check non-empty sequences with a shared prefix.
  func testSharedPrefix() {
    let sample1 = [2.2, 4.4, 6.6, 8.8], sample2 = [2.2, 4.4, 8.8, 16.16]
    let samples12Delta = sample1.firstDelta(against: sample2)
    XCTAssertEqual(samples12Delta.0, 6.6)
    XCTAssertEqual(samples12Delta.1, 8.8)

    let samples12Divergence = sample1.diverges(from: sample2)
    XCTAssertEqual(samples12Divergence.0, 2)
    XCTAssertEqual(samples12Divergence.1, 2)
  }

  /// Check non-empty sequences with nothing in common.
  func testUnrelatedNonempty() {
    let sample1 = [2.2, 4.4, 6.6, 8.8], sample2 = [1.1, 3.3, 9.9, 27.27]
    let samples12Delta = sample1.firstDelta(against: sample2)
    XCTAssertEqual(samples12Delta.0, 2.2)
    XCTAssertEqual(samples12Delta.1, 1.1)

    let samples12Divergence = sample1.diverges(from: sample2)
    XCTAssertEqual(samples12Divergence.0, sample1.startIndex)
    XCTAssertEqual(samples12Divergence.1, sample2.startIndex)

    let samples12Convergence = sample1.converges(with: sample2)
    XCTAssertEqual(samples12Convergence.0, sample1.endIndex)
    XCTAssertEqual(samples12Convergence.1, sample2.endIndex)
  }

  /// Check non-empty sequences for their suffixes.
  func testSuffixes() {
    let short = [4.4, 5.5, 6.6, 7.7], long = [1.1, 2.2, 3.3] + short
    let shortLongConvergence = short.converges(with: long),
        longShortConvergence = long.converges(with: short)
    XCTAssertEqual(shortLongConvergence.0, short.startIndex)
    XCTAssertEqual(shortLongConvergence.1, long.indices.dropFirst(3).first)
    XCTAssertEqual(longShortConvergence.0, long.indices.dropFirst(3).first)
    XCTAssertEqual(longShortConvergence.1, short.startIndex)

    let sample1 = [7.7, 9.9, 11.11, 13.13], sample2 = [5.5, 7.7, 11.11, 13.13]
    let samples12Convergence = sample1.converges(with: sample2)
    XCTAssertEqual(samples12Convergence.0, 2)
    XCTAssertEqual(samples12Convergence.1, 2)
  }
}
