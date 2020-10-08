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

final class IsSortedTests: XCTestCase {
    
  func testIsSorted() {
    let a = 0...10
    let b = (0...10).reversed()
    let c = Array(repeating: 42, count: 10)
    XCTAssertTrue(a.isSorted())
    XCTAssertTrue(b.isSorted(by: >))
    XCTAssertTrue(c.allEqual())
  }
}
