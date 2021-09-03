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
  
  func testProductDistanceFromTo() {
    let p = product([1, 2], "abc")
    XCTAssertEqual(p.distance(from: p.startIndex, to: p.endIndex), 6)
  }
  
  func testProductIndexTraversals() {
    let validator = IndexValidator<Product2Sequence<[Int], String>>(
      indicesIncludingEnd: { product in
        product.base1.indices.flatMap { i1 in
          product.base2.indices.map { i2 in
            .init(i1: i1, i2: i2)
          }
        } + [.init(i1: product.base1.endIndex, i2: product.base2.startIndex)]
      })
    
    validator.validate(product([1, 2, 3, 4], "abc"), expectedCount: 4 * 3)
    validator.validate(product([1, 2, 3, 4], ""), expectedCount: 4 * 0)
    validator.validate(product([], "abc"), expectedCount: 0 * 3)
    validator.validate(product([], ""), expectedCount: 0 * 0)
  }
}
