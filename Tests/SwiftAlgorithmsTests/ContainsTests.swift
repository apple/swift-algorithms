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

final class ContainsTests: XCTestCase {
  func test() {
    let array = [0, 1, 2, 1, 2, 1, 2, 3]
    
    XCTAssertEqual(array.firstRange(of: [0, 1, 2]),       0..<3)
    XCTAssertEqual(array.firstRange(of: [1, 2]),          1..<3)
    XCTAssertEqual(array.firstRange(of: [1, 2, 3]),       5..<8)
    XCTAssertEqual(array.firstRange(of: [1, 2, 1, 2, 3]), 3..<8)
    XCTAssertNil(array.firstRange(of: [0, 1, 2, 3]))
    
    XCTAssertEqual(array.lastRange(of: [1, 2]),          5..<7)
    XCTAssertEqual(array.lastRange(of: [0, 1, 2]),       0..<3)
    XCTAssertEqual(array.lastRange(of: [0, 1, 2, 1, 2]), 0..<5)
    XCTAssertNil(array.lastRange(of: [0, 1, 2, 3]))
  }
  
  func testEmpty() {
    let array = [0, 1, 2, 1, 2, 1, 2, 3]
    let empty: [Int] = []
    
    XCTAssertEqual(array.firstRange(of: empty), 0..<0)
    XCTAssertEqual(empty.firstRange(of: empty), 0..<0)
    XCTAssertNil(empty.firstRange(of: array))
    
    XCTAssertEqual(array.lastRange(of: empty), 8..<8)
    XCTAssertEqual(empty.lastRange(of: empty), 0..<0)
    XCTAssertNil(empty.lastRange(of: array))
  }
}
