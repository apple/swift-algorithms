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
@testable import Algorithms

/// Unit tests for the `deltas()` method.
final class DeltasTests: XCTestCase {
  /// Check the differences for an empty source.
  func testEmpty() {
    let empty = EmptyCollection<Int>()
    XCTAssertEqualSequences(empty.deltas(via: -), [])
  }

  /// Check the differences for a single-element source.
  func testSingle() {
    let single = CollectionOfOne(1)
    XCTAssertEqualSequences(single.deltas(via: -), [])
  }

  /// Check the differences for a two-element source.
  func testDouble() {
    XCTAssertEqualSequences([3, 12].deltas(via: /), [4])
  }

  /// Check the differences with longer sources.
  func testMoreSequences() {
    let repeats = repeatElement(5.0, count: 5)
    XCTAssertEqualSequences(repeats.deltas(via: -), [0, 0, 0, 0])
    XCTAssertEqualSequences(repeats.deltas(via: /), [1, 1, 1, 1])

    XCTAssertEqualSequences([1, 1, 2, 3, 5, 8].deltas(via: -), [0, 1, 1, 2, 3])
    XCTAssertEqualSequences([1, 1, 2, 6, 24, 120, 720, 5040].deltas(via: /),
                            [1, 2, 3, 4, 5, 6, 7])
  }
}
