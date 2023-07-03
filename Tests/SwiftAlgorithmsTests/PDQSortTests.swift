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

final class PDQSortTests: XCTestCase {
  func testPartitionLeft() {
    for _ in 1...1000 {
      var a = (0...20).map { _ in Int.random(in: 1...5) }
      a._preparePivot(subrange: a.indices, count: a.indices.count, by: <)
      let pivot = a._partitionLeft(subrange: a.indices, by: <)
      for x in a[..<pivot] {
        XCTAssertLessThanOrEqual(x, a[pivot])
      }
      for x in a[(pivot + 1)...] {
        XCTAssertGreaterThan(x, a[pivot])
      }
    }
  }
  
  func testPartitionRight() {
    for _ in 1...1000 {
      var a = (0...20).map { _ in Int.random(in: 1...5) }
      a._preparePivot(subrange: a.indices, count: a.indices.count, by: <)
      let (pivot, _) = a._partitionRight(subrange: a.indices, by: <)
      for x in a[..<pivot] {
        XCTAssertLessThan(x, a[pivot])
      }
      for x in a[(pivot + 1)...] {
        XCTAssertGreaterThanOrEqual(x, a[pivot])
      }
    }
  }

  func testSort() {
    var empty: [Int] = []
    empty.sortUnstable()
    
    var inOrder = Array(1...1000)
    inOrder.sortUnstable()
    XCTAssert(inOrder.isSorted())
    
    var reversed = Array((1...1000).reversed())
    reversed.sortUnstable()
    XCTAssert(reversed.isSorted())
    
    for _ in 1...1000 {
      var a = (0...Int.random(in: 100...1000)).map { _ in Int.random(in: 1...50) }
      a.sortUnstable()
      XCTAssert(a.isSorted())
    }
  }
  
  func testSpecialCase() {
    var a = (1...10).shuffled() + [20] + (31...40).shuffled()
    a.sortUnstable()
    XCTAssert(a.isSorted())
  }
}
