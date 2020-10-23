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
  // intentionally does not depend on `Chain.index(_:offsetBy:)` in order to
  // avoid making assumptions about the code being tested
  func index<A, B>(atOffset offset: Int, in chain: Chain2<A, B>) -> Chain2<A, B>.Index {
    offset < chain.base1.count
      ? .init(first: chain.base1.index(chain.base1.startIndex, offsetBy: offset))
      : .init(second: chain.base2.index(chain.base2.startIndex, offsetBy: offset - chain.base1.count))
  }
  
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
  
  func testChainIndexOffsetBy() {
    let s1 = "abcde"
    let s2 = "VWXYZ"
    let c = chain(s1, s2)
    
    for (startOffset, endOffset) in product(0...c.count, 0...c.count) {
      let start = index(atOffset: startOffset, in: c)
      let end = index(atOffset: endOffset, in: c)
      let distance = endOffset - startOffset
      XCTAssertEqual(c.index(start, offsetBy: distance), end)
    }
  }
  
  func testChainIndexOffsetByLimitedBy() {
    let s1 = "abcd"
    let s2 = "XYZ"
    let c = chain(s1, s2)
    
    for (startOffset, limitOffset) in product(0...c.count, 0...c.count) {
      let start = index(atOffset: startOffset, in: c)
      let limit = index(atOffset: limitOffset, in: c)
      
      // verifies that the target index corresponding to each offset in `range`
      // can or cannot be reached from `start` using
      // `c.index(start, offsetBy: _, limitedBy: limit)`, depending on the
      // value of `beyondLimit`
      func checkTargetRange(_ range: ClosedRange<Int>, beyondLimit: Bool) {
        for targetOffset in range {
          let distance = targetOffset - startOffset
          
          XCTAssertEqual(
            c.index(start, offsetBy: distance, limitedBy: limit),
            beyondLimit ? nil : index(atOffset: targetOffset, in: c))
        }
      }
      
      // forward
      if limit >= start {
        // the limit has an effect
        checkTargetRange(startOffset...limitOffset, beyondLimit: false)
        checkTargetRange((limitOffset + 1)...(c.count + 1), beyondLimit: true)
      } else {
        // the limit has no effect
        checkTargetRange(startOffset...c.count, beyondLimit: false)
      }
      
      // backward
      if limit <= start {
        // the limit has an effect
        checkTargetRange(limitOffset...startOffset, beyondLimit: false)
        checkTargetRange(-1...(limitOffset - 1), beyondLimit: true)
      } else {
        // the limit has no effect
        checkTargetRange(0...startOffset, beyondLimit: false)
      }
    }
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
  
  func testChainDistanceFromTo() {
    let s1 = "abcde"
    let s2 = "VWXYZ"
    let c = chain(s1, s2)
    
    XCTAssertEqual(c.count, s1.count + s2.count)
    
    for (startOffset, endOffset) in product(0...c.count, 0...c.count) {
      let start = index(atOffset: startOffset, in: c)
      let end = index(atOffset: endOffset, in: c)
      let distance = endOffset - startOffset
      XCTAssertEqual(c.distance(from: start, to: end), distance)
    }
  }
  
  func testChainLazy() {
    XCTAssertLazy(chain([1, 2, 3].lazy, [4, 5, 6]))
  }
}
