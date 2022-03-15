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
    
    func ts<R: RangeExpression>(count: R) where R.Bound == Int {
      let p = count.relative(to: 0 ..< .max)
        .clamped(to: 0 ..< c.count + 1)
        .flatMap {
          c.permutations(ofCount: $0)
        }
      
      let p2 = c.permutations(ofCount: count)
      
      XCTAssertEqual(p.count, p2.count)
      XCTAssertEqualSequences(p, Array(p2))
    }
    
    t(count: 0)
    t(count: 1)
    t(count: 2)
    t(count: 3)
    t(count: 4)
    t(count: 5)
    t(count: nil)
    
    ts(count: 0...0)
    ts(count: 1...1)
    ts(count: 0...1)
    ts(count: 0...2)
    ts(count: 0...3)
    ts(count: 1...3)
    ts(count: 2...3)
    ts(count: 0...)
    ts(count: ...5)
    ts(count: ...4)
    ts(count: ...6)
  }
  
  func testEmpty() {
    // `k == 0` results in one zero-length permutation
    XCTAssertEqual(1, "".permutations().count)
    XCTAssertEqual(1, "ABCD".permutations(ofCount: 0).count)
    XCTAssertEqual(1, "ABCD".permutations(ofCount: 0...0).count)
    XCTAssertEqual(Array("".permutations()), [[]])
    XCTAssertEqual(Array("".permutations(ofCount: 0)), [[]])
    XCTAssertEqual(Array("ABCD".permutations(ofCount: 0)), [[]])
    XCTAssertEqual(Array("ABCD".permutations(ofCount: 0...0)), [[]])
    
    // `k` greater than element count results in zero permutations
    XCTAssertEqual(0, "".permutations(ofCount: 5).count)
    XCTAssertEqual(Array("".permutations(ofCount: 5)), [])
    XCTAssertEqual(Array("ABCD".permutations(ofCount: 5)), [])
    XCTAssertEqual(Array("ABCD".permutations(ofCount: 5..<6)), [])
    XCTAssertEqual(Array("ABCD".permutations(ofCount: 5..<7)), [])
    XCTAssertEqual(Array("ABCD".permutations(ofCount: 5...)), [])
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
    XCTAssertLazySequence("ABCD".lazy.permutations(ofCount: 2))
  }
  
  func testDocumentationExample1() {
    // From Guides/Permutations.md
    let numbers = [10, 20, 30]
    let permutations = numbers.permutations()
    XCTAssertEqualSequences(permutations, [
      [10, 20, 30],
      [10, 30, 20],
      [20, 10, 30],
      [20, 30, 10],
      [30, 10, 20],
      [30, 20, 10],
    ])
  }
  
  func testDocumentationExample2() {
    // From Guides/Permutations.md
    let numbers = [10, 20, 30]
    let permutations = numbers.permutations(ofCount: 2)
    XCTAssertEqualSequences(permutations, [
      [10, 20],
      [10, 30],
      [20, 10],
      [20, 30],
      [30, 10],
      [30, 20],
    ])
  }
  
  func testDocumentationExample3() {
    // From Guides/Permutations.md
    let numbers2 = [20, 10, 10]
    let permutations = numbers2.permutations()
    XCTAssertEqualSequences(permutations, [
      [20, 10, 10],
      [20, 10, 10],
      [10, 20, 10],
      [10, 10, 20],
      [10, 20, 10],
      [10, 10, 20],
    ])
  }
  
  func testDocumentationExample4() {
    // From Guides/Permutations.md
    let numbers = [10, 20, 30]
    let permutations = numbers.permutations(ofCount: 0...)
    XCTAssertEqualSequences(permutations, [
      [],
      [10],
      [20],
      [30],
      [10, 20],
      [10, 30],
      [20, 10],
      [20, 30],
      [30, 10],
      [30, 20],
      [10, 20, 30],
      [10, 30, 20],
      [20, 10, 30],
      [20, 30, 10],
      [30, 10, 20],
      [30, 20, 10],
    ])
  }
  
  func testDocumentationExample5() {
    // From Permutations.swift
    let names = ["Alex", "Celeste", "Davide"]
    let permutations = names.permutations(ofCount: 2)
    XCTAssertEqualSequences(permutations, [
      ["Alex", "Celeste"],
      ["Alex", "Davide"],
      ["Celeste", "Alex"],
      ["Celeste", "Davide"],
      ["Davide", "Alex"],
      ["Davide", "Celeste"],
    ])
  }
  
  func testDocumentationExample6() {
    // From Permutations.swift
    let names = ["Alex", "Celeste", "Davide"]
    let permutations = names.permutations(ofCount: 1...2)
    XCTAssertEqualSequences(permutations, [
      ["Alex"],
      ["Celeste"],
      ["Davide"],
      ["Alex", "Celeste"],
      ["Alex", "Davide"],
      ["Celeste", "Alex"],
      ["Celeste", "Davide"],
      ["Davide", "Alex"],
      ["Davide", "Celeste"],
    ])
  }
}
