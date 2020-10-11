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

  let arraysToTest = [
    "kdrienspeksanewerdof",
    "ermdie,kdsap,erl;kamrek;qermdkll;rel;nsn8cvtt3w7flpr9ok2",
    "Woven silk pyjamas exchanged for blue quartz."
  ]

  let comparators : [(Character, Character) -> Bool] =
    [{$0 <= $1},
     {$1 <= $0}]

  let arraysToTestInt : [[Int]] = [
    [9, 2, 40, 302, 3, 321, 1, 3, 4],
    [4032, 3453, 2340, 9482, 8323, 34, 9284, 2342, 9233, 3454, 2395, 8273, 6574,
    8342, 7345, 9274, 3491, 9342, 8234, 7234, 6123, 8342, 7231, 9349]
  ]

  let comparatorsInt : [(Int, Int) -> Bool] =
    [{$0 <= $1},
     {$1 <= $0}]
  /**
   * Checks that root is more than any other element of the heap
   *   according to the comparator logic (where left < right)
   *   by calling the comparator repeatedly on the other elements.
   */
  func invariantRootIsMax<T>(heap: Heap<T>,
                             comparator: (T.Element, T.Element) -> Bool,
                             output: Bool = false)
                                -> Bool {

    if let rootValue = heap[0] {
      var i = 1
      while let toCompare = heap[i] {
        if output {
          print(i, toCompare, rootValue)
        }
        if !comparator(toCompare, rootValue) {
          return false
        }
        i += 1
      }
    }
    return true
  }

  func harness<T>(collection: T,
                  comparator: @escaping (T.Element, T.Element) -> Bool,
                  output: Bool = false)
                    where T: Collection {
    var heap = Heap(collection,
                    comparator: comparator)
    XCTAssert(invariantRootIsMax(heap: heap,
                                 comparator: comparator,
                                 output: output))
    var oldElementQ: T.Element? = .none

    XCTAssert(heap.consumedCount == 0)
    XCTAssert(heap.count == heap.collectionCount)

    while let newElement = heap.pop() {
      if let oldElement = oldElementQ {
        XCTAssert(comparator(newElement, oldElement))
        XCTAssert(invariantRootIsMax(heap: heap,
                                     comparator: comparator,
                                     output: output))

        XCTAssert(heap.collectionCount == heap.consumedCount + heap.count)

      }
      oldElementQ = newElement
    }

    XCTAssert(heap.consumedCount == heap.collectionCount)
    XCTAssert(heap.count == 0)
  }


  func testPopCharacters() {

    for arrayUnderTest : String in arraysToTest {
      for comparator in comparators {
        harness(collection: arrayUnderTest,
                comparator: comparator)
      }
    }
  }

  func testPopInts() {

    for arrayUnderTest : [Int] in arraysToTestInt {
      for comparator in comparatorsInt {
        harness(collection: arrayUnderTest,
                comparator: comparator)
      }
    }
  }


  func testSubCollections() {

    for arrayUnderTest : String in arraysToTest {
      for comparator in comparators {
        let startIndex = arrayUnderTest.index(arrayUnderTest.startIndex,
                                              offsetBy: 5)
        let endIndex = arrayUnderTest.index(arrayUnderTest.startIndex,
                                            offsetBy: 17)

        let subarray = arrayUnderTest[startIndex ..< endIndex]
        harness(collection: subarray,
                comparator: comparator)
      }
    }
  }

  func testChained() {

    let extraArray = "chain and train in vain"

    for arrayUnderTest : String in arraysToTest {
      for comparator in comparators {
        let chained = arrayUnderTest.chained(with: extraArray)

        harness(collection: chained,
                comparator: comparator)
      }
    }
  }

}

