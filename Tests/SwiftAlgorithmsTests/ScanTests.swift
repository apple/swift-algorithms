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

final class ScanTests: XCTestCase {
  func testScan() {
    XCTAssertEqualSequences((1...5).scan(0, +), [1, 3, 6, 10, 15])
    XCTAssertEqualSequences([3, 4, 2, 3, 1].scan(.max, min), [3, 3, 2, 2, 1])
  }
}
