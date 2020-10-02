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

final class ChainTests: XCTestCase {
  func testChainSequences() {
    let run = (1...).prefix(10).chained(with: 20...)
    XCTAssertEqualSequences(run.prefix(20), Array(1...10) + (20..<30))
  }
  
  func testChainForwardCollection() {
    let s1 = Set(0...10)
    let s2 = Set(20...30)
    let c = s1.chained(with: s2)
    XCTAssertEqualSequences(c, Array(s1) + Array(s2))
  }
  
  func testChainBidirectionalCollection() {
    let s1 = "ABCDEFGHIJ"
    let s2 = "klmnopqrstuv"
    let c = s1.chained(with: s2)
    
    XCTAssertEqualSequences(c, "ABCDEFGHIJklmnopqrstuv")
    XCTAssertEqualSequences(c.reversed(), "ABCDEFGHIJklmnopqrstuv".reversed())
    XCTAssertEqualSequences(s1.reversed().chained(with: s2), "JIHGFEDCBAklmnopqrstuv")
  }
  
  // TODO: Add tests that check distance and index(offsetBy:)
}
