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

/// Unit tests for the `overwrite` methods.
final class CopyTests: XCTestCase {
  /// Test using an iterator as the source for prefix copying.
  func testIteratorSourcePrefix() {
    // Empty source and destination
    let source1 = EmptyCollection<Double>()
    var destination1 = source1, iterator1 = source1.makeIterator()
    XCTAssertEqualSequences(destination1, [])

    let result1 = destination1.overwrite(prefixUsing: &iterator1)
    XCTAssertEqual(result1, destination1.startIndex)
    XCTAssertEqualSequences(IteratorSequence(iterator1), [])
    XCTAssertEqualSequences(destination1, [])

    // Nonempty source with empty destination
    let source2 = CollectionOfOne(1.1)
    var destination2 = EmptyCollection<Double>(),
        iterator2 = source2.makeIterator()
    XCTAssertEqualSequences(destination2, [])

    let result2 = destination2.overwrite(prefixUsing: &iterator2)
    XCTAssertEqual(result2, destination2.startIndex)
    XCTAssertEqualSequences(IteratorSequence(iterator2), [1.1])
    XCTAssertEqualSequences(destination2, [])

    // Empty source with nonempty destination
    let source3 = EmptyCollection<Double>()
    var destination3 = CollectionOfOne(2.2), iterator3 = source3.makeIterator()
    XCTAssertEqualSequences(destination3, [2.2])

    let result3 = destination3.overwrite(prefixUsing: &iterator3)
    XCTAssertEqual(result3, destination3.startIndex)
    XCTAssertEqualSequences(IteratorSequence(iterator3), [])
    XCTAssertEqualSequences(destination3, [2.2])

    // Two one-element collections
    let source4 = CollectionOfOne(3.3)
    var destination4 = CollectionOfOne(4.4), iterator4 = source4.makeIterator()
    XCTAssertEqualSequences(destination4, [4.4])

    let result4 = destination4.overwrite(prefixUsing: &iterator4)
    XCTAssertEqual(result4, destination4.endIndex)
    XCTAssertEqualSequences(IteratorSequence(iterator4), [])
    XCTAssertEqualSequences(destination4, [3.3])

    // Two equal-length multi-element collections
    let source5 = 1...5
    var destination5 = Array(6...10), iterator5 = source5.makeIterator()
    XCTAssertEqualSequences(destination5, 6...10)
    XCTAssertEqual(source5.count, destination5.count)

    let result5 = destination5.overwrite(prefixUsing: &iterator5)
    XCTAssertEqual(result5, destination5.endIndex)
    XCTAssertEqualSequences(IteratorSequence(iterator5), [])
    XCTAssertEqualSequences(destination5, 1...5)

    // Source longer than multi-element destination
    let source6 = 10..<20
    var destination6 = Array(1...5), iterator6 = source6.makeIterator()
    XCTAssertEqualSequences(destination6, 1...5)
    XCTAssertGreaterThan(source6.count, destination6.count)

    let result6 = destination6.overwrite(prefixUsing: &iterator6)
    XCTAssertEqual(result6, destination6.endIndex)
    XCTAssertEqualSequences(IteratorSequence(iterator6), 15..<20)
    XCTAssertEqualSequences(destination6, 10..<15)

    // Multi-element source shorter than destination
    let source7 = -5..<1
    var destination7 = Array(0..<10), iterator7 = source7.makeIterator()
    XCTAssertEqualSequences(destination7, 0..<10)
    XCTAssertLessThan(source7.count, destination7.count)

    let result7 = destination7.overwrite(prefixUsing: &iterator7)
    XCTAssertEqual(result7, 6)
    XCTAssertEqualSequences(IteratorSequence(iterator7), [])
    XCTAssertEqualSequences(destination7, [-5, -4, -3, -2, -1, 0, 6, 7, 8, 9])

    // Copying over part of the destination
    var destination8 = Array("abcdefghijklm")
    XCTAssertEqualSequences(destination8, "abcdefghijklm")

    let source8a = EmptyCollection<Character>()
    var iterator8a = source8a.makeIterator()
    let result8a = destination8[3..<7].overwrite(prefixUsing: &iterator8a)
    XCTAssertTrue(source8a.isEmpty)
    XCTAssertEqual(result8a, 3)
    XCTAssertEqualSequences(IteratorSequence(iterator8a), [])
    XCTAssertEqualSequences(destination8, "abcdefghijklm")

    let source8b = "12"
    var iterator8b = source8b.makeIterator()
    let result8b = destination8[3..<7].overwrite(prefixUsing: &iterator8b)
    XCTAssertLessThan(source8b.count, destination8[3..<7].count)
    XCTAssertEqual(result8b, 5)
    XCTAssertEqualSequences(IteratorSequence(iterator8b), [])
    XCTAssertEqualSequences(destination8, "abc12fghijklm")

    let source8c = "!@#$"
    var iterator8c = source8c.makeIterator()
    let result8c = destination8[3..<7].overwrite(prefixUsing: &iterator8c)
    XCTAssertEqual(source8c.count, destination8[3..<7].count)
    XCTAssertEqual(result8c, 7)
    XCTAssertEqualSequences(IteratorSequence(iterator8c), [])
    XCTAssertEqualSequences(destination8, "abc!@#$hijklm")

    let source8d = "NOPQRST"
    var iterator8d = source8d.makeIterator()
    let result8d = destination8[3..<7].overwrite(prefixUsing: &iterator8d)
    XCTAssertGreaterThan(source8d.count, destination8[3..<7].count)
    XCTAssertEqual(result8d, 7)
    XCTAssertEqualSequences(IteratorSequence(iterator8d), "RST")
    XCTAssertEqualSequences(destination8, "abcNOPQhijklm")
  }

