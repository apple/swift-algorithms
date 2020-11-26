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

/// Unit tests for the `accumulate(via:)` and `disperse(via:)` methods.
final class AccumulateTests: XCTestCase {
  /// Check that nothing happens with empty collections.
  func testEmpty() {
    var empty = EmptyCollection<Double>()
    XCTAssertEqualSequences(empty, [])
    empty.accumulate(via: +)
    XCTAssertEqualSequences(empty, [])
    empty.disperse(via: -)
    XCTAssertEqualSequences(empty, [])
  }

  /// Check that nothing happens with one-element collections.
  func testSingle() {
    var single = CollectionOfOne(1.1)
    XCTAssertEqualSequences(single, [1.1])
    single.accumulate(via: +)
    XCTAssertEqualSequences(single, [1.1])
    single.disperse(via: -)
    XCTAssertEqualSequences(single, [1.1])
  }

  /// Check a two-element collection.
  func testDouble() {
    var sample = [5, 2]
    XCTAssertEqualSequences(sample, [5, 2])
    sample.accumulate(via: *)
    XCTAssertEqualSequences(sample, [5, 10])
    sample.disperse(via: /)
    XCTAssertEqualSequences(sample, [5, 2])
  }

  /// Check a long collection.
  func testLong() {
    var sample1 = Array(repeating: 1, count: 5)
    XCTAssertEqualSequences(sample1, repeatElement(1, count: 5))
    sample1.accumulate(via: +)
    XCTAssertEqualSequences(sample1, 1...5)
    sample1.disperse(via: -)
    XCTAssertEqualSequences(sample1, repeatElement(1, count: 5))
  }
}
