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
}
