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

final class GroupedTests: XCTestCase {
  private final class SampleError: Error {}

  // Based on https://github.com/apple/swift/blob/4d1d8a9de5ebc132a17aee9fc267461facf89bf8/validation-test/stdlib/Dictionary.swift#L1974-L1988

  func testGroupedBy() {
    let r = 0..<10

    let d1 = r.grouped(by: { $0 % 3 })
    XCTAssertEqual(3, d1.count)
    XCTAssertEqual(d1[0]!, [0, 3, 6, 9])
    XCTAssertEqual(d1[1]!, [1, 4, 7])
    XCTAssertEqual(d1[2]!, [2, 5, 8])

    let d2 = r.grouped(by: { $0 })
    XCTAssertEqual(10, d2.count)

    let d3 = (0..<0).grouped(by: { $0 })
    XCTAssertEqual(0, d3.count)
  }

  func testThrowingFromKeyFunction() {
    let input = ["Apple", "Banana", "Cherry"]
    let error = SampleError()

    XCTAssertThrowsError(
      try input.grouped(by: { (_: String) -> Character in throw error })
    ) { thrownError in
      XCTAssertIdentical(error, thrownError as? SampleError)
    }
  }
}
