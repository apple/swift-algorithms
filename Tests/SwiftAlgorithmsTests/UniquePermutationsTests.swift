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

final class UniquePermutationsTests: XCTestCase {
  static let numbers = [1, 1, 1, 2, 3]
  
  static let numbersPermutations: [[[Int]]] = [
    // 0
    [[]],
    // 1
    [[1], [2], [3]],
    // 2
    [[1, 1], [1, 2], [1, 3], [2, 1], [2, 3], [3, 1], [3, 2]],
    // 3
    [[1, 1, 1], [1, 1, 2], [1, 1, 3],
     [1, 2, 1], [1, 2, 3], [1, 3, 1], [1, 3, 2],
     [2, 1, 1], [2, 1, 3], [2, 3, 1],
     [3, 1, 1], [3, 1, 2], [3, 2, 1]],
    // 4
    [[1, 1, 1, 2], [1, 1, 1, 3],
     [1, 1, 2, 1], [1, 1, 2, 3],
     [1, 1, 3, 1], [1, 1, 3, 2],
     [1, 2, 1, 1], [1, 2, 1, 3], [1, 2, 3, 1],
     [1, 3, 1, 1], [1, 3, 1, 2], [1, 3, 2, 1],
     [2, 1, 1, 1], [2, 1, 1, 3], [2, 1, 3, 1], [2, 3, 1, 1],
     [3, 1, 1, 1], [3, 1, 1, 2], [3, 1, 2, 1], [3, 2, 1, 1]],
    // 5
    [[1, 1, 1, 2, 3], [1, 1, 1, 3, 2],
     [1, 1, 2, 1, 3], [1, 1, 2, 3, 1],
     [1, 1, 3, 1, 2], [1, 1, 3, 2, 1],
     [1, 2, 1, 1, 3], [1, 2, 1, 3, 1], [1, 2, 3, 1, 1],
     [1, 3, 1, 1, 2], [1, 3, 1, 2, 1], [1, 3, 2, 1, 1],
     [2, 1, 1, 1, 3], [2, 1, 1, 3, 1], [2, 1, 3, 1, 1], [2, 3, 1, 1, 1],
     [3, 1, 1, 1, 2], [3, 1, 1, 2, 1], [3, 1, 2, 1, 1], [3, 2, 1, 1, 1]]
  ]
  
  static var numbersAndNils: [Int?] {
    numbers.map { $0 == 1 ? nil : $0 }
  }
  
  static var numbersAndNilsPermutations: [[ArraySlice<Int?>]] {
    numbersPermutations.map { $0.map { ArraySlice($0.map { $0 == 1 ? nil : $0 }) }}
  }
}

extension UniquePermutationsTests {
  func testEmpty() {
    XCTAssertEqualSequences(([] as [Int]).uniquePermutations(), [[]])
    XCTAssertEqualSequences(([] as [Int]).uniquePermutations(ofCount: 0), [[]])
    XCTAssertEqualSequences(([] as [Int]).uniquePermutations(ofCount: 1), [])
    XCTAssertEqualSequences(([] as [Int]).uniquePermutations(ofCount: 1...3), [])
  }
  
  func testSingleCounts() {
    for (k, expectation) in Self.numbersPermutations.enumerated() {
      XCTAssertEqualSequences(expectation, Self.numbers.uniquePermutations(ofCount: k))
    }
  }
  
  func testRanges() {
    for lower in Self.numbersPermutations.indices {
      // upper bounded
      XCTAssertEqualSequences(
        Self.numbersPermutations[...lower].joined(),
        Self.numbers.uniquePermutations(ofCount: ...lower))
      
      // lower bounded
      XCTAssertEqualSequences(
        Self.numbersPermutations[lower...].joined(),
        Self.numbers.uniquePermutations(ofCount: lower...))

      for upper in lower..<Self.numbersPermutations.count {
        XCTAssertEqualSequences(
          Self.numbersPermutations[lower..<upper].joined(),
          Self.numbers.uniquePermutations(ofCount: lower..<upper))
      }
    }
  }

//  func testEmptyWithPredicate() {
//    XCTAssertEqualSequences(([] as [Int?]).uniquePermutations(by: <), [[]])
//    XCTAssertEqualSequences(([] as [Int?]).uniquePermutations(ofCount: 0, by: <), [[]])
//    XCTAssertEqualSequences(([] as [Int?]).uniquePermutations(ofCount: 1, by: <), [])
//    XCTAssertEqualSequences(([] as [Int?]).uniquePermutations(ofCount: 1...3, by: <), [])
//  }
//
//  func testSingleCountsWithPredicate() {
//    for (k, expectation) in Self.numbersAndNilsPermutations.enumerated() {
//      XCTAssertEqualSequences(expectation, Self.numbersAndNils.uniquePermutations(ofCount: k, by: <))
//    }
//  }
//
//  func testRangesWithPredicate() {
//    let numbersAndNils = Self.numbersAndNils
//    let numbersAndNilsPermutations = Self.numbersAndNilsPermutations
//
//    for lower in numbersAndNilsPermutations.indices {
//      // upper bounded
//      XCTAssertEqualSequences(
//        numbersAndNilsPermutations[...lower].joined(),
//        numbersAndNils.uniquePermutations(ofCount: ...lower, by: <))
//
//      // lower bounded
//      XCTAssertEqualSequences(
//        numbersAndNilsPermutations[lower...].joined(),
//        numbersAndNils.uniquePermutations(ofCount: lower..., by: <))
//
//      for upper in lower..<numbersAndNilsPermutations.count {
//        XCTAssertEqualSequences(
//          numbersAndNilsPermutations[lower..<upper].joined(),
//          numbersAndNils.uniquePermutations(ofCount: lower..<upper, by: <))
//      }
//    }
//  }
}
