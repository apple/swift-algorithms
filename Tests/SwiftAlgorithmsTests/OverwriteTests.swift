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
final class OverwriteTests: XCTestCase {
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

  /// Test using a sequence as the source for prefix copying.
  func testSequenceSourcePrefix() {
    // Empty source and destination
    var destination1 = EmptyCollection<Double>()
    XCTAssertEqualSequences(destination1, [])
    XCTAssertEqual(destination1.overwrite(prefixWith: EmptyCollection()),
                   destination1.startIndex)
    XCTAssertEqualSequences(destination1, [])

    // Nonempty source with empty destination
    var destination2 = EmptyCollection<Double>()
    XCTAssertEqualSequences(destination2, [])
    XCTAssertEqual(destination2.overwrite(prefixWith: CollectionOfOne(1.1)),
                   destination2.startIndex)
    XCTAssertEqualSequences(destination2, [])

    // Empty source with nonempty destination
    var destination3 = CollectionOfOne(2.2)
    XCTAssertEqualSequences(destination3, [2.2])
    XCTAssertEqual(destination3.overwrite(prefixWith: EmptyCollection()),
                   destination3.startIndex)
    XCTAssertEqualSequences(destination3, [2.2])

    // Two one-element collections
    var destination4 = CollectionOfOne(3.3)
    XCTAssertEqualSequences(destination4, [3.3])
    XCTAssertEqual(destination4.overwrite(prefixWith: CollectionOfOne(4.4)),
                   destination4.endIndex)
    XCTAssertEqualSequences(destination4, [4.4])

    // Two equal-length multi-element collections
    var destination5 = Array(6...10)
    XCTAssertEqualSequences(destination5, 6...10)
    XCTAssertEqual(destination5.overwrite(prefixWith: 1...5),
                   destination5.endIndex)
    XCTAssertEqualSequences(destination5, 1...5)

    // Source longer than multi-element destination
    var destination6 = Array(1...5)
    XCTAssertEqualSequences(destination6, 1...5)
    XCTAssertEqual(destination6.overwrite(prefixWith: 10..<20),
                   destination6.endIndex)
    XCTAssertEqualSequences(destination6, 10..<15)

    // Multi-element source shorter than destination
    var destination7 = Array(0..<10)
    XCTAssertEqualSequences(destination7, 0..<10)
    XCTAssertEqual(destination7.overwrite(prefixWith: -5..<1), 6)
    XCTAssertEqualSequences(destination7, [-5, -4, -3, -2, -1, 0, 6, 7, 8, 9])

    // Copying over part of the destination
    var destination8 = Array("abcdefghijklm")
    XCTAssertEqualSequences(destination8, "abcdefghijklm")
    XCTAssertEqual(destination8[3..<7].overwrite(prefixWith: EmptyCollection()),
                   3)
    XCTAssertEqualSequences(destination8, "abcdefghijklm")
    XCTAssertEqual(destination8[3..<7].overwrite(prefixWith: "12"), 5)
    XCTAssertEqualSequences(destination8, "abc12fghijklm")
    XCTAssertEqual(destination8[3..<7].overwrite(prefixWith: "!@#$"), 7)
    XCTAssertEqualSequences(destination8, "abc!@#$hijklm")
    XCTAssertEqual(destination8[3..<7].overwrite(prefixWith: "NOPQRST"), 7)
    XCTAssertEqualSequences(destination8, "abcNOPQhijklm")
  }

