//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift Algorithms open source project
//
// Copyright (c) 2020-2021 Apple Inc. and the Swift project authors
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
    
    let c5 = c.combinations(ofCount: 0...0).count
    XCTAssertEqual(c5, 1)
    
    let c6 = c.combinations(ofCount: 1...1).count
    XCTAssertEqual(c6, 4)
    
    let c7 = c.combinations(ofCount: 1...2).count
    XCTAssertEqual(c7, 10)
    
    let c8 = c.combinations(ofCount: 1...3).count
    XCTAssertEqual(c8, 14)
    
    let c9 = c.combinations(ofCount: 2...4).count
    XCTAssertEqual(c9, 11)
    
    // `k` greater than element count results in same number of combinations
    let c10 = c.combinations(ofCount: 3...10).count
    XCTAssertEqual(c10, 5)
    
    // `k` greater than element count results in same number of combinations
    let c11 = c.combinations(ofCount: 4...10).count
    XCTAssertEqual(c11, 1)
    
    // `k` entirely greater than element count results in no combinations
    let c12 = c.combinations(ofCount: 5...10).count
    XCTAssertEqual(c12, 0)
    
    let c13 = c.combinations(ofCount: 0...).count
    XCTAssertEqual(c13, 16)
    
    let c14 = c.combinations(ofCount: ...3).count
    XCTAssertEqual(c14, 15)
    
    let c15 = c.combinations(ofCount: 0...).count
    XCTAssertEqual(c15, 16)
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
    
    let c5 = c.combinations(ofCount: 2...4)
    XCTAssertEqual(["AB", "AC", "AD", "BC", "BD", "CD", "ABC", "ABD", "ACD", "BCD", "ABCD"], c5.map { String($0) })
    
    let c6 = c.combinations(ofCount: 0...4)
    XCTAssertEqual(["", "A", "B", "C", "D", "AB", "AC", "AD", "BC", "BD", "CD", "ABC", "ABD", "ACD", "BCD", "ABCD"], c6.map { String($0) })
    
    let c7 = c.combinations(ofCount: 0...)
    XCTAssertEqual(["", "A", "B", "C", "D", "AB", "AC", "AD", "BC", "BD", "CD", "ABC", "ABD", "ACD", "BCD", "ABCD"], c7.map { String($0) })
    
    let c8 = c.combinations(ofCount: ...4)
    XCTAssertEqual(["", "A", "B", "C", "D", "AB", "AC", "AD", "BC", "BD", "CD", "ABC", "ABD", "ACD", "BCD", "ABCD"], c8.map { String($0) })
    
    let c9 = c.combinations(ofCount: ...3)
    XCTAssertEqual(["", "A", "B", "C", "D", "AB", "AC", "AD", "BC", "BD", "CD", "ABC", "ABD", "ACD", "BCD"], c9.map { String($0) })
    
    let c10 = c.combinations(ofCount: 1...)
    XCTAssertEqual(["A", "B", "C", "D", "AB", "AC", "AD", "BC", "BD", "CD", "ABC", "ABD", "ACD", "BCD", "ABCD"], c10.map { String($0) })
  }
  
  func testEmpty() {
    // `k == 0` results in one zero-length combination
    XCTAssertEqualSequences([[]], "".combinations(ofCount: 0))
    XCTAssertEqualSequences([[]], "".combinations(ofCount: 0...0))
    XCTAssertEqualSequences([[]], "ABCD".combinations(ofCount: 0))
    XCTAssertEqualSequences([[]], "ABCD".combinations(ofCount: 0...0))
    
    // `k` greater than element count results in zero combinations
    XCTAssertEqualSequences([], "".combinations(ofCount: 5))
    XCTAssertEqualSequences([], "".combinations(ofCount: 5...10))
    XCTAssertEqualSequences([], "ABCD".combinations(ofCount: 5))
    XCTAssertEqualSequences([], "ABCD".combinations(ofCount: 5...10))
  }
  
  func testCombinationsLazy() {
    XCTAssertLazySequence("ABC".lazy.combinations(ofCount: 1))
    XCTAssertLazySequence("ABC".lazy.combinations(ofCount: 1...3))
    XCTAssertLazySequence("ABC".lazy.combinations(ofCount: 1...))
    XCTAssertLazySequence("ABC".lazy.combinations(ofCount: ...3))
    XCTAssertLazySequence("ABC".lazy.combinations(ofCount: 0...))
  }
}
