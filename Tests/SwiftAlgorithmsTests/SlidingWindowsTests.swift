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

final class SlidingWindowsTests: XCTestCase {
  
  func testWindowsOfString() {

    let s = "swift"
    let w = s.slidingWindows(ofCount: 2)
    var i = w.startIndex

    XCTAssertEqualSequences(w[i], "sw")
    w.formIndex(after: &i)
    XCTAssertEqualSequences(w[i], "wi")
    w.formIndex(after: &i)
    XCTAssertEqualSequences(w[i], "if")
    w.formIndex(after: &i)
    XCTAssertEqualSequences(w[i], "ft")

//    w.index(after: w.endIndex) // ← Precondition failed: SlidingWindows index is out of range
//    w.index(before: w.startIndex) // ← Precondition failed: SlidingWindows index is out of range
//    w.formIndex(after: &i); w[i] // ← Precondition failed: SlidingWindows index is out of range
  }
  
  func testWindowsOfRange() {
    let a = 0...100
    
    XCTAssertTrue(a.slidingWindows(ofCount: 200).isEmpty)
    
    let w = a.slidingWindows(ofCount: 10)
    
    XCTAssertEqualSequences(w.first!, 0..<10)
    XCTAssertEqualSequences(w.last!, 91..<101)
  }
  
  func testWindowsOfInt() {
    
    let a = [ 0, 1, 0, 1 ].slidingWindows(ofCount: 2)
    
    XCTAssertEqual(a.count, 3)
    XCTAssertEqual(a.map { $0.reduce(0, +) }, [1, 1, 1])
    
    let a2 = [0, 1, 2, 3, 4, 5, 6].slidingWindows(ofCount: 3).map {
      $0.reduce(0, +)
    }.reduce(0, +)
    
    XCTAssertEqual(a2, 3 + 6 + 9 + 12 + 15)
  }
  
  func testWindowsCount() {
    let a = [0, 1, 2, 3, 4, 5]
    XCTAssertEqual(a.slidingWindows(ofCount: 3).count, 4)
    
    let a2 = [0, 1, 2, 3, 4]
    XCTAssertEqual(a2.slidingWindows(ofCount: 6).count, 0)
    
    let a3 = [Int]()
    XCTAssertEqual(a3.slidingWindows(ofCount: 2).count, 0)
  }
  
  func testWindowsSecondAndLast() {
    let a = [0, 1, 2, 3, 4, 5]
    let w = a.slidingWindows(ofCount: 4)
    let snd = w[w.index(after: w.startIndex)]
    XCTAssertEqualSequences(snd, [1, 2, 3, 4])
    
    let w2 = a.slidingWindows(ofCount: 3)
    XCTAssertEqualSequences(w2.last!, [3, 4, 5])
  }
  
  func testWindowsIndexAfterAndBefore() {
    let a = [0, 1, 2, 3, 4, 5].slidingWindows(ofCount: 2)
    var i = a.startIndex
    a.formIndex(after: &i)
    a.formIndex(after: &i)
    a.formIndex(before: &i)
    XCTAssertEqualSequences(a[i], [1, 2])
  }
  
  func testWindowsIndexTraversals() {
    validateIndexTraversals(
      "".slidingWindows(ofCount: 1),
      "a".slidingWindows(ofCount: 1),
      "ab".slidingWindows(ofCount: 1),
      "abc".slidingWindows(ofCount: 1),
      "".slidingWindows(ofCount: 3),
      "a".slidingWindows(ofCount: 3),
      "abc".slidingWindows(ofCount: 3),
      "abcdefgh".slidingWindows(ofCount: 3),
      indices: { windows in
        let endIndex = windows.base.endIndex
        let indices = windows.base.indices + [endIndex]
        return zip(indices, indices.dropFirst(windows.size))
          .map { .init(lowerBound: $0, upperBound: $1) }
          + [.init(lowerBound: endIndex, upperBound: endIndex)]
      })
  }
}
