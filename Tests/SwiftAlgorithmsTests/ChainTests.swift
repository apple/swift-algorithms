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

final class ChainTests: XCTestCase {
  func testChainSequences() {
    let run = chain((1...).prefix(10), 20...)
    XCTAssertEqualSequences(run.prefix(20), Array(1...10) + (20..<30))
  }
  
  func testChainForwardCollection() {
    let s1 = Set(0...10)
    let s2 = Set(20...30)
    let c = chain(s1, s2)
    XCTAssertEqualSequences(c, Array(s1) + Array(s2))
  }
  
  func testChainBidirectionalCollection() {
    let s1 = "ABCDEFGHIJ"
    let s2 = "klmnopqrstuv"
    let c = chain(s1, s2)
    
    XCTAssertEqualSequences(c, "ABCDEFGHIJklmnopqrstuv")
    XCTAssertEqualSequences(c.reversed(), "ABCDEFGHIJklmnopqrstuv".reversed())
    XCTAssertEqualSequences(chain(s1.reversed(), s2), "JIHGFEDCBAklmnopqrstuv")
  }
  
  func testChainIndexTraversals() {
    let validator = IndexValidator<Chain2Sequence<String, String>>(
      indicesIncludingEnd: { chain in
        chain.base1.indices.map { .init(first: $0) }
          + chain.base2.indices.map { .init(second: $0) }
          + [.init(second: chain.base2.endIndex)]
      })
    
    validator.validate(chain("abcd", "XYZ"), expectedCount: 4 + 3)
    validator.validate(chain("abcd", ""), expectedCount: 4 + 0)
    validator.validate(chain("", "XYZ"), expectedCount: 0 + 3)
    validator.validate(chain("", ""), expectedCount: 0 + 0)
  }
  
  func testChainIndexOffsetAcrossBoundary() {
    let c = chain("abc", "XYZ")
    
    do {
      let i = c.index(c.startIndex, offsetBy: 3, limitedBy: c.startIndex)
      XCTAssertNil(i)
    }
    
    do {
      let i = c.index(c.startIndex, offsetBy: 4)
      let j = c.index(i, offsetBy: -2)
      XCTAssertEqual(c[j], "c")
    }
    
    do {
      let i = c.index(c.startIndex, offsetBy: 3)
      let j = c.index(i, offsetBy: -1, limitedBy: i)
      XCTAssertNil(j)
    }
  }
}
