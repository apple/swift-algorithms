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

//===----------------------------------------------------------------------===//
// Tests for `LazySplitSequence`
//===----------------------------------------------------------------------===//
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

//===----------------------------------------------------------------------===//
// Tests for `LazySplitCollection`
//===----------------------------------------------------------------------===//
final class LazySplitCollectionTests: XCTestCase {
  func testInts() {
    let nums = [1, 2, 42, 3, 4, 42, 5, 6, 42, 7]
    let expectedResult = nums.split(separator: 42)
    let testResult = nums.lazy.split(separator: 42)
    XCTAssertEqualSequences(testResult, expectedResult)
  }

  func testIntsWithWhereClosure() {
    let nums = [1, 2, 3, 4, 5, 6, 7]
    let isEven = { $0 % 2 == 0 }
    let expectedResult = nums.split(whereSeparator: isEven)
    let testResult = nums.lazy.split(whereSeparator: isEven)
    XCTAssertEqualSequences(testResult, expectedResult)
  }

  func testIntsWithMaxSplits() {
    let nums = [1, 2, 42, 3, 4, 42, 5, 6, 42, 7]
    let expectedResult = nums.split(separator: 42, maxSplits: 2)
    let testResult = nums.lazy.split(separator: 42, maxSplits: 2)
    XCTAssertEqualSequences(testResult, expectedResult)
  }

  func testZeroMaxSplits() {
    let nums = [1, 2, 42, 3, 4, 42, 5, 6, 42, 7]
    let expectedResult = nums.split(separator: 42, maxSplits: 0)
    let testResult = nums.lazy.split(separator: 42, maxSplits: 0)
    XCTAssertEqualSequences(testResult, expectedResult)
  }

  func testIntsNotOmittingEmpty() {
    let nums = [1, 2, 42, 3, 4, 42, 42, 5, 6, 42, 7]
    let expectedResult = nums.split(
      separator: 42, omittingEmptySubsequences: false)
    let testResult = nums.lazy.split(
      separator: 42, omittingEmptySubsequences: false)
    XCTAssertEqualSequences(testResult, expectedResult)
  }

  func testIntsEndsWithSeparatorNotOmittingEmpty() {
    let nums = [7, 42]
    let expectedResult = nums.split(
      separator: 42,
      omittingEmptySubsequences: false
    )
    let testResult = nums.lazy.split(
      separator: 42,
      omittingEmptySubsequences: false
    )
    XCTAssertEqualSequences(testResult, expectedResult)
  }

  func testIntsWithMultipleAdjacentSeparators() {
    let nums = [1, 2, 42, 3, 4, 42, 42, 5, 6, 42, 7]
    let expectedResult = nums.split(separator: 42)
    let testResult = nums.lazy.split(separator: 42)
    XCTAssertEqualSequences(testResult, expectedResult)
  }

  func testIntsWithTrailingMultipleAdjacentSeparators() {
    let nums = [1, 2, 42, 3, 4, 42, 42, 5, 6, 42, 7, 42, 42, 42]
    let expectedResult = nums.split(separator: 42)
    let testResult = nums.lazy.split(separator: 42)
    XCTAssertEqualSequences(testResult, expectedResult)
  }

  func testIntsWithTrailingMultipleAdjacentSeparatorsNotOmittingEmpty() {
    let nums = [1, 2, 42, 3, 4, 42, 42, 5, 6, 42, 7, 42, 42, 42]
    let expectedResult = nums.split(
      separator: 42, omittingEmptySubsequences: false)
    let testResult = nums.lazy.split(
      separator: 42, omittingEmptySubsequences: false)
    XCTAssertEqualSequences(testResult, expectedResult)
  }

  func testIntsAllSeparators() {
    let nums = [42, 42, 42, 42, 42]
    let expectedResult = nums.split(separator: 42)
    let testResult = nums.lazy.split(separator: 42)
    XCTAssertEqualSequences(testResult, expectedResult)
  }

  func testIntsAllSeparatorsNotOmittingEmpty() {
    let nums = [42, 42, 42, 42, 42]
    let expectedResult = nums.split(
      separator: 42, omittingEmptySubsequences: false)
    let testResult = nums.lazy.split(
      separator: 42, omittingEmptySubsequences: false)
    XCTAssertEqualSequences(testResult, expectedResult)
  }

