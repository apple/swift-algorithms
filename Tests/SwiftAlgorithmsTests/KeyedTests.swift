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

final class KeyedTests: XCTestCase {
  private class SampleError: Error {}

  func testUniqueKeys() {
    let d = ["Apple", "Banana", "Cherry"].keyed(by: { $0.first! })
    XCTAssertEqual(d.count, 3)
    XCTAssertEqual(d["A"]!, "Apple")
    XCTAssertEqual(d["B"]!, "Banana")
    XCTAssertEqual(d["C"]!, "Cherry")
    XCTAssertNil(d["D"])
  }

  func testEmpty() {
    let d = EmptyCollection<String>().keyed(by: { $0.first! })
    XCTAssertEqual(d.count, 0)
  }

  func testNonUniqueKeys() throws {
    throw XCTSkip("""
    TODO: What's the XCTest equivalent to `expectCrashLater()`?

    https://github.com/apple/swift/blob/4d1d8a9de5ebc132a17aee9fc267461facf89bf8/validation-test/stdlib/Dictionary.swift#L1914
    """)
  }

  func testNonUniqueKeysWithMergeFunction() {
    let d = ["Apple", "Avocado", "Banana", "Cherry", "Coconut"].keyed(
      by: { $0.first! },
      uniquingKeysWith: { older, newer in "\(older)-\(newer)"}
    )

    XCTAssertEqual(d.count, 3)
    XCTAssertEqual(d["A"]!, "Apple-Avocado")
    XCTAssertEqual(d["B"]!, "Banana")
    XCTAssertEqual(d["C"]!, "Cherry-Coconut")
    XCTAssertNil(d["D"])
  }

  func testThrowingFromKeyFunction() {
    let input = ["Apple", "Banana", "Cherry"]
    let error = SampleError()

    XCTAssertThrowsError(
      try input.keyed(by: { (_: String) -> Character in throw error })
    ) { thrownError in
      XCTAssertIdentical(error, thrownError as? SampleError)
    }
  }

  func testThrowingFromCombineFunction() {
    let input = ["Apple", "Avocado", "Banana", "Cherry"]
    let error = SampleError()

    XCTAssertThrowsError(
      try input.keyed(by: { $0.first! }, uniquingKeysWith: { _, _ in throw error })
    ) { thrownError in
      XCTAssertIdentical(error, thrownError as? SampleError)
    }
  }
}
