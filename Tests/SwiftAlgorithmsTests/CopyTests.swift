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

/// Unit tests for the `copy(from:)` method.
final class CopyTests: XCTestCase {
  /// Test empty source and destination.
  func testBothEmpty() {
    var empty1 = EmptyCollection<Double>()
    let empty2 = EmptyCollection<Double>()
    XCTAssertEqualSequences(empty1, [])

    let result = empty1.copy(from: empty2)
    XCTAssertEqual(result.copyEnd, empty1.startIndex)
    XCTAssertEqualSequences(IteratorSequence(result.sourceTail), [])
    XCTAssertEqualSequences(empty1, [])
  }

  /// Test nonempty source and empty destination.
  func testOnlyDestinationEmpty() {
    var empty = EmptyCollection<Double>()
    let single = CollectionOfOne(1.1)
    XCTAssertEqualSequences(empty, [])

    let result = empty.copy(from: single)
    XCTAssertEqual(result.copyEnd, empty.endIndex)
    XCTAssertEqualSequences(IteratorSequence(result.sourceTail), [1.1])
    XCTAssertEqualSequences(empty, [])
  }

  /// Test empty source and nonempty destination.
  func testOnlySourceEmpty() {
    var single = CollectionOfOne(2.2)
    let empty = EmptyCollection<Double>()
    XCTAssertEqualSequences(single, [2.2])

    let result = single.copy(from: empty)
    XCTAssertEqual(result.copyEnd, single.startIndex)
    XCTAssertEqualSequences(IteratorSequence(result.sourceTail), [])
    XCTAssertEqualSequences(single, [2.2])
  }

  /// Test two one-element collections.
  func testTwoSingles() {
    var destination = CollectionOfOne(3.3)
    let source = CollectionOfOne(4.4)
    XCTAssertEqualSequences(destination, [3.3])

    let result = destination.copy(from: source)
    XCTAssertEqual(result.copyEnd, destination.endIndex)
    XCTAssertEqualSequences(IteratorSequence(result.sourceTail), [])
    XCTAssertEqualSequences(destination, [4.4])
  }

  /// Test two equal-length multi-element collections.
  func testTwoWithEqualLength() {
    var destination = Array("ABCDE")
    let source = "fghij"
    XCTAssertEqualSequences(destination, "ABCDE")

    let result = destination.copy(from: source)
    XCTAssertEqual(result.copyEnd, destination.endIndex)
    XCTAssertEqualSequences(IteratorSequence(result.sourceTail), [])
    XCTAssertEqualSequences(destination, "fghij")
  }

  /// Test a source longer than a multi-element destination.
  func testLongerDestination() {
    var destination = Array(1...5)
    let source = 10...100
    XCTAssertEqualSequences(destination, 1...5)

    let result = destination.copy(from: source)
    XCTAssertEqual(result.copyEnd, destination.endIndex)
    XCTAssertEqualSequences(IteratorSequence(result.sourceTail), 15...100)
    XCTAssertEqualSequences(destination, 10..<15)
  }

  /// Test a multi-element source shorter than the destination.
  func testShorterDestination() {
    var destination = Array("abcdefghijklm")
    let source = "NOPQR"
    XCTAssertEqualSequences(destination, "abcdefghijklm")

    let result = destination.copy(from: source)
    XCTAssertEqual(result.copyEnd, destination.index(destination.startIndex,
                                                 offsetBy: source.count))
    XCTAssertEqualSequences(IteratorSequence(result.sourceTail), [])
    XCTAssertEqualSequences(destination, "NOPQRfghijklm")
  }

  /// Test copying over part of the destination.
  func testPartial() {
    var destination = Array("abcdefghijklm")
    let source = "STUVWXYZ"
    XCTAssertEqualSequences(destination, "abcdefghijklm")

    let result = destination[3..<7].copy(from: source)
    XCTAssertEqual(result.copyEnd, 7)
    XCTAssertEqualSequences(IteratorSequence(result.sourceTail), "WXYZ")
    XCTAssertEqualSequences(destination, "abcSTUVhijklm")

    let result2 = destination[3..<7].copy(from: "12")
    XCTAssertEqual(result2.copyEnd, 5)
    XCTAssertEqualSequences(IteratorSequence(result2.sourceTail), [])
    XCTAssertEqualSequences(destination, "abc12UVhijklm")
  }
}
