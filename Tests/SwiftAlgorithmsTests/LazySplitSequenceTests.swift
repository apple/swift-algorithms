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

import Algorithms
import XCTest

final class LazySplitSequenceTests: XCTestCase {
  fileprivate static let isEven = { $0 % 2 == 0 }

  func testOneSeparator() {
    let nums = stride(from: 1, through: 10, by: 1)
    let expectedResult = nums.split(separator: 7).map { Array($0) }
    let testResult = nums.lazy.split(separator: 7)
    XCTAssertEqualSequences(testResult, expectedResult)
  }

  func testEndsWithSeparatorWithClosure() {
    let nums = stride(from: 1, through: 10, by: 1)
    let expectedResult = nums.split(
      whereSeparator: LazySplitSequenceTests.isEven
    ).map { Array($0) }
    let testResult = nums.lazy.split(
      whereSeparator: LazySplitSequenceTests.isEven)
    XCTAssertEqualSequences(testResult, expectedResult)
  }

  func testEndsWithSeparatorWithClosureNotOmittingEmptySubsequences() {
    let nums = stride(from: 1, through: 10, by: 1)
    let expectedResult = nums.split(
      omittingEmptySubsequences: false,
      whereSeparator: LazySplitSequenceTests.isEven
    ).map { Array($0) }
    let testResult = nums.lazy.split(
      omittingEmptySubsequences: false,
      whereSeparator: LazySplitSequenceTests.isEven)
    XCTAssertEqualSequences(testResult, expectedResult)
  }

  func testAllSeparators() {
    let evens = stride(from: 2, through: 6, by: 2)
    let expectedResult = evens.split(
      whereSeparator: LazySplitSequenceTests.isEven
    ).map {
      Array($0)
    }
    let testResult = evens.lazy.split(
      whereSeparator: LazySplitSequenceTests.isEven)
    XCTAssertEqualSequences(testResult, expectedResult)
  }

  func testAllSeparatorsNotOmittingEmptySubsequences() {
    let evens = stride(from: 2, through: 6, by: 2)
    let expectedResult = evens.split(
      omittingEmptySubsequences: false,
      whereSeparator: LazySplitSequenceTests.isEven
    ).map { Array($0) }
    let testResult = evens.lazy.split(
      omittingEmptySubsequences: false,
      whereSeparator: LazySplitSequenceTests.isEven
    )
    XCTAssertEqualSequences(testResult, expectedResult)
  }

  func testMaxSplits() {
    let nums = stride(from: 1, through: 10, by: 1)
    let expectedResult = nums.split(
      maxSplits: 2,
      whereSeparator: LazySplitSequenceTests.isEven
    ).map { Array($0) }
    let testResult = nums.lazy.split(
      maxSplits: 2,
      whereSeparator: LazySplitSequenceTests.isEven
    )
    XCTAssertEqualSequences(testResult, expectedResult)
  }

  // Exercise the end-of-list logic to make sure we don't, for example, repeat
  // the last element when there are an equal or greater number of separators
  // than elements.
  func testSepCountEqualElemCount() {
    let nums = AnySequence([1, 0, 0, 2])
    let expectedResult = nums.split(separator: 0).map { Array($0) }
    let testResult = nums.lazy.split(separator: 0)
    XCTAssertEqualSequences(testResult, expectedResult)
  }

  func testSepCountEqualElemCountNotOmittingEmpty() {
    let nums = AnySequence([1, 0, 0, 2])
    let expectedResult = nums.split(
      separator: 0,
      omittingEmptySubsequences: false
    ).map { Array($0) }
    let testResult = nums.lazy.split(
      separator: 0,
      omittingEmptySubsequences: false
    )
    XCTAssertEqualSequences(testResult, expectedResult)
  }

  func testSepCountMoreThanElemCountStartsWithSep() {
    let nums = AnySequence([0, 1, 0, 0, 2])
    let expectedResult = nums.split(separator: 0).map { Array($0) }
    let testResult = nums.lazy.split(separator: 0)
    XCTAssertEqualSequences(testResult, expectedResult)
  }

  func testSepCountMoreThanElemCountStartsWithSepNotOmittingEmpty() {
    let nums = AnySequence([0, 1, 0, 0, 2])
    let expectedResult = nums.split(
      separator: 0,
      omittingEmptySubsequences: false
    ).map { Array($0) }
    let testResult = nums.lazy.split(
      separator: 0,
      omittingEmptySubsequences: false
    )
    XCTAssertEqualSequences(testResult, expectedResult)
  }

  func testSepCountMoreThanElemCountStartsWithElem() {
    let nums = AnySequence([1, 0, 0, 0, 0, 2, 0, 3])
    let expectedResult = nums.split(separator: 0).map { Array($0) }
    let testResult = nums.lazy.split(separator: 0)
    XCTAssertEqualSequences(testResult, expectedResult)
  }

  func testSepCountMoreThanElemCountStartsWithElemNotOmittingEmpty() {
    let nums = AnySequence([1, 0, 0, 0, 0, 2, 0, 3])
    let expectedResult = nums.split(
      separator: 0,
      omittingEmptySubsequences: false
    ).map { Array($0) }
    let testResult = nums.lazy.split(
      separator: 0,
      omittingEmptySubsequences: false
    )
    XCTAssertEqualSequences(testResult, expectedResult)
  }
}