  /// Test using a collection as the source for prefix copying.
  func testCollectionSourcePrefix() {
    // Empty source and destination
    var destination1 = EmptyCollection<Double>()
    XCTAssertEqualSequences(destination1, [])

    let source1 = EmptyCollection<Double>()
    let (sEnd1, dEnd1) = destination1.overwrite(forwardsWith: source1)
    XCTAssertEqual(sEnd1, source1.startIndex)
    XCTAssertEqual(dEnd1, destination1.startIndex)
    XCTAssertEqualSequences(destination1, [])
    XCTAssertEqualSequences(source1[..<sEnd1], destination1[..<dEnd1])

    // Nonempty source with empty destination
    var destination2 = EmptyCollection<Double>()
    XCTAssertEqualSequences(destination2, [])

    let source2 = CollectionOfOne(1.1)
    let (sEnd2, dEnd2) = destination2.overwrite(forwardsWith: source2)
    XCTAssertEqual(sEnd2, source2.startIndex)
    XCTAssertEqual(dEnd2, destination2.startIndex)
    XCTAssertEqualSequences(destination2, [])
    XCTAssertEqualSequences(source2[..<sEnd2], destination2[..<dEnd2])

    // Empty source with nonempty destination
    var destination3 = CollectionOfOne(2.2)
    XCTAssertEqualSequences(destination3, [2.2])

    let source3 = EmptyCollection<Double>()
    let (sEnd3, dEnd3) = destination3.overwrite(forwardsWith: source3)
    XCTAssertEqual(sEnd3, source3.startIndex)
    XCTAssertEqual(dEnd3, destination3.startIndex)
    XCTAssertEqualSequences(destination3, [2.2])
    XCTAssertEqualSequences(source3[..<sEnd3], destination3[..<dEnd3])

    // Two one-element collections
    var destination4 = CollectionOfOne(3.3)
    XCTAssertEqualSequences(destination4, [3.3])

    let source4 = CollectionOfOne(4.4)
    let (sEnd4, dEnd4) = destination4.overwrite(forwardsWith: source4)
    XCTAssertEqual(sEnd4, source4.endIndex)
    XCTAssertEqual(dEnd4, destination4.endIndex)
    XCTAssertEqualSequences(destination4, [4.4])
    XCTAssertEqualSequences(source4[..<sEnd4], destination4[..<dEnd4])

    // Two equal-length multi-element collections
    var destination5 = Array(6...10)
    XCTAssertEqualSequences(destination5, 6...10)

    let source5 = 1...5
    let (sEnd5, dEnd5) = destination5.overwrite(forwardsWith: source5)
    XCTAssertEqual(sEnd5, source5.endIndex)
    XCTAssertEqual(dEnd5, destination5.endIndex)
    XCTAssertEqualSequences(destination5, 1...5)
    XCTAssertEqualSequences(source5[..<sEnd5], destination5[..<dEnd5])

    // Source longer than multi-element destination
    var destination6 = Array(1...5)
    XCTAssertEqualSequences(destination6, 1...5)

    let source6 = 10..<20
    let (sEnd6, dEnd6) = destination6.overwrite(forwardsWith: source6)
    XCTAssertEqual(sEnd6, 15)
    XCTAssertEqual(dEnd6, destination6.endIndex)
    XCTAssertEqualSequences(destination6, 10..<15)
    XCTAssertEqualSequences(source6[..<sEnd6], destination6[..<dEnd6])

    // Multi-element source shorter than destination
    var destination7 = Array(0..<10)
    XCTAssertEqualSequences(destination7, 0..<10)

    let source7 = -5..<1
    let (sEnd7, dEnd7) = destination7.overwrite(forwardsWith: source7)
    XCTAssertEqual(sEnd7, source7.endIndex)
    XCTAssertEqual(dEnd7, 6)
    XCTAssertEqualSequences(destination7, [-5, -4, -3, -2, -1, 0, 6, 7, 8, 9])
    XCTAssertEqualSequences(source7[..<sEnd7], destination7[..<dEnd7])

    // Copying over part of the destination
    var destination8 = Array("abcdefghijklm")
    XCTAssertEqualSequences(destination8, "abcdefghijklm")

    let source8a = ""
    let (sEnd8a, dEnd8a) = destination8[3..<7].overwrite(forwardsWith: source8a)
    XCTAssertEqual(sEnd8a, source8a.startIndex)
    XCTAssertEqual(dEnd8a, 3)
    XCTAssertEqualSequences(destination8, "abcdefghijklm")
    XCTAssertEqualSequences(source8a[..<sEnd8a], destination8[3..<dEnd8a])

    let source8b = "12"
    let (sEnd8b, dEnd8b) = destination8[3..<7].overwrite(forwardsWith: source8b)
    XCTAssertEqual(sEnd8b, source8b.endIndex)
    XCTAssertEqual(dEnd8b, 5)
    XCTAssertEqualSequences(destination8, "abc12fghijklm")
    XCTAssertEqualSequences(source8b[..<sEnd8b], destination8[3..<dEnd8b])

    let source8c = "!@#$"
    let (sEnd8c, dEnd8c) = destination8[3..<7].overwrite(forwardsWith: source8c)
    XCTAssertEqual(sEnd8c, source8c.endIndex)
    XCTAssertEqual(dEnd8c, 7)
    XCTAssertEqualSequences(destination8, "abc!@#$hijklm")
    XCTAssertEqualSequences(source8c[..<sEnd8c], destination8[3..<dEnd8c])

    let source8d = "NOPQRST"
    let (sEnd8d, dEnd8d) = destination8[3..<7].overwrite(forwardsWith: source8d)
    XCTAssertEqual(sEnd8d, source8d.index(source8d.startIndex, offsetBy: +4))
    XCTAssertEqual(dEnd8d, 7)
    XCTAssertEqualSequences(destination8, "abcNOPQhijklm")
    XCTAssertEqualSequences(source8d[sEnd8d...], "RST")
    XCTAssertEqualSequences(source8d[..<sEnd8d], destination8[3..<dEnd8d])
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

  /// Test using a sequence as the source for suffix copying.
  func testSequenceSourceSuffix() {
    // Empty source and destination
    var destination1 = EmptyCollection<Double>()
    XCTAssertEqualSequences(destination1, [])
    XCTAssertEqual(destination1.overwrite(suffixWith: []),
                   destination1.endIndex)
    XCTAssertEqualSequences(destination1, [])

    // Nonempty source with empty destination
    var destination2 = EmptyCollection<Double>()
    XCTAssertEqualSequences(destination2, [])
    XCTAssertEqual(destination2.overwrite(suffixWith: CollectionOfOne(1.1)),
                   destination2.endIndex)
    XCTAssertEqualSequences(destination2, [])

    // Empty source with nonempty destination
    var destination3 = CollectionOfOne(2.2)
    XCTAssertEqualSequences(destination3, [2.2])
    XCTAssertEqual(destination3.overwrite(suffixWith: []),
                   destination3.endIndex)
    XCTAssertEqualSequences(destination3, [2.2])

    // Two one-element collections
    var destination4 = CollectionOfOne(4.4)
    XCTAssertEqualSequences(destination4, [4.4])
    XCTAssertEqual(destination4.overwrite(suffixWith: CollectionOfOne(3.3)),
                   destination4.startIndex)
    XCTAssertEqualSequences(destination4, [3.3])

    // Two equal-length multi-element collections
    var destination5 = Array(6...10)
    XCTAssertEqualSequences(destination5, 6...10)
    XCTAssertEqual(destination5.overwrite(suffixWith: 1...5),
                   destination5.startIndex)
    XCTAssertEqualSequences(destination5, 1...5)

    // Source longer than multi-element destination
    var destination6 = Array(1...5)
    XCTAssertEqualSequences(destination6, 1...5)
    XCTAssertEqual(destination6.overwrite(suffixWith: 10..<20),
                   destination6.startIndex)
    XCTAssertEqualSequences(destination6, 10..<15)

    // Multi-element source shorter than destination
    var destination7 = Array(0..<10)
    XCTAssertEqualSequences(destination7, 0..<10)
    XCTAssertEqual(destination7.overwrite(suffixWith: -5..<1), 4)
    XCTAssertEqualSequences(destination7, [0, 1, 2, 3, -5, -4, -3, -2, -1, 0])

    // Copying over part of the destination
    var destination8 = Array("abcdefghijklm")
    XCTAssertEqualSequences(destination8, "abcdefghijklm")
    XCTAssertEqual(destination8[3..<7].overwrite(suffixWith: []), 7)
    XCTAssertEqualSequences(destination8, "abcdefghijklm")
    XCTAssertEqual(destination8[3..<7].overwrite(suffixWith: "12"), 5)
    XCTAssertEqualSequences(destination8, "abcde12hijklm")
    XCTAssertEqual(destination8[3..<7].overwrite(suffixWith: "!@#$"), 3)
    XCTAssertEqualSequences(destination8, "abc!@#$hijklm")
    XCTAssertEqual(destination8[3..<7].overwrite(suffixWith: "NOPQRST"), 3)
    XCTAssertEqualSequences(destination8, "abcNOPQhijklm")
  }

  /// Test using a collection as the source for suffix copying.
  func testCollectionSourceSuffix() {
    // Empty source and destination
    var destination1 = EmptyCollection<Double>()
    XCTAssertEqualSequences(destination1, [])

    let source1 = EmptyCollection<Double>()
    let (sStart1, dStart1) = destination1.overwrite(backwardsWith: source1)
    XCTAssertEqual(sStart1, source1.endIndex)
    XCTAssertEqual(dStart1, destination1.endIndex)
    XCTAssertEqualSequences(destination1, [])
    XCTAssertEqualSequences(source1[sStart1...], destination1[dStart1...])

    // Nonempty source with empty destination
    var destination2 = EmptyCollection<Double>()
    XCTAssertEqualSequences(destination2, [])

    let source2 = CollectionOfOne(1.1)
    let (sStart2, dStart2) = destination2.overwrite(backwardsWith: source2)
    XCTAssertEqual(sStart2, source2.endIndex)
    XCTAssertEqual(dStart2, destination2.endIndex)
    XCTAssertEqualSequences(destination2, [])
    XCTAssertEqualSequences(source2[sStart2...], destination2[dStart2...])

    // Empty source with nonempty destination
    var destination3 = CollectionOfOne(2.2)
    XCTAssertEqualSequences(destination3, [2.2])

    let source3 = EmptyCollection<Double>()
    let (sStart3, dStart3) = destination3.overwrite(backwardsWith: source3)
    XCTAssertEqual(sStart3, source3.endIndex)
    XCTAssertEqual(dStart3, destination3.endIndex)
    XCTAssertEqualSequences(destination3, [2.2])
    XCTAssertEqualSequences(source3[sStart3...], destination3[dStart3...])

    // Two one-element collections
    var destination4 = CollectionOfOne(3.3)
    XCTAssertEqualSequences(destination4, [3.3])

    let source4 = CollectionOfOne(4.4)
    let (sStart4, dStart4) = destination4.overwrite(backwardsWith: source4)
    XCTAssertEqual(sStart4, source4.startIndex)
    XCTAssertEqual(dStart4, destination4.startIndex)
    XCTAssertEqualSequences(destination4, [4.4])
    XCTAssertEqualSequences(source4[sStart4...], destination4[dStart4...])

    // Two equal-length multi-element collections
    var destination5 = Array(6...10)
    XCTAssertEqualSequences(destination5, 6...10)

    let source5 = 1...5
    let (sStart5, dStart5) = destination5.overwrite(backwardsWith: source5)
    XCTAssertEqual(sStart5, source5.startIndex)
    XCTAssertEqual(dStart5, destination5.startIndex)
    XCTAssertEqualSequences(destination5, 1...5)
    XCTAssertEqualSequences(source5[sStart5...], destination5[dStart5...])

    // Source longer than multi-element destination
    var destination6 = Array(1...5)
    XCTAssertEqualSequences(destination6, 1...5)

    let source6 = 10..<20
    let (sStart6, dStart6) = destination6.overwrite(backwardsWith: source6)
    XCTAssertEqual(sStart6, 15)
    XCTAssertEqual(dStart6, destination6.startIndex)
    XCTAssertEqualSequences(destination6, 15..<20)
    XCTAssertEqualSequences(source6[sStart6...], destination6[dStart6...])

    // Multi-element source shorter than destination
    var destination7 = Array(0..<10)
    XCTAssertEqualSequences(destination7, 0..<10)

    let source7 = -5..<1
    let (sStart7, dStart7) = destination7.overwrite(backwardsWith: source7)
    XCTAssertEqual(sStart7, source7.startIndex)
    XCTAssertEqual(dStart7, 4)
    XCTAssertEqualSequences(destination7, [0, 1, 2, 3, -5, -4, -3, -2, -1, 0])
    XCTAssertEqualSequences(source7[sStart7...], destination7[dStart7...])

    // Copying over part of the destination
    var destination8 = Array("abcdefghijklm")
    XCTAssertEqualSequences(destination8, "abcdefghijklm")

    let source8a = ""
    let (sStart8a, dStart8a) = destination8[3..<7]
      .overwrite(backwardsWith: source8a)
    XCTAssertEqual(sStart8a, source8a.endIndex)
    XCTAssertEqual(dStart8a, 7)
    XCTAssertEqualSequences(destination8, "abcdefghijklm")
    XCTAssertEqualSequences(source8a[sStart8a...], destination8[dStart8a..<7])

    let source8b = "12"
    let (sStart8b, dStart8b) = destination8[3..<7]
      .overwrite(backwardsWith: source8b)
    XCTAssertEqual(sStart8b, source8b.startIndex)
    XCTAssertEqual(dStart8b, 5)
    XCTAssertEqualSequences(destination8, "abcde12hijklm")
    XCTAssertEqualSequences(source8b[sStart8b...], destination8[dStart8b..<7])

    let source8c = "!@#$"
    let (sStart8c, dStart8c) = destination8[3..<7]
      .overwrite(backwardsWith: source8c)
    XCTAssertEqual(sStart8c, source8c.startIndex)
    XCTAssertEqual(dStart8c, 3)
    XCTAssertEqualSequences(destination8, "abc!@#$hijklm")
    XCTAssertEqualSequences(source8c[sStart8c...], destination8[dStart8c..<7])

    let source8d = "NOPQRST"
    let (sStart8d, dStart8d) = destination8[3..<7]
      .overwrite(backwardsWith: source8d)
    XCTAssertEqual(sStart8d, source8d.index(source8d.endIndex, offsetBy: -4))
    XCTAssertEqual(dStart8d, 3)
    XCTAssertEqualSequences(destination8, "abcQRSThijklm")
    XCTAssertEqualSequences(source8d[..<sStart8d], "NOP")
    XCTAssertEqualSequences(source8d[sStart8d...], destination8[dStart8d..<7])
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
