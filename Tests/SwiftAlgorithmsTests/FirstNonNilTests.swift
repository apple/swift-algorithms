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

final class FirstNonNilTests: XCTestCase {
  func testFirstNonNil() {
    XCTAssertNil([].firstNonNil { $0 })
    XCTAssertNil(["A", "B", "C"].firstNonNil { Int($0) })
    XCTAssertNil(["A", "B", "C"].firstNonNil { _ in nil })
    XCTAssertEqual(["A", "B", "10"].firstNonNil { Int($0) }, 10)
    XCTAssertEqual(["20", "B", "10"].firstNonNil { Int($0) }, 20)
  }
}
