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

final class CombinationsTests: XCTestCase {
  func testCombinations() {
    let c = "ABCD"

    let c1 = c.combinations(ofCount: 1)
    XCTAssertEqual(["A", "B", "C", "D"], c1.map { String($0) })

    let c2 = c.combinations(ofCount: 2)
    XCTAssertEqual(["AB", "AC", "AD", "BC", "BD", "CD"], c2.map { String($0) })

    let c3 = c.combinations(ofCount: 3)
    XCTAssertEqual(["ABC", "ABD", "ACD", "BCD"], c3.map { String($0) })

    let c4 = c.combinations(ofCount: 4)
    XCTAssertEqual(["ABCD"], c4.map { String($0) })
  }
  
  func testEmpty() {
    // `k == 0` results in one zero-length combination
    XCTAssertEqualSequences([[]], "".combinations(ofCount: 0))
    XCTAssertEqualSequences([[]], "ABCD".combinations(ofCount: 0))

    // `k` greater than element count results in zero combinations
    XCTAssertEqualSequences([], "".combinations(ofCount: 5))
    XCTAssertEqualSequences([], "ABCD".combinations(ofCount: 5))
  }
  
  func testCombinationsLazy() {
    XCTAssertLazy("ABC".lazy.combinations(ofCount: 1))
  }
}
