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
  func testBinaryTree() {
    let c = "ABCDEFGHIJKLMNOPQRSTUVWXYZA"

    let leftIndex = c.index(c.startIndex, offsetBy: 7)
    let rightIndex = c.index(c.startIndex, offsetBy: 22)
    let arrayUnderTest = c[leftIndex...rightIndex]

    let heap = arrayUnderTest.heap()

    for j in arrayUnderTest.indices {

      let leftChildIndex = heap.leftChild(x: j)
      let rightChildIndex = heap.rightChild(x: j)
      let parentIndex = heap.parent(x: j)

      let value = arrayUnderTest[j]
      let leftValue = leftChildIndex.map {arrayUnderTest[$0]} ?? "ø"
      let rightValue = rightChildIndex.map {arrayUnderTest[$0]} ?? "ø"
      let parentValue = parentIndex.map {arrayUnderTest[$0]} ?? "ø"

//      let jDistance = arrayUnderTest.distance(from: arrayUnderTest.startIndex,
//                                              to: j)
//      let jLeftDistance = leftChild.map {
//        arrayUnderTest.distance(from: arrayUnderTest.startIndex, to: $0)
//      }
//      let jRightDistance = rightChild.map {
//        arrayUnderTest.distance(from: arrayUnderTest.startIndex, to: $0)
//      }
//
//      let parentDistance = i.parent(x:j).map {
//        arrayUnderTest.distance(from: arrayUnderTest.startIndex, to: $0)
//      }

      print(value,
            leftValue,
            rightValue,
            parentValue)
      print()
    }

  }

  public func testSwap() {

    let c = "ABCDEFGHIJKLMNOPQRSTUVWXYZA"

    let leftIndex = c.index(c.startIndex, offsetBy: 7)
    let rightIndex = c.index(c.startIndex, offsetBy: 22)
    let arrayUnderTest = c[leftIndex...rightIndex]

    var heap = arrayUnderTest.heap()

    let swaps = [
    (0, 0),
    (3, 4),
    (5, 8),
    (8, 10),
    (11, 9),
    (1, 30),
    (29, 1)]

    // postcondition: true -> i.valueAt[left] == before[right], after[right] == before[left]
    //                false -> after == before
    for (left, right) in swaps {
      let beforeLeft = heap[left]
      let beforeRight = heap[right]

      let swapped = heap.swap(x: left, y: right)

      var after = ""
      for index in 0..<arrayUnderTest.count {
        after.append(heap[index] ?? "ø")
      }
      print(left, right, swapped)
      print(after)

      let afterLeft = heap[left]
      let afterRight = heap[right]

      if (swapped) {
        XCTAssert(beforeLeft == afterRight)
        XCTAssert(beforeRight == afterLeft)
      }
    }
  }

  func testMakeHeap() {
    let c = "kdrienspeksanewerdof"
    let arrayUnderTest = c

    var heap = Heap(arrayUnderTest)

    var before = String()
    for i in heap.indexes.indices {
      before.append(heap[i]!)
    }

    heap.makeHeap()

    var after = String()
    for i in heap.indexes.indices {
      after.append(heap[i]!)
    }

    print(before)
    print(after)

    XCTAssert(heap.isHeapThreeAll())

  }


  func testPop() {
    let c = "kdrienspeksanewerdof"
    let arrayUnderTest = c

    var heap = Heap(arrayUnderTest)

    heap.makeHeap()

    while (!heap.indexes.isEmpty) {
      print(heap.pop()!)
    }
  }
}
