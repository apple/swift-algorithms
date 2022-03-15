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

final class IndexedTests: XCTestCase {
  func testIndexed() {
    let s = "ABCDEFGHIJKLMNOP"
    let si = s.indexed()

    XCTAssertEqual(s.startIndex, si.first!.index)
    XCTAssertEqual("A", si.first!.element)
    XCTAssertEqual(s.index(before: s.endIndex), si.last!.index)
    XCTAssertEqual("P", si.last!.element)

    let indexOfG = si.first(where: { $0.element == "G" })!.index
    XCTAssertEqual("G", s[indexOfG])
    let indexOfI = si.last(where: { $0.element == "I" })!.index
    XCTAssertEqual("I", s[indexOfI])
  }
  
  func testIndexedLazy() {
    XCTAssertLazyCollection("ABCD".lazy.indexed())
  }
}
