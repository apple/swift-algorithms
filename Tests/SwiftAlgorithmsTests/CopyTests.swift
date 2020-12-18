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

/// Unit tests for the `copy` and `copyOntoSuffix` methods.
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
    XCTAssertEqualSequences(empty1[..<result2.copyEnd],
                            empty2[..<result2.sourceTailStart])

    let result3 = empty1.copyOntoSuffix(with: empty2)
    XCTAssertEqual(result3.copyStart, empty1.endIndex)
    XCTAssertEqualSequences(IteratorSequence(result3.sourceTail), [])
    XCTAssertEqualSequences(empty1, [])

    let result4 = empty1.copyOntoSuffix(withCollection: empty2)
    XCTAssertEqual(result4.copyStart, empty1.endIndex)
    XCTAssertEqual(result4.sourceTailStart, empty2.startIndex)
    XCTAssertEqualSequences(empty1, [])
    XCTAssertEqualSequences(empty1[result4.copyStart...],
                            empty2[..<result4.sourceTailStart])
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
    XCTAssertEqualSequences(empty[..<result2.copyEnd],
                            single[..<result2.sourceTailStart])

    let result3 = empty.copyOntoSuffix(with: single)
    XCTAssertEqual(result3.copyStart, empty.endIndex)
    XCTAssertEqualSequences(IteratorSequence(result3.sourceTail), [1.1])
    XCTAssertEqualSequences(empty, [])

    let result4 = empty.copyOntoSuffix(withCollection: single)
    XCTAssertEqual(result4.copyStart, empty.endIndex)
    XCTAssertEqual(result4.sourceTailStart, single.startIndex)
    XCTAssertEqualSequences(empty, [])
    XCTAssertEqualSequences(empty[result4.copyStart...],
                            single[..<result4.sourceTailStart])
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
    XCTAssertEqualSequences(single[..<result2.copyEnd],
                            empty[..<result2.sourceTailStart])

    let result3 = single.copyOntoSuffix(with: empty)
    XCTAssertEqual(result3.copyStart, single.endIndex)
    XCTAssertEqualSequences(IteratorSequence(result3.sourceTail), [])
    XCTAssertEqualSequences(single, [2.2])

    let result4 = single.copyOntoSuffix(withCollection: empty)
    XCTAssertEqual(result4.copyStart, single.endIndex)
    XCTAssertEqual(result4.sourceTailStart, empty.startIndex)
    XCTAssertEqualSequences(single, [2.2])
    XCTAssertEqualSequences(single[result4.copyStart...],
                            empty[..<result4.sourceTailStart])
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
    XCTAssertEqualSequences(destination[..<result2.copyEnd],
                            source2[..<result2.sourceTailStart])

    let source3 = CollectionOfOne(6.6),
        result3 = destination.copyOntoSuffix(with: source3)
    XCTAssertEqual(result3.copyStart, destination.startIndex)
    XCTAssertEqualSequences(IteratorSequence(result3.sourceTail), [])
    XCTAssertEqualSequences(destination, [6.6])

    let source4 = CollectionOfOne(7.7),
        result4 = destination.copyOntoSuffix(withCollection: source4)
    XCTAssertEqual(result4.copyStart, destination.startIndex)
    XCTAssertEqual(result4.sourceTailStart, source4.endIndex)
    XCTAssertEqualSequences(destination, [7.7])
    XCTAssertEqualSequences(destination[result4.copyStart...],
                            source4[..<result4.sourceTailStart])
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
    XCTAssertEqualSequences(destination[..<result2.copyEnd],
                            source2[..<result2.sourceTailStart])

    let source3 = "KLMNO", result3 = destination.copyOntoSuffix(with: source3)
    XCTAssertEqual(result3.copyStart, destination.startIndex)
    XCTAssertEqualSequences(IteratorSequence(result3.sourceTail), [])
    XCTAssertEqualSequences(destination, "KLMNO")

    let source4 = "67890",
        result4 = destination.copyOntoSuffix(withCollection: source4)
    XCTAssertEqual(result4.copyStart, destination.startIndex)
    XCTAssertEqual(result4.sourceTailStart, source4.endIndex)
    XCTAssertEqualSequences(destination, "67890")
    XCTAssertEqualSequences(destination[result4.copyStart...],
                            source4[..<result4.sourceTailStart])
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
    XCTAssertEqualSequences(destination[..<result2.copyEnd],
                            source2[..<result2.sourceTailStart])

    let source3 = 200..<300, result3 = destination.copyOntoSuffix(with: source3)
    XCTAssertEqual(result3.copyStart, destination.startIndex)
    XCTAssertEqualSequences(IteratorSequence(result3.sourceTail), 205..<300)
    XCTAssertEqualSequences(destination, 200..<205)

    let source4 = -200..<0,
        result4 = destination.copyOntoSuffix(withCollection: source4)
    XCTAssertEqual(result4.copyStart, destination.startIndex)
    XCTAssertEqual(result4.sourceTailStart, -195)
    XCTAssertEqualSequences(destination, (-200)..<(-195))
    XCTAssertEqualSequences(destination[result4.copyStart...],
                            source4[..<result4.sourceTailStart])
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
    XCTAssertEqualSequences(destination[..<result2.copyEnd],
                            source2[..<result2.sourceTailStart])

    let source3 = "STUV", result3 = destination.copyOntoSuffix(with: source3)
    XCTAssertEqual(result3.copyStart, 9)
    XCTAssertEqualSequences(IteratorSequence(result3.sourceTail), [])
    XCTAssertEqualSequences(destination, "123QRfghiSTUV")

    let source4 = "45678",
        result4 = destination.copyOntoSuffix(withCollection: source4)
    XCTAssertEqual(result4.copyStart, 8)
    XCTAssertEqual(result4.sourceTailStart, source4.endIndex)
    XCTAssertEqualSequences(destination, "123QRfgh45678")
    XCTAssertEqualSequences(destination[result4.copyStart...],
                            source4[..<result4.sourceTailStart])
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
    XCTAssertEqualSequences(destination[3..<7][..<result3.copyEnd],
                            source[..<result3.sourceTailStart])

    let source2 = "12", result4 = destination[3..<7].copy(collection: source2)
    XCTAssertEqual(result4.copyEnd, 5)
    XCTAssertEqual(result4.sourceTailStart, source2.endIndex)
    XCTAssertEqualSequences(destination, "abc12UVhijklm")
    XCTAssertEqualSequences(destination[3..<7][..<result4.copyEnd],
                            source2[..<result4.sourceTailStart])

    let result5 = destination[3..<7].copyOntoSuffix(with: "34")
    XCTAssertEqual(result5.copyStart, 5)
    XCTAssertEqualSequences(IteratorSequence(result5.sourceTail), [])
    XCTAssertEqualSequences(destination, "abc1234hijklm")

    let source3 = "56",
        result6 = destination[3..<7].copyOntoSuffix(withCollection: source3)
    XCTAssertEqual(result6.copyStart, 5)
    XCTAssertEqual(result6.sourceTailStart, source3.endIndex)
    XCTAssertEqualSequences(destination, "abc1256hijklm")
    XCTAssertEqualSequences(destination[3..<7][result6.copyStart...],
                            source3[..<result6.sourceTailStart])
  }
}
