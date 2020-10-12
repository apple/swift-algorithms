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

final class WindowsTests: XCTestCase {
  
  func testWindowsOfString() {
    let s = "swift"
    let w = s.windows(size: 2)
    var i = w.startIndex
    
    XCTAssertEqualSequences(w[i], "sw")
    w.formIndex(after: &i)
    XCTAssertEqualSequences(w[i], "wi")
    w.formIndex(after: &i)
    XCTAssertEqualSequences(w[i], "if")
    w.formIndex(after: &i)
    XCTAssertEqualSequences(w[i], "ft")
    w.formIndex(after: &i)
    XCTAssertTrue(w[i].isEmpty)
  }
  
  func testWindowsOfRange() {
    let a = 0...100
    
    XCTAssertTrue(a.windows(size: 200).isEmpty)
    
    let w = a.windows(size: 10)
    
    XCTAssertEqualSequences(w.first!, 0..<10)
    XCTAssertEqualSequences(w.last!, 91..<101)
  }
  
  func testWindowsOfInt() {
    
    let a = [ 0, 1, 0, 1 ].windows(size: 2)
    
    XCTAssertEqual(a.count, 3)
    XCTAssertEqual(a.map { $0.reduce(0, +) }, [1, 1, 1])
    
    let a2 = [0, 1, 2, 3, 4, 5, 6].windows(size: 3).map {
      $0.reduce(0, +)
    }.reduce(0, +)
    
    XCTAssertEqual(a2, 3 + 6 + 9 + 12 + 15)
  }
  
  func testWindowsCount() {
    let a = [0, 1, 2, 3, 4, 5]
    XCTAssertEqual(a.windows(size: 3).count, 4)
    
    let a2 = [0, 1, 2, 3, 4]
    XCTAssertEqual(a2.windows(size: 6).count, 0)
    
    let a3 = [Int]()
    XCTAssertEqual(a3.windows(size: 2).count, 0)
  }
  
  func testWindowsSecondAndLast() {
    let a = [0, 1, 2, 3, 4, 5]
    let w = a.windows(size: 4)
    let snd = w[w.index(after: w.startIndex)]
    XCTAssertEqualSequences(snd, [1, 2, 3, 4])
    
    let w2 = a.windows(size: 3)
    XCTAssertEqualSequences(w2.last!, [3, 4, 5])
  }
  
  func testWindowsIndexAfterAndBefore() {
    let a = [0, 1, 2, 3, 4, 5].windows(size: 2)
    var i = a.startIndex
    a.formIndex(after: &i)
    a.formIndex(after: &i)
    a.formIndex(before: &i)
    XCTAssertEqualSequences(a[i], [1, 2])
  }
  
}
