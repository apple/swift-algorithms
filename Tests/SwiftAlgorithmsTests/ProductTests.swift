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

final class ProductTests: XCTestCase {
  func testProduct() {
    XCTAssertEqualSequences(
      [(1, "A" as Character), (1, "B"), (2, "A"), (2, "B")],
      product(1...2, "AB"),
      by: ==)

    XCTAssertEqualSequences(product(1...10, ""), [], by: ==)
    XCTAssertEqualSequences(product("", 1...10), [], by: ==)
  }
  
  func testProductReversed() {
    XCTAssertEqualSequences(
      [(2, "B" as Character), (2, "A"), (1, "B"), (1, "A")],
      product(1...2, "AB").reversed(),
      by: ==)

    XCTAssertEqualSequences(product(1...10, "").reversed(), [], by: ==)
    XCTAssertEqualSequences(product("", 1...10).reversed(), [], by: ==)
  }
}
