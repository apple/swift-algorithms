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
    XCTAssertEqual(10, b.count)
    
    let c: [Int] = []
    XCTAssertEqual(c.uniqued(), [])
  }
  
  func testUniqueOn() {
    let a = ["Albemarle", "Abeforth", "Astrology", "Brandywine", "Beatrice", "Axiom"]
    let b = a.uniqued(on: { $0.first })
    XCTAssertEqual(["Albemarle", "Brandywine"], b)
    
    let c: [Int] = []
    XCTAssertEqual(c.uniqued(on: { $0.bitWidth }), [])
  }
}
