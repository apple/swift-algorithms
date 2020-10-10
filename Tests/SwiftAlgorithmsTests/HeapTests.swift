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

final class HeapTests: XCTestCase {

  func testPopCharacters() {
    let arraysToTest = [
      "kdrienspeksanewerdof",
      "ermdie,kdsap,erl;kamrek;qermdkll;rel;nsn8cvtt3w7flpr9ok2"
    ]

    let comparators : [(Character, Character) -> Bool] =
      [{$0 <= $1},
       {$1 <= $0}]
    for arrayUnderTest in arraysToTest {
      for comparator in comparators {
        var heap = Heap(arrayUnderTest, comparator: comparator)

        var oldChar: Character? = .none
        while let newchar = heap.pop() {
          if let old = oldChar {
            XCTAssert(comparator(newchar, old))
          }
          oldChar = newchar
          print(newchar)
        }
      }
    }
  }

  func testPopInts() {
    let arraysToTest = [
      [9, 2, 40, 302, 3, 321, 1, 3, 4],
      [4032, 3453, 2340, 9482, 8323, 34, 9284, 2342, 9233, 3454, 2395, 8273, 6574,
      8342, 7345, 9274, 3491, 9342, 8234, 7234, 6123, 8342, 7231, 9349]
    ]

    let comparators : [(Int, Int) -> Bool] =
      [{$0 <= $1},
       {$1 <= $0}]
    for arrayUnderTest in arraysToTest {
      for comparator in comparators {
        var heap = Heap(arrayUnderTest, comparator: comparator)

        var oldValue: Int? = .none
        while let newValue = heap.pop() {
          if let old = oldValue {
            XCTAssert(comparator(newValue, old))
          }
          oldValue = newValue
          print(newValue)
        }
      }
    }
  }
}
