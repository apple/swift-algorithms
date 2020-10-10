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

final class AdjacentPairsTests: XCTestCase {
    func testAdjacentPairs() {
      let list = [10, 20, 30, 40, 50]
      let pairs = list.adjacentPairs
      let expectedResult = [(10, 20), (20, 30), (30, 40), (40, 50)]
      
      XCTAssertEqual(pairs.first?.leading, 10)
      XCTAssertEqual(pairs.last?.trailing, 50)
      XCTAssertEqual(pairs.count, expectedResult.count)
    }
    
    func testLazyAdjacentPairs() {
      let list = "ABCDEF".unicodeScalars.lazy
      let lazyPairs = list.lazy.adjacentPairs
      let expectedResult = [("A", "B"), ("B", "C"), ("C", "D"), ("D", "E"), ("E", "F")]
      
      XCTAssertEqual(lazyPairs.first?.trailing, "B")
      XCTAssertEqual(lazyPairs.last?.leading, "E")
      XCTAssertEqual(lazyPairs.count, expectedResult.count)
    }
    
}
