//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift Algorithms open source project
//
// Copyright (c) 2021 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

import XCTest
import Algorithms

final class SuffixTests: XCTestCase {
  func testSuffix() {
    let a = 0...10
    XCTAssertEqualSequences(a.suffix(while: { $0 > 5 }), (6...10))
    XCTAssertEqualSequences(a.suffix(while: { $0 > 10 }), [])
    XCTAssertEqualSequences(a.suffix(while: { $0 > 9 }), [10])
    XCTAssertEqualSequences(a.suffix(while: { $0 > -1 }), (0...10))
    
    let empty: [Int] = []
    XCTAssertEqualSequences(empty.suffix(while: { $0 > 10 }), [])
  }
  
  func testEndOfPrefix() {
    let array = Array(0..<10)
    XCTAssertEqual(array.endOfPrefix(while: { $0 < 3 }), 3)
    XCTAssertEqual(array.endOfPrefix(while: { _ in false }), array.startIndex)
    XCTAssertEqual(array.endOfPrefix(while: { _ in true }), array.endIndex)
    
    let empty = [Int]()
    XCTAssertEqual(empty.endOfPrefix(while: { $0 < 3 }), 0)
    XCTAssertEqual(empty.endOfPrefix(while: { _ in false }), empty.startIndex)
    XCTAssertEqual(empty.endOfPrefix(while: { _ in true }), empty.endIndex)
  }
  
  func testStartOfSuffix() {
    let array = Array(0..<10)
    XCTAssertEqual(array.startOfSuffix(while: { $0 >= 3 }), 3)
    XCTAssertEqual(array.startOfSuffix(while: { _ in false }), array.endIndex)
    XCTAssertEqual(array.startOfSuffix(while: { _ in true }), array.startIndex)
    
    let empty = [Int]()
    XCTAssertEqual(empty.startOfSuffix(while: { $0 < 3 }), 0)
    XCTAssertEqual(empty.startOfSuffix(while: { _ in false }), empty.endIndex)
    XCTAssertEqual(empty.startOfSuffix(while: { _ in true }), empty.startIndex)
  }
}
