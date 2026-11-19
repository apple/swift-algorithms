//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift Algorithms open source project
//
// Copyright (c) 2022 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

import XCTest
@testable import Algorithms

final class MergeTests: XCTestCase {
  func testMergeArrays() {
    let evens = [0, 2, 4, 6, 8]
    let odds = [1, 3, 5, 7, 9]
    let output = merge(evens, odds)
    XCTAssertEqualSequences(output, 0...9)
  }
  
  func testMergeSequences() {
    let evens = stride(from: 0, to: 10, by: 2)
    let odds = stride(from: 1, to: 10, by: 2)
    let output = merge(evens, odds)
    XCTAssertEqualSequences(output, 0...9)
  }
  
  func testMergeMixedSequences() {
    let evens = [0, 2, 4, 6, 8]
    let odds = stride(from: 1, to: 10, by: 2)
    let output = merge(evens, odds)
    XCTAssertEqualSequences(output, 0...9)
  }
  
  func testMergeSequencesWithEqualElements() {
    let a = [1, 2, 3, 4, 5]
    let b = [1, 2, 3, 4, 5]
    let output = merge(a, b)
    XCTAssertEqualSequences(output, [1, 1, 2, 2, 3, 3, 4, 4, 5, 5])
  }
  
  func testMerge3Sequences() {
    let a = [0, 3, 6, 9]
    let b = [1, 5, 8, 10]
    let c = [2, 4, 7, 11]
    let output = merge(merge(a, b), c)
    XCTAssertEqualSequences(output, 0...11)
  }
  
  func testNonDefaultSortOrder() {
    let evens = [8, 6, 4, 2, 0]
    let odds = stride(from: 9, to: 0, by: -2)
    let output = merge(evens, odds, areInIncreasingOrder: >)
    XCTAssertEqualSequences(output, (0...9).reversed())
  }
}