  /// Test using an iterator as the source for suffix copying.
  func testIteratorSourceSuffix() {
    // Empty source and destination
    let source1 = EmptyCollection<Double>()
    var destination1 = source1, iterator1 = source1.makeIterator()
    XCTAssertEqualSequences(destination1, [])

    let result1 = destination1.overwrite(suffixUsing: &iterator1)
    XCTAssertEqual(result1, destination1.endIndex)
    XCTAssertEqualSequences(IteratorSequence(iterator1), [])
    XCTAssertEqualSequences(destination1, [])

    // Nonempty source with empty destination
    let source2 = CollectionOfOne(1.1)
    var destination2 = EmptyCollection<Double>(),
        iterator2 = source2.makeIterator()
    XCTAssertEqualSequences(destination2, [])

    let result2 = destination2.overwrite(suffixUsing: &iterator2)
    XCTAssertEqual(result2, destination2.endIndex)
    XCTAssertEqualSequences(IteratorSequence(iterator2), [1.1])
    XCTAssertEqualSequences(destination2, [])

    // Empty source with nonempty destination
    let source3 = EmptyCollection<Double>()
    var destination3 = CollectionOfOne(2.2), iterator3 = source3.makeIterator()
    XCTAssertEqualSequences(destination3, [2.2])

    let result3 = destination3.overwrite(suffixUsing: &iterator3)
    XCTAssertEqual(result3, destination3.endIndex)
    XCTAssertEqualSequences(IteratorSequence(iterator3), [])
    XCTAssertEqualSequences(destination3, [2.2])

    // Two one-element collections
    let source4 = CollectionOfOne(3.3)
    var destination4 = CollectionOfOne(4.4), iterator4 = source4.makeIterator()
    XCTAssertEqualSequences(destination4, [4.4])

    let result4 = destination4.overwrite(suffixUsing: &iterator4)
    XCTAssertEqual(result4, destination4.startIndex)
    XCTAssertEqualSequences(IteratorSequence(iterator4), [])
    XCTAssertEqualSequences(destination4, [3.3])

    // Two equal-length multi-element collections
    let source5 = 1...5
    var destination5 = Array(6...10), iterator5 = source5.makeIterator()
    XCTAssertEqualSequences(destination5, 6...10)
    XCTAssertEqual(source5.count, destination5.count)

    let result5 = destination5.overwrite(suffixUsing: &iterator5)
    XCTAssertEqual(result5, destination5.startIndex)
    XCTAssertEqualSequences(IteratorSequence(iterator5), [])
    XCTAssertEqualSequences(destination5, 1...5)

    // Source longer than multi-element destination
    let source6 = 10..<20
    var destination6 = Array(1...5), iterator6 = source6.makeIterator()
    XCTAssertEqualSequences(destination6, 1...5)
    XCTAssertGreaterThan(source6.count, destination6.count)

    let result6 = destination6.overwrite(suffixUsing: &iterator6)
    XCTAssertEqual(result6, destination6.startIndex)
    XCTAssertEqualSequences(IteratorSequence(iterator6), 15..<20)
    XCTAssertEqualSequences(destination6, 10..<15)

    // Multi-element source shorter than destination
    let source7 = -5..<1
    var destination7 = Array(0..<10), iterator7 = source7.makeIterator()
    XCTAssertEqualSequences(destination7, 0..<10)
    XCTAssertLessThan(source7.count, destination7.count)

    let result7 = destination7.overwrite(suffixUsing: &iterator7)
    XCTAssertEqual(result7, 4)
    XCTAssertEqualSequences(IteratorSequence(iterator7), [])
    XCTAssertEqualSequences(destination7, [0, 1, 2, 3, -5, -4, -3, -2, -1, 0])

    // Copying over part of the destination
    var destination8 = Array("abcdefghijklm")
    XCTAssertEqualSequences(destination8, "abcdefghijklm")

    let source8a = EmptyCollection<Character>()
    var iterator8a = source8a.makeIterator()
    let result8a = destination8[3..<7].overwrite(suffixUsing: &iterator8a)
    XCTAssertTrue(source8a.isEmpty)
    XCTAssertEqual(result8a, 7)
    XCTAssertEqualSequences(IteratorSequence(iterator8a), [])
    XCTAssertEqualSequences(destination8, "abcdefghijklm")

    let source8b = "12"
    var iterator8b = source8b.makeIterator()
    let result8b = destination8[3..<7].overwrite(suffixUsing: &iterator8b)
    XCTAssertLessThan(source8b.count, destination8[3..<7].count)
    XCTAssertEqual(result8b, 5)
    XCTAssertEqualSequences(IteratorSequence(iterator8b), [])
    XCTAssertEqualSequences(destination8, "abcde12hijklm")

    let source8c = "!@#$"
    var iterator8c = source8c.makeIterator()
    let result8c = destination8[3..<7].overwrite(suffixUsing: &iterator8c)
    XCTAssertEqual(source8c.count, destination8[3..<7].count)
    XCTAssertEqual(result8c, 3)
    XCTAssertEqualSequences(IteratorSequence(iterator8c), [])
    XCTAssertEqualSequences(destination8, "abc!@#$hijklm")

    let source8d = "NOPQRST"
    var iterator8d = source8d.makeIterator()
    let result8d = destination8[3..<7].overwrite(suffixUsing: &iterator8d)
    XCTAssertGreaterThan(source8d.count, destination8[3..<7].count)
    XCTAssertEqual(result8d, 3)
    XCTAssertEqualSequences(IteratorSequence(iterator8d), "RST")
    XCTAssertEqualSequences(destination8, "abcNOPQhijklm")
  }

