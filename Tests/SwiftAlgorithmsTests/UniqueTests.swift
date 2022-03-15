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

final class UniqueTests: XCTestCase {
  func testUnique() {
    let a = repeatElement(1...10, count: 15).joined().shuffled()
    let b = a.uniqued()
    XCTAssertEqual(b.sorted(), Set(a).sorted())
    XCTAssertEqual(10, Array(b).count)
    
    let c: [Int] = []
    XCTAssertEqualSequences(c.uniqued(), [])
    
    let d = Array(repeating: 1, count: 10)
    XCTAssertEqualSequences(d.uniqued(), [1])
  }
  
  func testUniqueOn() {
    let a = ["Albemarle", "Abeforth", "Astrology", "Brandywine", "Beatrice", "Axiom"]
    let b = a.uniqued(on: { $0.first })
    XCTAssertEqual(["Albemarle", "Brandywine"], b)
    
    let c: [Int] = []
    XCTAssertEqual(c.uniqued(on: { $0.bitWidth }), [])
    
    let d = Array(repeating: "Andromeda", count: 10)
    XCTAssertEqualSequences(d.uniqued(on: { $0.first }), ["Andromeda"])
  }
  
  func testLazyUniqueOn() {
    let a = ["Albemarle", "Abeforth", "Astrology", "Brandywine", "Beatrice", "Axiom"]
    let b = a.lazy.uniqued(on: { $0.first })
    XCTAssertEqualSequences(b, ["Albemarle", "Brandywine"])
    XCTAssertLazySequence(b)

    let c: [Int] = []
    XCTAssertEqualSequences(c.lazy.uniqued(on: { $0.bitWidth }), [])
    
    let d = Array(repeating: "Andromeda", count: 10)
    XCTAssertEqualSequences(d.lazy.uniqued(on: { $0.first }), ["Andromeda"])
  }
}
