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
@testable import Algorithms

final class PermutationsTests: XCTestCase {
  func testPermutations() {
    let c = "ABCDE"
    
    func t(count: Int?) {
      let p = c.permutations(ofCount: count)
      
      let count = count ?? c.count
      let permCount = c.count.factorial() / (c.count - count).factorial()
      XCTAssertEqual(permCount, p.count)
      XCTAssertEqual(p.count, Array(p).count)
      XCTAssertTrue(p.allSatisfy { $0.count == count })
      XCTAssertTrue(p.isSorted(by: { $0.lexicographicallyPrecedes($1) }))
    }

    t(count: 1)
    t(count: 2)
    t(count: 3)
    t(count: 4)
    t(count: 5)
    t(count: nil)
  }
  
  func testEmpty() {
    // `k == 0` results in one zero-length permutation
    XCTAssertEqual(1, "".permutations().count)
    XCTAssertEqual(1, "ABCD".permutations(ofCount: 0).count)
    XCTAssertEqual(Array("".permutations()), [[]])
    XCTAssertEqual(Array("".permutations(ofCount: 0)), [[]])
    XCTAssertEqual(Array("ABCD".permutations(ofCount: 0)), [[]])
    
    // `k` greater than element count results in zero permutations
    XCTAssertEqual(0, "".permutations(ofCount: 5).count)
    XCTAssertEqual(Array("".permutations(ofCount: 5)), [])
    XCTAssertEqual(Array("ABCD".permutations(ofCount: 5)), [])
  }
  
  func testNextPermutation() {
    var numbers = Array(1...7)
    
    _ = numbers.nextPermutation()
    XCTAssertEqual([1, 2, 3, 4, 5, 7, 6], numbers)
    _ = numbers.nextPermutation()
    XCTAssertEqual([1, 2, 3, 4, 6, 5, 7], numbers)
    _ = numbers.nextPermutation()
    XCTAssertEqual([1, 2, 3, 4, 6, 7, 5], numbers)
    _ = numbers.nextPermutation()
    XCTAssertEqual([1, 2, 3, 4, 7, 5, 6], numbers)
    _ = numbers.nextPermutation()
    XCTAssertEqual([1, 2, 3, 4, 7, 6, 5], numbers)
    _ = numbers.nextPermutation()
    XCTAssertEqual([1, 2, 3, 5, 4, 6, 7], numbers)

    // Fast-forward to end of permutations.
    while numbers.nextPermutation() {}
    XCTAssertEqual([1, 2, 3, 4, 5, 6, 7], numbers)
  }
  
  func testPermutationsLazy() {
    XCTAssertLazy("ABCD".lazy.permutations(ofCount: 2))
  }
}
