//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift Algorithms open source project
//
// Copyright (c) 2025 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

import XCTest

@testable import Algorithms

final class SortedDuplicatesTests: XCTestCase {
  /// Test counting over an empty sequence.
  func testEmpty() {
    let emptyString = ""
    let emptyStringCounts = emptyString.countSortedDuplicates()
    expectEqualCollections(emptyStringCounts.map(\.value), [])
    expectEqualCollections(emptyStringCounts.map(\.count), [])
    expectEqualCollections(emptyString.deduplicateSorted(), [])

    let lazyEmptyStringCounts = emptyString.lazy.countSortedDuplicates()
    expectEqualSequences(lazyEmptyStringCounts.map(\.value), [])
    expectEqualSequences(lazyEmptyStringCounts.map(\.count), [])
    expectEqualSequences(emptyString.lazy.deduplicateSorted(), [])
  }

  /// Test counting over a single-element sequence.
  func testSingle() {
    let aString = "a"
    let aStringCounts = aString.countSortedDuplicates()
    let aStringValues = aString.deduplicateSorted()
    expectEqualCollections(aStringCounts.map(\.value), ["a"])
    expectEqualCollections(aStringCounts.map(\.count), [1])
    expectEqualCollections(aStringValues, ["a"])

    let lazyAStringCounts = aString.lazy.countSortedDuplicates()
    expectEqualSequences(lazyAStringCounts.map(\.value), ["a"])
    expectEqualSequences(lazyAStringCounts.map(\.count), [1])
    expectEqualSequences(aString.lazy.deduplicateSorted(), ["a"])
  }

  /// Test counting over a repeated element.
  func testRepeat() {
    let count = 20
    let letters = repeatElement("b" as Character, count: count)
    let lettersCounts = letters.countSortedDuplicates()
    let lazyLettersCounts = letters.lazy.countSortedDuplicates()
    expectEqualCollections(lettersCounts.map(\.value), ["b"])
    expectEqualCollections(lettersCounts.map(\.count), [count])
    expectEqualCollections(letters.deduplicateSorted(), ["b"])
    expectEqualSequences(lazyLettersCounts.map(\.value), ["b"])
    expectEqualSequences(lazyLettersCounts.map(\.count), [count])
    expectEqualSequences(letters.lazy.deduplicateSorted(), ["b"])
  }

  /// Test multiple elements.
  func testMultiple() {
    let sample = "Xacccddffffxzz"
    let sampleCounts = sample.countSortedDuplicates()
    let expected: [(value: Character, count: Int)] = [
      ("X", 1),
      ("a", 1),
      ("c", 3),
      ("d", 2),
      ("f", 4),
      ("x", 1),
      ("z", 2),
    ]
    expectEqualCollections(sampleCounts.map(\.value), expected.map(\.0))
    expectEqualCollections(sampleCounts.map(\.count), expected.map(\.1))
    expectEqualCollections(sample.deduplicateSorted(), "Xacdfxz")

    let lazySampleCounts = sample.lazy.countSortedDuplicates()
    expectEqualSequences(lazySampleCounts.map(\.value), expected.map(\.0))
    expectEqualSequences(lazySampleCounts.map(\.count), expected.map(\.1))
    expectEqualSequences(sample.lazy.deduplicateSorted(), "Xacdfxz")
  }
}