  /// Test empty source and destination.
  func testBothEmpty() {
    var empty1 = EmptyCollection<Double>()
    let empty2 = EmptyCollection<Double>()
    XCTAssertEqualSequences(empty1, [])

    let result = empty1.overwrite(prefixWith: empty2)
    XCTAssertEqual(result.copyEnd, empty1.startIndex)
    XCTAssertEqualSequences(IteratorSequence(result.sourceTail), [])
    XCTAssertEqualSequences(empty1, [])

    let result2 = empty1.overwrite(prefixWithCollection: empty2)
    XCTAssertEqual(result2.copyEnd, empty1.startIndex)
    XCTAssertEqual(result2.sourceTailStart, empty2.startIndex)
    XCTAssertEqualSequences(empty1, [])
    XCTAssertEqualSequences(empty1[..<result2.copyEnd],
                            empty2[..<result2.sourceTailStart])

    let result3 = empty1.overwrite(suffixWith: empty2)
    XCTAssertEqual(result3.copyStart, empty1.endIndex)
    XCTAssertEqualSequences(IteratorSequence(result3.sourceTail), [])
    XCTAssertEqualSequences(empty1, [])

    let result4 = empty1.overwrite(suffixWithCollection: empty2)
    XCTAssertEqual(result4.copyStart, empty1.endIndex)
    XCTAssertEqual(result4.sourceTailStart, empty2.startIndex)
    XCTAssertEqualSequences(empty1, [])
    XCTAssertEqualSequences(empty1[result4.copyStart...],
                            empty2[..<result4.sourceTailStart])

    let result5 = empty1.overwrite(backwards: empty2)
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

    let result = empty.overwrite(prefixWith: single)
    XCTAssertEqual(result.copyEnd, empty.endIndex)
    XCTAssertEqualSequences(IteratorSequence(result.sourceTail), [1.1])
    XCTAssertEqualSequences(empty, [])

    let result2 = empty.overwrite(prefixWithCollection: single)
    XCTAssertEqual(result2.copyEnd, empty.startIndex)
    XCTAssertEqual(result2.sourceTailStart, single.startIndex)
    XCTAssertEqualSequences(empty, [])
    XCTAssertEqualSequences(empty[..<result2.copyEnd],
                            single[..<result2.sourceTailStart])

    let result3 = empty.overwrite(suffixWith: single)
    XCTAssertEqual(result3.copyStart, empty.endIndex)
    XCTAssertEqualSequences(IteratorSequence(result3.sourceTail), [1.1])
    XCTAssertEqualSequences(empty, [])

    let result4 = empty.overwrite(suffixWithCollection: single)
    XCTAssertEqual(result4.copyStart, empty.endIndex)
    XCTAssertEqual(result4.sourceTailStart, single.startIndex)
    XCTAssertEqualSequences(empty, [])
    XCTAssertEqualSequences(empty[result4.copyStart...],
                            single[..<result4.sourceTailStart])

    let result5 = empty.overwrite(backwards: single)
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

    let result = single.overwrite(prefixWith: empty)
    XCTAssertEqual(result.copyEnd, single.startIndex)
    XCTAssertEqualSequences(IteratorSequence(result.sourceTail), [])
    XCTAssertEqualSequences(single, [2.2])

    let result2 = single.overwrite(prefixWithCollection: empty)
    XCTAssertEqual(result2.copyEnd, single.startIndex)
    XCTAssertEqual(result2.sourceTailStart, empty.startIndex)
    XCTAssertEqualSequences(single, [2.2])
    XCTAssertEqualSequences(single[..<result2.copyEnd],
                            empty[..<result2.sourceTailStart])

    let result3 = single.overwrite(suffixWith: empty)
    XCTAssertEqual(result3.copyStart, single.endIndex)
    XCTAssertEqualSequences(IteratorSequence(result3.sourceTail), [])
    XCTAssertEqualSequences(single, [2.2])

    let result4 = single.overwrite(suffixWithCollection: empty)
    XCTAssertEqual(result4.copyStart, single.endIndex)
    XCTAssertEqual(result4.sourceTailStart, empty.startIndex)
    XCTAssertEqualSequences(single, [2.2])
    XCTAssertEqualSequences(single[result4.copyStart...],
                            empty[..<result4.sourceTailStart])

    let result5 = single.overwrite(backwards: empty)
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

    let result = destination.overwrite(prefixWith: source)
    XCTAssertEqual(result.copyEnd, destination.endIndex)
    XCTAssertEqualSequences(IteratorSequence(result.sourceTail), [])
    XCTAssertEqualSequences(destination, [4.4])

    let source2 = CollectionOfOne(5.5),
        result2 = destination.overwrite(prefixWithCollection: source2)
    XCTAssertEqual(result2.copyEnd, destination.endIndex)
    XCTAssertEqual(result2.sourceTailStart, source2.endIndex)
    XCTAssertEqualSequences(destination, [5.5])
    XCTAssertEqualSequences(destination[..<result2.copyEnd],
                            source2[..<result2.sourceTailStart])

    let source3 = CollectionOfOne(6.6),
        result3 = destination.overwrite(suffixWith: source3)
    XCTAssertEqual(result3.copyStart, destination.startIndex)
    XCTAssertEqualSequences(IteratorSequence(result3.sourceTail), [])
    XCTAssertEqualSequences(destination, [6.6])

    let source4 = CollectionOfOne(7.7),
        result4 = destination.overwrite(suffixWithCollection: source4)
    XCTAssertEqual(result4.copyStart, destination.startIndex)
    XCTAssertEqual(result4.sourceTailStart, source4.endIndex)
    XCTAssertEqualSequences(destination, [7.7])
    XCTAssertEqualSequences(destination[result4.copyStart...],
                            source4[..<result4.sourceTailStart])

    let source5 = CollectionOfOne(8.8),
        result5 = destination.overwrite(backwards: source5)
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

    let result = destination.overwrite(prefixWith: source)
    XCTAssertEqual(result.copyEnd, destination.endIndex)
    XCTAssertEqualSequences(IteratorSequence(result.sourceTail), [])
    XCTAssertEqualSequences(destination, "fghij")

    let source2 = "12345", result2 = destination.overwrite(prefixWithCollection: source2)
    XCTAssertEqual(result2.copyEnd, destination.endIndex)
    XCTAssertEqual(result2.sourceTailStart, source2.endIndex)
    XCTAssertEqualSequences(destination, "12345")
    XCTAssertEqualSequences(destination[..<result2.copyEnd],
                            source2[..<result2.sourceTailStart])

    let source3 = "KLMNO", result3 = destination.overwrite(suffixWith: source3)
    XCTAssertEqual(result3.copyStart, destination.startIndex)
    XCTAssertEqualSequences(IteratorSequence(result3.sourceTail), [])
    XCTAssertEqualSequences(destination, "KLMNO")

    let source4 = "67890",
        result4 = destination.overwrite(suffixWithCollection: source4)
    XCTAssertEqual(result4.copyStart, destination.startIndex)
    XCTAssertEqual(result4.sourceTailStart, source4.endIndex)
    XCTAssertEqualSequences(destination, "67890")
    XCTAssertEqualSequences(destination[result4.copyStart...],
                            source4[..<result4.sourceTailStart])

    let source5 = "pqrst", result5 = destination.overwrite(backwards: source5)
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

    let result = destination.overwrite(prefixWith: source)
    XCTAssertEqual(result.copyEnd, destination.endIndex)
    XCTAssertEqualSequences(IteratorSequence(result.sourceTail), 15...100)
    XCTAssertEqualSequences(destination, 10..<15)

    let source2 = -50..<0, result2 = destination.overwrite(prefixWithCollection: source2)
    XCTAssertEqual(result2.copyEnd, destination.endIndex)
    XCTAssertEqual(result2.sourceTailStart, -45)
    XCTAssertEqualSequences(destination, (-50)...(-46))
    XCTAssertEqualSequences(destination[..<result2.copyEnd],
                            source2[..<result2.sourceTailStart])

    let source3 = 200..<300, result3 = destination.overwrite(suffixWith: source3)
    XCTAssertEqual(result3.copyStart, destination.startIndex)
    XCTAssertEqualSequences(IteratorSequence(result3.sourceTail), 205..<300)
    XCTAssertEqualSequences(destination, 200..<205)

    let source4 = -200..<0,
        result4 = destination.overwrite(suffixWithCollection: source4)
    XCTAssertEqual(result4.copyStart, destination.startIndex)
    XCTAssertEqual(result4.sourceTailStart, -195)
    XCTAssertEqualSequences(destination, (-200)..<(-195))
    XCTAssertEqualSequences(destination[result4.copyStart...],
                            source4[..<result4.sourceTailStart])

    let source5 = 400..<500, result5 = destination.overwrite(backwards: source5)
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

    let result = destination.overwrite(prefixWith: source)
    XCTAssertEqual(result.copyEnd, destination.index(destination.startIndex,
                                                 offsetBy: source.count))
    XCTAssertEqualSequences(IteratorSequence(result.sourceTail), [])
    XCTAssertEqualSequences(destination, "NOPQRfghijklm")

    let source2 = "123", result2 = destination.overwrite(prefixWithCollection: source2)
    XCTAssertEqual(result2.copyEnd, 3)
    XCTAssertEqual(result2.sourceTailStart, source2.endIndex)
    XCTAssertEqualSequences(destination, "123QRfghijklm")
    XCTAssertEqualSequences(destination[..<result2.copyEnd],
                            source2[..<result2.sourceTailStart])

    let source3 = "STUV", result3 = destination.overwrite(suffixWith: source3)
    XCTAssertEqual(result3.copyStart, 9)
    XCTAssertEqualSequences(IteratorSequence(result3.sourceTail), [])
    XCTAssertEqualSequences(destination, "123QRfghiSTUV")

    let source4 = "45678",
        result4 = destination.overwrite(suffixWithCollection: source4)
    XCTAssertEqual(result4.copyStart, 8)
    XCTAssertEqual(result4.sourceTailStart, source4.endIndex)
    XCTAssertEqualSequences(destination, "123QRfgh45678")
    XCTAssertEqualSequences(destination[result4.copyStart...],
                            source4[..<result4.sourceTailStart])

    let source5 = "wxyz", result5 = destination.overwrite(backwards: source5)
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

    let result = destination[3..<7].overwrite(prefixWith: source)
    XCTAssertEqual(result.copyEnd, 7)
    XCTAssertEqualSequences(IteratorSequence(result.sourceTail), "WXYZ")
    XCTAssertEqualSequences(destination, "abcSTUVhijklm")

    let result2 = destination[3..<7].overwrite(prefixWith: "12")
    XCTAssertEqual(result2.copyEnd, 5)
    XCTAssertEqualSequences(IteratorSequence(result2.sourceTail), [])
    XCTAssertEqualSequences(destination, "abc12UVhijklm")

    let result3 = destination[3..<7].overwrite(prefixWithCollection: source)
    XCTAssertEqual(result3.copyEnd, 7)
    XCTAssertEqualSequences(source[result3.sourceTailStart...], "WXYZ")
    XCTAssertEqualSequences(destination, "abcSTUVhijklm")
    XCTAssertEqualSequences(destination[3..<7][..<result3.copyEnd],
                            source[..<result3.sourceTailStart])

    let source2 = "12", result4 = destination[3..<7].overwrite(prefixWithCollection: source2)
    XCTAssertEqual(result4.copyEnd, 5)
    XCTAssertEqual(result4.sourceTailStart, source2.endIndex)
    XCTAssertEqualSequences(destination, "abc12UVhijklm")
    XCTAssertEqualSequences(destination[3..<7][..<result4.copyEnd],
                            source2[..<result4.sourceTailStart])

    let result5 = destination[3..<7].overwrite(suffixWith: "34")
    XCTAssertEqual(result5.copyStart, 5)
    XCTAssertEqualSequences(IteratorSequence(result5.sourceTail), [])
    XCTAssertEqualSequences(destination, "abc1234hijklm")

    let source3 = "56",
        result6 = destination[3..<7].overwrite(suffixWithCollection: source3)
    XCTAssertEqual(result6.copyStart, 5)
    XCTAssertEqual(result6.sourceTailStart, source3.endIndex)
    XCTAssertEqualSequences(destination, "abc1256hijklm")
    XCTAssertEqualSequences(destination[3..<7][result6.copyStart...],
                            source3[..<result6.sourceTailStart])

    let source4 = "NOP", result7 = destination[3..<7].overwrite(backwards: source4)
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
    (sRange, dRange) = sample.overwrite(forwardsFrom: 1..<1, to: 6..<6)
    XCTAssertEqualSequences(sample, untarnished)
    XCTAssertEqual(sRange, 1..<1)
    XCTAssertEqual(dRange, 6..<6)

    // Empty source
    (sRange, dRange) = sample.overwrite(forwardsFrom: 2..<2, to: 7..<8)
    XCTAssertEqualSequences(sample, untarnished)
    XCTAssertEqual(sRange, 2..<2)
    XCTAssertEqual(dRange, 7..<7)

    // Empty destination
    (sRange, dRange) = sample.overwrite(forwardsFrom: 3..<4, to: 9..<9)
    XCTAssertEqualSequences(sample, untarnished)
    XCTAssertEqual(sRange, 3..<3)
    XCTAssertEqual(dRange, 9..<9)

    // Equal nonempty source and destination
    (sRange, dRange) = sample.overwrite(forwardsFrom: 5..<8, to: 5..<8)
    XCTAssertEqualSequences(sample, untarnished)
    XCTAssertEqual(sRange, 5..<8)
    XCTAssertEqual(dRange, 5..<8)

    // Overlapping nonempty source and destination
    (sRange, dRange) = sample.overwrite(forwardsFrom: 5..<9, to: 3..<7)
    XCTAssertEqualSequences(sample, [0, 1, 2, 5, 6, 7, 8, 7, 8, 9])
    XCTAssertEqual(sRange, 5..<9)
    XCTAssertEqual(dRange, 3..<7)

    // Disjoint but nonempty equal-sized source and destination
    sample = untarnished
    (sRange, dRange) = sample.overwrite(forwardsFrom: 7..<9, to: 2..<4)
    XCTAssertEqualSequences(sample, [0, 1, 7, 8, 4, 5, 6, 7, 8, 9])
    XCTAssertEqual(sRange, 7..<9)
    XCTAssertEqual(dRange, 2..<4)

    // Source longer than nonempty destination
    sample = untarnished
    (sRange, dRange) = sample.overwrite(forwardsFrom: 2..<6, to: 7..<10)
    XCTAssertEqualSequences(sample, [0, 1, 2, 3, 4, 5, 6, 2, 3, 4])
    XCTAssertEqual(sRange, 2..<5)
    XCTAssertEqual(dRange, 7..<10)

    // Nonempty source shorter than destination
    sample = untarnished
    (sRange, dRange) = sample.overwrite(forwardsFrom: 5..<7, to: 1..<9)
    XCTAssertEqualSequences(sample, [0, 5, 6, 3, 4, 5, 6, 7, 8, 9])
    XCTAssertEqual(sRange, 5..<7)
    XCTAssertEqual(dRange, 1..<3)

    // Using expressions other than `Range`
    sample = untarnished
    (sRange, dRange) = sample.overwrite(forwardsFrom: ..<2, to: 8...)
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
    (sRange, dRange) = sample.overwrite(backwardsFrom: 1..<1, to: 6..<6)
    XCTAssertEqualSequences(sample, untarnished)
    XCTAssertEqual(sRange, 1..<1)
    XCTAssertEqual(dRange, 6..<6)

    // Empty source
    (sRange, dRange) = sample.overwrite(backwardsFrom: 2..<2, to: 7..<8)
    XCTAssertEqualSequences(sample, untarnished)
    XCTAssertEqual(sRange, 2..<2)
    XCTAssertEqual(dRange, 8..<8)

    // Empty destination
    (sRange, dRange) = sample.overwrite(backwardsFrom: 3..<4, to: 9..<9)
    XCTAssertEqualSequences(sample, untarnished)
    XCTAssertEqual(sRange, 4..<4)
    XCTAssertEqual(dRange, 9..<9)

    // Equal nonempty source and destination
    (sRange, dRange) = sample.overwrite(backwardsFrom: 5..<8, to: 5..<8)
    XCTAssertEqualSequences(sample, untarnished)
    XCTAssertEqual(sRange, 5..<8)
    XCTAssertEqual(dRange, 5..<8)

    // Overlapping nonempty source and destination
    (sRange, dRange) = sample.overwrite(backwardsFrom: 3..<7, to: 5..<9)
    XCTAssertEqualSequences(sample, [0, 1, 2, 3, 4, 3, 4, 5, 6, 9])
    XCTAssertEqual(sRange, 3..<7)
    XCTAssertEqual(dRange, 5..<9)

    // Disjoint but nonempty equal-sized source and destination
    sample = untarnished
    (sRange, dRange) = sample.overwrite(backwardsFrom: 7..<9, to: 2..<4)
    XCTAssertEqualSequences(sample, [0, 1, 7, 8, 4, 5, 6, 7, 8, 9])
    XCTAssertEqual(sRange, 7..<9)
    XCTAssertEqual(dRange, 2..<4)

    // Source longer than nonempty destination
    sample = untarnished
    (sRange, dRange) = sample.overwrite(backwardsFrom: 2..<6, to: 7..<10)
    XCTAssertEqualSequences(sample, [0, 1, 2, 3, 4, 5, 6, 3, 4, 5])
    XCTAssertEqual(sRange, 3..<6)
    XCTAssertEqual(dRange, 7..<10)

    // Nonempty source shorter than destination
    sample = untarnished
    (sRange, dRange) = sample.overwrite(backwardsFrom: 5..<7, to: 1..<9)
    XCTAssertEqualSequences(sample, [0, 1, 2, 3, 4, 5, 6, 5, 6, 9])
    XCTAssertEqual(sRange, 5..<7)
    XCTAssertEqual(dRange, 7..<9)

    // Using expressions other than `Range`
    sample = untarnished
    (sRange, dRange) = sample.overwrite(backwardsFrom: 8..., to: ..<2)
    XCTAssertEqualSequences(sample, [8, 9, 2, 3, 4, 5, 6, 7, 8, 9])
    XCTAssertEqual(sRange, 8..<10)
    XCTAssertEqual(dRange, 0..<2)
  }
}
