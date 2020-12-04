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
  func testCount() {
    let c = "ABCD"
    
    let c0 = c.combinations(ofCount: 0).count
    XCTAssertEqual(c0, 1)
    
    let c1 = c.combinations(ofCount: 1).count
    XCTAssertEqual(c1, 4)
    
    let c2 = c.combinations(ofCount: 2).count
    XCTAssertEqual(c2, 6)
    
    let c3 = c.combinations(ofCount: 3).count
    XCTAssertEqual(c3, 4)
    
    let c4 = c.combinations(ofCount: 4).count
    XCTAssertEqual(c4, 1)
  }
  
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
    XCTAssertLazySequence("ABC".lazy.combinations(ofCount: 1))
  }
}
