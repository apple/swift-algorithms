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

/// Unit tests for the `copy` methods.
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

    let result3 = empty1.copy(asSuffix: empty2)
    XCTAssertEqual(result3.copyStart, empty1.endIndex)
    XCTAssertEqualSequences(IteratorSequence(result3.sourceTail), [])
    XCTAssertEqualSequences(empty1, [])

    let result4 = empty1.copy(collectionAsSuffix: empty2)
    XCTAssertEqual(result4.copyStart, empty1.endIndex)
    XCTAssertEqual(result4.sourceTailStart, empty2.startIndex)
    XCTAssertEqualSequences(empty1, [])
    XCTAssertEqualSequences(empty1[result4.copyStart...],
                            empty2[..<result4.sourceTailStart])

    let result5 = empty1.copy(backwards: empty2)
    XCTAssertEqual(result5.writtenStart, empty1.endIndex)
    XCTAssertEqual(result5.readStart, empty2.endIndex)
    XCTAssertEqualSequences(empty1, [])
    XCTAssertEqualSequences(empty1[result5.writtenStart...],
                            empty2[result5.readStart...])
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

    let result3 = empty.copy(asSuffix: single)
    XCTAssertEqual(result3.copyStart, empty.endIndex)
    XCTAssertEqualSequences(IteratorSequence(result3.sourceTail), [1.1])
    XCTAssertEqualSequences(empty, [])

    let result4 = empty.copy(collectionAsSuffix: single)
    XCTAssertEqual(result4.copyStart, empty.endIndex)
    XCTAssertEqual(result4.sourceTailStart, single.startIndex)
    XCTAssertEqualSequences(empty, [])
    XCTAssertEqualSequences(empty[result4.copyStart...],
                            single[..<result4.sourceTailStart])

    let result5 = empty.copy(backwards: single)
    XCTAssertEqual(result5.writtenStart, empty.endIndex)
    XCTAssertEqual(result5.readStart, single.endIndex)
    XCTAssertEqualSequences(empty, [])
    XCTAssertEqualSequences(empty[result5.writtenStart...],
                            single[result5.readStart...])
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

    let result3 = single.copy(asSuffix: empty)
    XCTAssertEqual(result3.copyStart, single.endIndex)
    XCTAssertEqualSequences(IteratorSequence(result3.sourceTail), [])
    XCTAssertEqualSequences(single, [2.2])

    let result4 = single.copy(collectionAsSuffix: empty)
    XCTAssertEqual(result4.copyStart, single.endIndex)
    XCTAssertEqual(result4.sourceTailStart, empty.startIndex)
    XCTAssertEqualSequences(single, [2.2])
    XCTAssertEqualSequences(single[result4.copyStart...],
                            empty[..<result4.sourceTailStart])

    let result5 = single.copy(backwards: empty)
    XCTAssertEqual(result5.writtenStart, single.endIndex)
    XCTAssertEqual(result5.readStart, empty.endIndex)
    XCTAssertEqualSequences(single, [2.2])
    XCTAssertEqualSequences(single[result5.writtenStart...],
                            empty[result5.readStart...])
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
        result3 = destination.copy(asSuffix: source3)
    XCTAssertEqual(result3.copyStart, destination.startIndex)
    XCTAssertEqualSequences(IteratorSequence(result3.sourceTail), [])
    XCTAssertEqualSequences(destination, [6.6])

    let source4 = CollectionOfOne(7.7),
        result4 = destination.copy(collectionAsSuffix: source4)
    XCTAssertEqual(result4.copyStart, destination.startIndex)
    XCTAssertEqual(result4.sourceTailStart, source4.endIndex)
    XCTAssertEqualSequences(destination, [7.7])
    XCTAssertEqualSequences(destination[result4.copyStart...],
                            source4[..<result4.sourceTailStart])

    let source5 = CollectionOfOne(8.8),
        result5 = destination.copy(backwards: source5)
    XCTAssertEqual(result5.writtenStart, destination.startIndex)
    XCTAssertEqual(result5.readStart, source5.startIndex)
    XCTAssertEqualSequences(destination, [8.8])
    XCTAssertEqualSequences(destination[result5.writtenStart...],
                            source5[result5.readStart...])
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

    let source3 = "KLMNO", result3 = destination.copy(asSuffix: source3)
    XCTAssertEqual(result3.copyStart, destination.startIndex)
    XCTAssertEqualSequences(IteratorSequence(result3.sourceTail), [])
    XCTAssertEqualSequences(destination, "KLMNO")

    let source4 = "67890",
        result4 = destination.copy(collectionAsSuffix: source4)
    XCTAssertEqual(result4.copyStart, destination.startIndex)
    XCTAssertEqual(result4.sourceTailStart, source4.endIndex)
    XCTAssertEqualSequences(destination, "67890")
    XCTAssertEqualSequences(destination[result4.copyStart...],
                            source4[..<result4.sourceTailStart])

    let source5 = "pqrst", result5 = destination.copy(backwards: source5)
    XCTAssertEqual(result5.writtenStart, destination.startIndex)
    XCTAssertEqual(result5.readStart, source5.startIndex)
    XCTAssertEqualSequences(destination, "pqrst")
    XCTAssertEqualSequences(destination[result5.writtenStart...],
                            source5[result5.readStart...])
  }

  /// Test a source longer than a multi-element destination.
  func testLongerSource() {
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

    let source3 = 200..<300, result3 = destination.copy(asSuffix: source3)
    XCTAssertEqual(result3.copyStart, destination.startIndex)
    XCTAssertEqualSequences(IteratorSequence(result3.sourceTail), 205..<300)
    XCTAssertEqualSequences(destination, 200..<205)

    let source4 = -200..<0,
        result4 = destination.copy(collectionAsSuffix: source4)
    XCTAssertEqual(result4.copyStart, destination.startIndex)
    XCTAssertEqual(result4.sourceTailStart, -195)
    XCTAssertEqualSequences(destination, (-200)..<(-195))
    XCTAssertEqualSequences(destination[result4.copyStart...],
                            source4[..<result4.sourceTailStart])

    let source5 = 400..<500, result5 = destination.copy(backwards: source5)
    XCTAssertEqual(result5.writtenStart, destination.startIndex)
    XCTAssertEqual(result5.readStart, 495)
    XCTAssertEqualSequences(destination, 495..<500)
    XCTAssertEqualSequences(destination[result5.writtenStart...],
                            source5[result5.readStart...])
  }

  /// Test a multi-element source shorter than the destination.
  func testShorterSource() {
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

    let source3 = "STUV", result3 = destination.copy(asSuffix: source3)
    XCTAssertEqual(result3.copyStart, 9)
    XCTAssertEqualSequences(IteratorSequence(result3.sourceTail), [])
    XCTAssertEqualSequences(destination, "123QRfghiSTUV")

    let source4 = "45678",
        result4 = destination.copy(collectionAsSuffix: source4)
    XCTAssertEqual(result4.copyStart, 8)
    XCTAssertEqual(result4.sourceTailStart, source4.endIndex)
    XCTAssertEqualSequences(destination, "123QRfgh45678")
    XCTAssertEqualSequences(destination[result4.copyStart...],
                            source4[..<result4.sourceTailStart])

    let source5 = "wxyz", result5 = destination.copy(backwards: source5)
    XCTAssertEqual(result5.writtenStart, 9)
    XCTAssertEqual(result5.readStart, source5.startIndex)
    XCTAssertEqualSequences(destination, "123QRfgh4wxyz")
    XCTAssertEqualSequences(destination[result5.writtenStart...],
                            source5[result5.readStart...])
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

    let result5 = destination[3..<7].copy(asSuffix: "34")
    XCTAssertEqual(result5.copyStart, 5)
    XCTAssertEqualSequences(IteratorSequence(result5.sourceTail), [])
    XCTAssertEqualSequences(destination, "abc1234hijklm")

    let source3 = "56",
        result6 = destination[3..<7].copy(collectionAsSuffix: source3)
    XCTAssertEqual(result6.copyStart, 5)
    XCTAssertEqual(result6.sourceTailStart, source3.endIndex)
    XCTAssertEqualSequences(destination, "abc1256hijklm")
    XCTAssertEqualSequences(destination[3..<7][result6.copyStart...],
                            source3[..<result6.sourceTailStart])

    let source4 = "NOP", result7 = destination[3..<7].copy(backwards: source4)
    XCTAssertEqual(result7.writtenStart, 4)
    XCTAssertEqual(result7.readStart, source4.startIndex)
    XCTAssertEqualSequences(destination, "abc1NOPhijklm")
    XCTAssertEqualSequences(destination[3..<7][result7.writtenStart...],
                            source4[result7.readStart...])
  }

  /// Test forward copying within a collection.
  func testInternalForward() {
    // Empty source and destination
    let untarnished = (0..<10).map(Double.init)
    var sample = untarnished,
        sRange, dRange: Range<Int>
    XCTAssertEqualSequences(sample, untarnished)
    (sRange, dRange) = sample.copy(forwardsFrom: 1..<1, to: 6..<6)
    XCTAssertEqualSequences(sample, untarnished)
    XCTAssertEqual(sRange, 1..<1)
    XCTAssertEqual(dRange, 6..<6)

    // Empty source
    (sRange, dRange) = sample.copy(forwardsFrom: 2..<2, to: 7..<8)
    XCTAssertEqualSequences(sample, untarnished)
    XCTAssertEqual(sRange, 2..<2)
    XCTAssertEqual(dRange, 7..<7)

    // Empty destination
    (sRange, dRange) = sample.copy(forwardsFrom: 3..<4, to: 9..<9)
    XCTAssertEqualSequences(sample, untarnished)
    XCTAssertEqual(sRange, 3..<3)
    XCTAssertEqual(dRange, 9..<9)

    // Equal nonempty source and destination
    (sRange, dRange) = sample.copy(forwardsFrom: 5..<8, to: 5..<8)
    XCTAssertEqualSequences(sample, untarnished)
    XCTAssertEqual(sRange, 5..<8)
    XCTAssertEqual(dRange, 5..<8)

    // Overlapping nonempty source and destination
    (sRange, dRange) = sample.copy(forwardsFrom: 5..<9, to: 3..<7)
    XCTAssertEqualSequences(sample, [0, 1, 2, 5, 6, 7, 8, 7, 8, 9])
    XCTAssertEqual(sRange, 5..<9)
    XCTAssertEqual(dRange, 3..<7)

    // Disjoint but nonempty equal-sized source and destination
    sample = untarnished
    (sRange, dRange) = sample.copy(forwardsFrom: 7..<9, to: 2..<4)
    XCTAssertEqualSequences(sample, [0, 1, 7, 8, 4, 5, 6, 7, 8, 9])
    XCTAssertEqual(sRange, 7..<9)
    XCTAssertEqual(dRange, 2..<4)

    // Source longer than nonempty destination
    sample = untarnished
    (sRange, dRange) = sample.copy(forwardsFrom: 2..<6, to: 7..<10)
    XCTAssertEqualSequences(sample, [0, 1, 2, 3, 4, 5, 6, 2, 3, 4])
    XCTAssertEqual(sRange, 2..<5)
    XCTAssertEqual(dRange, 7..<10)

    // Nonempty source shorter than destination
    sample = untarnished
    (sRange, dRange) = sample.copy(forwardsFrom: 5..<7, to: 1..<9)
    XCTAssertEqualSequences(sample, [0, 5, 6, 3, 4, 5, 6, 7, 8, 9])
    XCTAssertEqual(sRange, 5..<7)
    XCTAssertEqual(dRange, 1..<3)

    // Using expressions other than `Range`
    sample = untarnished
    (sRange, dRange) = sample.copy(forwardsFrom: ..<2, to: 8...)
    XCTAssertEqualSequences(sample, [0, 1, 2, 3, 4, 5, 6, 7, 0, 1])
    XCTAssertEqual(sRange, 0..<2)
    XCTAssertEqual(dRange, 8..<10)
  }

  /// Test backward copying within a collection.
  func testInternalBackward() {
    // Empty source and destination
    let untarnished = (0..<10).map(Double.init)
    var sample = untarnished,
        sRange, dRange: Range<Int>
    XCTAssertEqualSequences(sample, untarnished)
    (sRange, dRange) = sample.copy(backwardsFrom: 1..<1, to: 6..<6)
    XCTAssertEqualSequences(sample, untarnished)
    XCTAssertEqual(sRange, 1..<1)
    XCTAssertEqual(dRange, 6..<6)

    // Empty source
    (sRange, dRange) = sample.copy(backwardsFrom: 2..<2, to: 7..<8)
    XCTAssertEqualSequences(sample, untarnished)
    XCTAssertEqual(sRange, 2..<2)
    XCTAssertEqual(dRange, 8..<8)

    // Empty destination
    (sRange, dRange) = sample.copy(backwardsFrom: 3..<4, to: 9..<9)
    XCTAssertEqualSequences(sample, untarnished)
    XCTAssertEqual(sRange, 4..<4)
    XCTAssertEqual(dRange, 9..<9)

    // Equal nonempty source and destination
    (sRange, dRange) = sample.copy(backwardsFrom: 5..<8, to: 5..<8)
    XCTAssertEqualSequences(sample, untarnished)
    XCTAssertEqual(sRange, 5..<8)
    XCTAssertEqual(dRange, 5..<8)

    // Overlapping nonempty source and destination
    (sRange, dRange) = sample.copy(backwardsFrom: 3..<7, to: 5..<9)
    XCTAssertEqualSequences(sample, [0, 1, 2, 3, 4, 3, 4, 5, 6, 9])
    XCTAssertEqual(sRange, 3..<7)
    XCTAssertEqual(dRange, 5..<9)

    // Disjoint but nonempty equal-sized source and destination
    sample = untarnished
    (sRange, dRange) = sample.copy(backwardsFrom: 7..<9, to: 2..<4)
    XCTAssertEqualSequences(sample, [0, 1, 7, 8, 4, 5, 6, 7, 8, 9])
    XCTAssertEqual(sRange, 7..<9)
    XCTAssertEqual(dRange, 2..<4)

    // Source longer than nonempty destination
    sample = untarnished
    (sRange, dRange) = sample.copy(backwardsFrom: 2..<6, to: 7..<10)
    XCTAssertEqualSequences(sample, [0, 1, 2, 3, 4, 5, 6, 3, 4, 5])
    XCTAssertEqual(sRange, 3..<6)
    XCTAssertEqual(dRange, 7..<10)

    // Nonempty source shorter than destination
    sample = untarnished
    (sRange, dRange) = sample.copy(backwardsFrom: 5..<7, to: 1..<9)
    XCTAssertEqualSequences(sample, [0, 1, 2, 3, 4, 5, 6, 5, 6, 9])
    XCTAssertEqual(sRange, 5..<7)
    XCTAssertEqual(dRange, 7..<9)

    // Using expressions other than `Range`
    sample = untarnished
    (sRange, dRange) = sample.copy(backwardsFrom: 8..., to: ..<2)
    XCTAssertEqualSequences(sample, [8, 9, 2, 3, 4, 5, 6, 7, 8, 9])
    XCTAssertEqual(sRange, 8..<10)
    XCTAssertEqual(dRange, 0..<2)
  }
}
