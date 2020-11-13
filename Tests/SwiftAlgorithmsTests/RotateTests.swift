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

final class RotateTests: XCTestCase {
  func testRotate() {
    for length in 0...15 {
      let a = Array(0..<length)
      var b = a
      for j in 0..<length {
        let i = b.rotate(toStartAt: j)
        XCTAssertEqualSequences(a[j...] + a[..<j], b)
        b.rotate(toStartAt: i)
        XCTAssertEqual(a, b)
      }
    }
  }
}