  func testIntsStartWithSeparator() {
    let nums = [42, 1, 2, 42, 3, 4, 42, 5, 6, 42, 7]
    let expectedResult = nums.split(separator: 42)
    let testResult = nums.lazy.split(separator: 42)
    XCTAssertEqualSequences(testResult, expectedResult)
  }

  func testIntsStartWithSeparatorNotOmittingEmpty() {
    let nums = [42, 1, 2, 42, 3, 4, 42, 5, 6, 42, 7]
    let expectedResult = nums.split(
      separator: 42, omittingEmptySubsequences: false)
    let testResult = nums.lazy.split(
      separator: 42, omittingEmptySubsequences: false)
    XCTAssertEqualSequences(testResult, expectedResult)
  }

  func testIntsStartWithSeparatorMaxSplitsNotOmittingEmpty() {
    let nums = [42, 1, 2, 42, 3, 4, 42, 5, 6, 42, 7]
    let expectedResult = nums.split(
      separator: 42, maxSplits: 2, omittingEmptySubsequences: false)
    let testResult = nums.lazy.split(
      separator: 42, maxSplits: 2, omittingEmptySubsequences: false)
    XCTAssertEqualSequences(testResult, expectedResult)
  }

  func testIntsSingleElement() {
    let num = [1]
    let expectedResult = num.split(separator: 42)
    let testResult = num.lazy.split(separator: 42)
    XCTAssertEqualSequences(testResult, expectedResult)
  }

  func testIntsSingleSeparator() {
    let num = [42]
    let expectedResult = num.split(separator: 42)
    let testResult = num.lazy.split(separator: 42)
    XCTAssertEqualSequences(testResult, expectedResult)
  }

  func testIntsSingleSeparatorNotOmittingEmpty() {
    let num = [42]
    let expectedResult = num.split(
      separator: 42, omittingEmptySubsequences: false)
    let testResult = num.lazy.split(
      separator: 42, omittingEmptySubsequences: false)
    XCTAssertEqualSequences(testResult, expectedResult)
  }

  func testIntsNonSeparatorSandwich() {
    let nums = [42, 1, 42]
    let expectedResult = nums.split(separator: 42)
    let testResult = nums.lazy.split(separator: 42)
    XCTAssertEqualSequences(testResult, expectedResult)
  }

  func testIntsNonSeparatorSandwichNotOmittingEmpty() {
    let nums = [42, 1, 42]
    let expectedResult = nums.split(
      separator: 42, omittingEmptySubsequences: false)
    let testResult = nums.lazy.split(
      separator: 42, omittingEmptySubsequences: false)
    XCTAssertEqualSequences(testResult, expectedResult)
  }

  func testIntsEmptyEquatableCollection() {
    let empty: [Int] = []
    let expectedResult = empty.split(separator: 42)
    let testResult = empty.lazy.split(separator: 42)
    XCTAssertEqualSequences(expectedResult, testResult)
  }

  func testIntsEmptyEquatableCollectionNotOmittingEmpty() {
    let empty: [Int] = []
    let expectedResult = empty.split(
      separator: 42,
      omittingEmptySubsequences: false
    )
    let testResult = empty.lazy.split(
      separator: 42,
      omittingEmptySubsequences: false
    )
    XCTAssertEqualSequences(expectedResult, testResult)
  }

  func testIntsSepCountEqualOrMoreThanElemCount() {
    let nums = [0, 1, 0, 0, 2]
    let expectedResult = nums.split(separator: 0)
    let testResult = nums.lazy.split(separator: 0)
    XCTAssertEqualSequences(testResult, expectedResult)
  }

  func testIntsSepCountEqualOrMoreThanElemCountNotOmittingEmpty() {
    let nums = [0, 1, 0, 0, 2]
    let expectedResult = nums.split(
      separator: 0,
      omittingEmptySubsequences: false
    )
    let testResult = nums.lazy.split(
      separator: 0,
      omittingEmptySubsequences: false
    )
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

  func testStringWithMaxSplits() {
    let path = "archive.tar.gz"
    let expectedResult = path.split(separator: ".", maxSplits: 1)
    let testResult = path.lazy.split(separator: ".", maxSplits: 1)
    XCTAssertEqualSequences(testResult, expectedResult)
  }

  func testStringNotOmittingEmpty() {
    let line = "BLANCHE:   I don't want realism. I want magic!"
    let expectedResult = line.split(
      separator: " ", omittingEmptySubsequences: false)
    let testResult = line.lazy.split(
      separator: " ", omittingEmptySubsequences: false)
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