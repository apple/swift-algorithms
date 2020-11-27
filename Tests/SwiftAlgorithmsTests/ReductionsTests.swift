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

final class ReductionsTests: XCTestCase {

  func testLazySequenceInitial() {
    XCTAssertEqualSequences(
      (1...).prefix(5).lazy.reductions(0, +),
      [0, 1, 3, 6, 10, 15])

    XCTAssertEqualSequences(
      (1...).prefix(1).lazy.reductions(0, +),
      [0, 1])

    XCTAssertEqualSequences(
      (1...).prefix(0).lazy.reductions(0, +),
      [0])
  }

  func testLazyCollectionInitial() {
    XCTAssertEqualSequences(
      [1, 2, 3, 4, 5].lazy.reductions(0, +),
      [0, 1, 3, 6, 10, 15])

    XCTAssertEqualSequences(
      [1].lazy.reductions(0, +),
      [0, 1])

    XCTAssertEqualSequences(
      EmptyCollection<Int>().lazy.reductions(0, +),
      [0])
  }

  func testEagerInitial() {
    XCTAssertEqual(
      [1, 2, 3, 4, 5].reductions(0, +),
      [0, 1, 3, 6, 10, 15])

    XCTAssertEqual(
      CollectionOfOne(1).reductions(0, +),
      [0, 1])

    XCTAssertEqualSequences(
      EmptyCollection<Int>().reductions(0, +),
      [0])
  }

  func testEagerNoInitial() {
    XCTAssertEqualSequences(
      [1, 2, 3, 4, 5].reductions(+),
      [1, 3, 6, 10, 15])

    XCTAssertEqualSequences(
      CollectionOfOne(1).reductions(+),
      [1])

    XCTAssertEqualSequences(
      EmptyCollection<Int>().reductions(+),
      [])
  }

  func testEagerThrows() {
    struct E: Error {}

    XCTAssertNoThrow(try [].reductions(0) { _, _ in throw E() })
    XCTAssertThrowsError(try [1].reductions(0) { _, _ in throw E() })

    XCTAssertNoThrow(try [].reductions { _, _ in throw E() })
    XCTAssertNoThrow(try [1].reductions { _, _ in throw E() })
    XCTAssertThrowsError(try [1, 1].reductions { _, _ in throw E() })
  }
}
