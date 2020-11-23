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

/// Unit tests for the `deltas()` eager and lazy methods.
final class DeltasTests: XCTestCase {
  /// Check the differences for an empty source.
  func testEmpty() {
    let empty = EmptyCollection<Int>()
    XCTAssertEqualSequences(empty.deltas(via: -), [])

    let emptyDeltas = empty.lazy.deltas(via: -)
    XCTAssertEqual(emptyDeltas.underestimatedCount, 0)
    XCTAssertEqualSequences(emptyDeltas, [])

    XCTAssertTrue(emptyDeltas.isEmpty)
  }

  /// Check the differences for a single-element source.
  func testSingle() {
    let single = CollectionOfOne(1)
    XCTAssertEqualSequences(single.deltas(via: -), [])

    let singleDeltas = single.lazy.deltas(via: -)
    XCTAssertEqual(singleDeltas.underestimatedCount, 0)
    XCTAssertEqualSequences(singleDeltas, [])

    XCTAssertTrue(singleDeltas.isEmpty)
  }

  /// Check the differences for a two-element source.
  func testDouble() {
    let sample = [3, 12]
    XCTAssertEqualSequences(sample.deltas(via: /), [4])

    let sampleDeltas = sample.lazy.deltas(via: /)
    XCTAssertEqual(sampleDeltas.underestimatedCount, 1)
    XCTAssertEqualSequences(sampleDeltas, [4])

    XCTAssertFalse(sampleDeltas.isEmpty)
    XCTAssertEqual(sampleDeltas.count, 1)
    XCTAssertEqualSequences(sampleDeltas.indices.lazy.map { sampleDeltas[$0] },
                            [4])
    XCTAssertEqualSequences(sampleDeltas.indices.reversed().map {
      sampleDeltas[$0]
    }, [4])
  }

  /// Check the differences with longer sources.
  func testMoreSequences() {
    let repeats = repeatElement(5.0, count: 5)
    XCTAssertEqualSequences(repeats.deltas(via: -), [0, 0, 0, 0])
    XCTAssertEqualSequences(repeats.deltas(via: /), [1, 1, 1, 1])

    let repeatsSubDeltas = repeats.lazy.deltas(via: -),
        repeatsDivDeltas = repeats.lazy.deltas(via: /)
    XCTAssertEqual(repeatsSubDeltas.underestimatedCount, 4)
    XCTAssertEqual(repeatsDivDeltas.underestimatedCount, 4)
    XCTAssertEqualSequences(repeatsSubDeltas, [0, 0, 0, 0])
    XCTAssertEqualSequences(repeatsDivDeltas, [1, 1, 1, 1])

    XCTAssertFalse(repeatsSubDeltas.isEmpty)
    XCTAssertEqual(repeatsSubDeltas.count, 4)
    XCTAssertEqualSequences(repeatsSubDeltas.indices.map {
      repeatsSubDeltas[$0]
    }, [0, 0, 0, 0])
    XCTAssertEqualSequences(repeatsSubDeltas.indices.reversed().map {
      repeatsSubDeltas[$0]
    }, [0, 0, 0, 0])

    XCTAssertFalse(repeatsDivDeltas.isEmpty)
    XCTAssertEqual(repeatsDivDeltas.count, 4)
    XCTAssertEqualSequences(repeatsDivDeltas.indices.map {
      repeatsDivDeltas[$0]
    }, [1, 1, 1, 1])
    XCTAssertEqualSequences(repeatsDivDeltas.indices.reversed().map {
      repeatsDivDeltas[$0]
    }, [1, 1, 1, 1])

    let fibonacci = [1, 1, 2, 3, 5, 8],
        factorials = [1, 1, 2, 6, 24, 120, 720, 5040]
    XCTAssertEqualSequences(fibonacci.deltas(via: -), [0, 1, 1, 2, 3])
    XCTAssertEqualSequences(factorials.deltas(via: /), 1...7)

    let fibonacciDeltas = fibonacci.lazy.deltas(via: -),
        factorialDeltas = factorials.lazy.deltas(via: /)
    XCTAssertEqual(fibonacciDeltas.underestimatedCount, 5)
    XCTAssertEqual(factorialDeltas.underestimatedCount, 7)
    XCTAssertEqualSequences(fibonacciDeltas, [0, 1, 1, 2, 3])
    XCTAssertEqualSequences(factorialDeltas, 1...7)

    XCTAssertFalse(factorialDeltas.isEmpty)
    XCTAssertTrue(factorialDeltas[factorialDeltas.endIndex...].isEmpty)
    XCTAssertEqualSequences(factorialDeltas.prefix(3), 1...3)
    XCTAssertEqual(factorialDeltas.distance(from: 1, to: 4), 3)
    XCTAssertNil(factorialDeltas.index(4, offsetBy: +100,
                                       limitedBy: factorialDeltas.endIndex))
    XCTAssertNil(factorialDeltas.index(4, offsetBy: -100,
                                       limitedBy: factorialDeltas.startIndex))
  }

  /// Check that `distance` works in both directions across the banned index.
  func testMoreDistance() {
    let sample = 0..<10, sampleDeltas = sample.lazy.deltas(via: -)
    XCTAssertEqualSequences(sampleDeltas, repeatElement(1, count: 9))
    XCTAssertEqual(sampleDeltas.distance(from: 2, to: 10), +7)  // Not +8
    XCTAssertEqual(sampleDeltas.distance(from: 10, to: 2), -7)  // Not -8
    XCTAssertEqual(sampleDeltas.distance(from: 10, to: 10), 0)
    XCTAssertEqual(sampleDeltas.distance(from: 3, to: 7), +4)
    XCTAssertEqual(sampleDeltas.distance(from: 7, to: 3), -4)
  }
}
