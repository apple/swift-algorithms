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

    /// XCTAsserts that `x`'s `count` and `underestimatedCount` are both `l` at
    /// the given `file` and `line`.
    func check(
      _ x: CombinationsSequence<String>, countsAre l: Int,
      file: StaticString, line: UInt)
    {
      XCTAssertEqual(x.count, l, "unexpected count", file: file, line: line)
      XCTAssertEqual(
        x.underestimatedCount, l, "unexpected underestimatedCount",
        file: file, line: line)
    }

    /// XCTAsserts that the `count` and `underestimatedCount` of
    /// `c.combinations(ofCount: l)` are both `n` at the given `file` and
    /// `line`.
    func check(
      cHas n: Int,
      combinationsOfLength l: Int,
      file: StaticString = #filePath, line: UInt = #line)
    {
      check(c.combinations(ofCount: l), countsAre: n, file: file, line: line)
    }

    /// XCTAsserts that the `count` and `underestimatedCount` of
    /// `c.combinations(ofCount: l)` are both `n` at the given `file` and
    /// `line`.
    func check<R: RangeExpression>(
      cHas n: Int,
      combinationsOfLengths l: R,
      file: StaticString = #filePath, line: UInt = #line) where R.Bound == Int
    {
      check(c.combinations(ofCount: l), countsAre: n, file: file, line: line)
    }

    check(cHas: 1, combinationsOfLength: 0)
    check(cHas: 4, combinationsOfLength: 1)
    check(cHas: 6, combinationsOfLength: 2)
    check(cHas: 1, combinationsOfLength: 4)

    check(cHas: 1, combinationsOfLengths: 0...0)
    check(cHas: 4, combinationsOfLengths: 1...1)
    check(cHas: 10, combinationsOfLengths: 1...2)
    check(cHas: 14, combinationsOfLengths: 1...3)
    check(cHas: 11, combinationsOfLengths: 2...4)

    // `k` greater than element count results in same number of combinations
    check(cHas: 5, combinationsOfLengths: 3...10)
    
    // `k` greater than element count results in same number of combinations
    check(cHas: 1, combinationsOfLengths: 4...10)
    
    // `k` entirely greater than element count results in no combinations
    check(cHas: 0, combinationsOfLengths: 5...10)
    
    check(cHas: 16, combinationsOfLengths: 0...)
    check(cHas: 15, combinationsOfLengths: ...3)
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
