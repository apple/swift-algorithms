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

@available(macOS 12.0, *)
final class ConcurrentTests: XCTestCase {
  func testParallelMap() async throws {
    let source = 1...10
    let expected = source.map { $0 }
    let actual = try await source.parallelMap { $0 }
    XCTAssertEqual(expected, actual)
  }
  
  func testParallelFirstIndex() async throws {
    let source = 0..<10
    let expected = 6
    let actual = try await source.parallelFirstIndex(parallelism: 2, where: { $0 > 5 })
    XCTAssertEqual(expected, actual)
  }
}
