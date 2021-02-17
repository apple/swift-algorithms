//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift Algorithms open source project
//
// Copyright (c) 2021 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

import XCTest
@testable import Algorithms

final class LazySplitCollectionTests: XCTestCase {
  func testInts() {
    let nums = [1, 2, 42, 3, 4, 42, 5, 6, 42, 7,]
    let expectedResult = nums.split(separator: 42)
    let testResult = nums.lazy.split(separator: 42)
    XCTAssertEqualSequences(testResult, expectedResult)
  }

  func testIntsWithMultipleAdjacentSeparators() {
    let nums = [1, 2, 42, 3, 4, 42, 42, 5, 6, 42, 7,]
    let expectedResult = nums.split(separator: 42)
    let testResult = nums.lazy.split(separator: 42)
    XCTAssertEqualSequences(testResult, expectedResult)
  }

  func testString() {
    let path = "archive.tar.gz"
    let expectedResult = path.split(separator: ".")
    let testResult = path.lazy.split(separator: ".")
    XCTAssertEqualSequences(testResult, expectedResult)
  }

  func testStringWithMultipleAdjacentSeparators() {
    let line = "BLANCHE:   I don't want realism. I want magic!"
    let expectedResult = line.split(separator: " ")
    let testResult = line.lazy.split(separator: " ")
    XCTAssertEqualSequences(testResult, expectedResult)
  }

  func testIntsWithMaxSplits() {
    let nums = [1, 2, 42, 3, 4, 42, 5, 6, 42, 7,]
    let expectedResult = nums.split(separator: 42, maxSplits: 2)
    let testResult = nums.lazy.split(separator: 42, maxSplits: 2)
    XCTAssertEqualSequences(testResult, expectedResult)
  }

  func testStringWithMaxSplits() {
    let path = "archive.tar.gz"
    let expectedResult = path.split(separator: ".", maxSplits: 1)
    let testResult = path.lazy.split(separator: ".", maxSplits: 1)
    XCTAssertEqualSequences(testResult, expectedResult)
  }

  func testIntsWithoutOmittingEmptySubsequences() {
    let nums = [1, 2, 42, 3, 4, 42, 42, 5, 6, 42, 7,]
    let expectedResult = nums.split(separator: 42, omittingEmptySubsequences: false)
    let testResult = nums.lazy.split(separator: 42, omittingEmptySubsequences: false)
    XCTAssertEqualSequences(testResult, expectedResult)
  }

  func testStringWithoutOmittingEmptySubsequences() {
    let line = "BLANCHE:   I don't want realism. I want magic!"
    let expectedResult = line.split(separator: " ", omittingEmptySubsequences: false)
    let testResult = line.lazy.split(separator: " ", omittingEmptySubsequences: false)
    XCTAssertEqualSequences(testResult, expectedResult)
  }

  func testIntsWithWhereClosure() {
    let nums = [1, 2, 3, 4, 5, 6, 7,]
    let isEven = { $0 % 2 == 0 }
    let expectedResult = nums.split(whereSeparator: isEven)
    let testResult = nums.lazy.split(whereSeparator: isEven)
    XCTAssertEqualSequences(testResult, expectedResult)
  }

  func testStringWithWhereClosure() {
    let line = "BLANCHE:   I don't want realism. I want magic!"
    let isSpace = { $0 == Character(" ") }
    let expectedResult = line.split(whereSeparator: isSpace)
    let testResult = line.lazy.split(whereSeparator: isSpace)
    XCTAssertEqualSequences(testResult, expectedResult)
  }

  func testSplitLazy() {
    let testSubject = "foo.bar".lazy.split(separator: ".")
    XCTAssertLazySequence(testSubject)
  }
}
