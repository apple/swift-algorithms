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

/// Unit tests for the `copy(from:)` and `copy(collection:)` methods.
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

    let result2 = empty1.copy(collection: empty2)
    XCTAssertEqual(result2.copyEnd, empty1.startIndex)
    XCTAssertEqual(result2.sourceTailStart, empty2.startIndex)
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

    let result2 = empty.copy(collection: single)
    XCTAssertEqual(result2.copyEnd, empty.startIndex)
    XCTAssertEqual(result2.sourceTailStart, single.startIndex)
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

    let result2 = single.copy(collection: empty)
    XCTAssertEqual(result2.copyEnd, single.startIndex)
    XCTAssertEqual(result2.sourceTailStart, empty.startIndex)
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

    let source2 = CollectionOfOne(5.5),
        result2 = destination.copy(collection: source2)
    XCTAssertEqual(result2.copyEnd, destination.endIndex)
    XCTAssertEqual(result2.sourceTailStart, source2.endIndex)
    XCTAssertEqualSequences(destination, [5.5])
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

    let source2 = "12345", result2 = destination.copy(collection: source2)
    XCTAssertEqual(result2.copyEnd, destination.endIndex)
    XCTAssertEqual(result2.sourceTailStart, source2.endIndex)
    XCTAssertEqualSequences(destination, "12345")
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

    let source2 = -50..<0, result2 = destination.copy(collection: source2)
    XCTAssertEqual(result2.copyEnd, destination.endIndex)
    XCTAssertEqual(result2.sourceTailStart, -45)
    XCTAssertEqualSequences(destination, (-50)...(-46))
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

    let source2 = "123", result2 = destination.copy(collection: source2)
    XCTAssertEqual(result2.copyEnd, 3)
    XCTAssertEqual(result2.sourceTailStart, source2.endIndex)
    XCTAssertEqualSequences(destination, "123QRfghijklm")
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

    let result3 = destination[3..<7].copy(collection: source)
    XCTAssertEqual(result3.copyEnd, 7)
    XCTAssertEqualSequences(source[result3.sourceTailStart...], "WXYZ")
    XCTAssertEqualSequences(destination, "abcSTUVhijklm")

    let source2 = "12", result4 = destination[3..<7].copy(collection: source2)
    XCTAssertEqual(result4.copyEnd, 5)
    XCTAssertEqual(result4.sourceTailStart, source2.endIndex)
    XCTAssertEqualSequences(destination, "abc12UVhijklm")
  }
}
