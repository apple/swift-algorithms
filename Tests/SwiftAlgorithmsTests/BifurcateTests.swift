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

class BifurcateTests: XCTestCase {
  func testEmpty() {
    let input: [Int] = []
    
    let s0 = input.bifurcate({ _ in return true })
    
    XCTAssertTrue(s0.0.isEmpty)
    XCTAssertTrue(s0.1.isEmpty)
  }
  
  func testExample() throws {
    let cast = ["Vivien", "Marlon", "Kim", "Karl"]
    let (shortNames, longNames) = cast.bifurcate({ $0.count < 5 })
    XCTAssertEqual(shortNames, ["Kim", "Karl"])
    XCTAssertEqual(longNames, ["Vivien", "Marlon"])
  }
  
  func testWithPredicate() throws {
    let s0 = ["A", "B", "C", "D"].bifurcate({ $0 == $0.lowercased() })
    let s1 = ["a", "B", "C", "D"].bifurcate({ $0 == $0.lowercased() })
    let s2 = ["a", "B", "c", "D"].bifurcate({ $0 == $0.lowercased() })
    let s3 = ["a", "B", "c", "d"].bifurcate({ $0 == $0.lowercased() })
    
    XCTAssertEqual(s0.0, [])
    XCTAssertEqual(s0.1, ["A", "B", "C", "D"])
    
    XCTAssertEqual(s1.0, ["a"])
    XCTAssertEqual(s1.1, ["B", "C", "D"])
    
    XCTAssertEqual(s2.0, ["a", "c"])
    XCTAssertEqual(s2.1, ["B", "D"])
    
    XCTAssertEqual(s3.0, ["a", "c", "d"])
    XCTAssertEqual(s3.1, ["B"])
  }
  
  func testWithIndex() throws {
    let s0 = ["A", "B", "C", "D"].bifurcate(upTo: 0)
    let s1 = ["A", "B", "C", "D"].bifurcate(upTo: 1)
    let s2 = ["A", "B", "C", "D"].bifurcate(upTo: 2)
    let s3 = ["A", "B", "C", "D"].bifurcate(upTo: 3)
    let s4 = ["A", "B", "C", "D"].bifurcate(upTo: 4)
    
    XCTAssertEqual(s0.0, [])
    XCTAssertEqual(s0.1, ["A", "B", "C", "D"])
    
    XCTAssertEqual(s1.0, ["A"])
    XCTAssertEqual(s1.1, ["B", "C", "D"])
    
    XCTAssertEqual(s2.0, ["A", "B"])
    XCTAssertEqual(s2.1, ["C", "D"])
    
    XCTAssertEqual(s3.0, ["A", "B", "C"])
    XCTAssertEqual(s3.1, ["D"])
    
    XCTAssertEqual(s4.0, ["A", "B", "C", "D"])
    XCTAssertEqual(s4.1, [])
  }
}
