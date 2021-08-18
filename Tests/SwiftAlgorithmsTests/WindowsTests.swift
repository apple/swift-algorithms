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

final class windowsTests: XCTestCase {
  
  func testWindowsOfString() {
    let s = "swift"
    let w = s.windows(ofCount: 2)
    var i = w.startIndex

    XCTAssertEqualSequences(w[i], "sw")
    w.formIndex(after: &i)
    XCTAssertEqualSequences(w[i], "wi")
    w.formIndex(after: &i)
    XCTAssertEqualSequences(w[i], "if")
    w.formIndex(after: &i)
    XCTAssertEqualSequences(w[i], "ft")

//    w.index(after: w.endIndex) // ← Precondition failed: windows index is out of range
//    w.index(before: w.startIndex) // ← Precondition failed: windows index is out of range
//    w.formIndex(after: &i); w[i] // ← Precondition failed: windows index is out of range
  }
  
  func testWindowsOfRange() {
    let a = 0...100
    
    XCTAssertTrue(a.windows(ofCount: 200).isEmpty)
    
    let w = a.windows(ofCount: 10)
    
    XCTAssertEqualSequences(w.first!, 0..<10)
    XCTAssertEqualSequences(w.last!, 91..<101)
  }
  
  func testWindowsOfInt() {
    let a = [ 0, 1, 0, 1 ].windows(ofCount: 2)
    
    XCTAssertEqual(a.count, 3)
    XCTAssertEqual(a.map { $0.reduce(0, +) }, [1, 1, 1])
    
    let a2 = [0, 1, 2, 3, 4, 5, 6].windows(ofCount: 3).map {
      $0.reduce(0, +)
    }.reduce(0, +)
    
    XCTAssertEqual(a2, 3 + 6 + 9 + 12 + 15)
  }
  
  func testWindowsCount() {
    let a = [0, 1, 2, 3, 4, 5]
    XCTAssertEqual(a.windows(ofCount: 3).count, 4)
    
    let a2 = [0, 1, 2, 3, 4]
    XCTAssertEqual(a2.windows(ofCount: 6).count, 0)
    
    let a3 = [Int]()
    XCTAssertEqual(a3.windows(ofCount: 2).count, 0)
  }
  
  func testWindowsSecondAndLast() {
    let a = [0, 1, 2, 3, 4, 5]
    let w = a.windows(ofCount: 4)
    let snd = w[w.index(after: w.startIndex)]
    XCTAssertEqualSequences(snd, [1, 2, 3, 4])
    
    let w2 = a.windows(ofCount: 3)
    XCTAssertEqualSequences(w2.last!, [3, 4, 5])
  }
  
  func testWindowsIndexAfterAndBefore() {
    let a = [0, 1, 2, 3, 4, 5].windows(ofCount: 2)
    var i = a.startIndex
    a.formIndex(after: &i)
    a.formIndex(after: &i)
    a.formIndex(before: &i)
    XCTAssertEqualSequences(a[i], [1, 2])
  }
  
  func testWindowsIndexTraversals() {
    validateIndexTraversals(
      "".windows(ofCount: 1),
      "a".windows(ofCount: 1),
      "ab".windows(ofCount: 1),
      "abc".windows(ofCount: 1),
      "".windows(ofCount: 3),
      "a".windows(ofCount: 3),
      "abc".windows(ofCount: 3),
      "abcdefgh".windows(ofCount: 3),
      indices: { windows in
        let endIndex = windows.base.endIndex
        let indices = windows.base.indices + [endIndex]
        return zip(indices, indices.dropFirst(windows.windowSize))
          .map { .init(lowerBound: $0, upperBound: $1) }
          + [.init(lowerBound: endIndex, upperBound: endIndex)]
      })
  }

  func testWindowsLazy() {
    XCTAssertLazyCollection([0, 1, 2, 3].lazy.windows(ofCount: 2))
  }
}
