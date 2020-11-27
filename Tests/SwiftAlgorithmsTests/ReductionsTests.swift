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

  struct TestError: Error {}

  // MARK: - Exclusive Reductions

  func testExclusiveLazy() {
    XCTAssertEqualSequences((1...).prefix(4).lazy.reductions(0, +), [0, 1, 3, 6, 10])
    XCTAssertEqualSequences((1...).prefix(1).lazy.reductions(0, +), [0, 1])
    XCTAssertEqualSequences((1...).prefix(0).lazy.reductions(0, +), [0])

    XCTAssertLazy([1].lazy.reductions(0, +))
  }

  func testExclusiveEager() {
    XCTAssertEqual([1, 2, 3, 4].reductions(0, +), [0, 1, 3, 6, 10])
    XCTAssertEqual([1].reductions(0, +), [0, 1])
    XCTAssertEqual(EmptyCollection<Int>().reductions(0, +), [0])

    XCTAssertNoThrow(try [].reductions(0) { _, _ in throw TestError() })
    XCTAssertThrowsError(try [1].reductions(0) { _, _ in throw TestError() })
  }

  // MARK: - Inclusive Reductions

  func testInclusiveLazy() {
    XCTAssertEqualSequences((1...).prefix(4).lazy.reductions(+), [1, 3, 6, 10])
    XCTAssertEqualSequences((1...).prefix(1).lazy.reductions(+), [1])
    XCTAssertEqualSequences((1...).prefix(0).lazy.reductions(+), [])

    XCTAssertEqualCollections([1, 2, 3, 4].lazy.reductions(+), [1, 3, 6, 10])
    XCTAssertEqualCollections([1].lazy.reductions(+), [1])
    XCTAssertEqualCollections(EmptyCollection<Int>().lazy.reductions(+), [])

    XCTAssertLazy([1].lazy.reductions(+))
  }

  func testInclusiveEager() {
    XCTAssertEqual([1, 2, 3, 4].reductions(+), [1, 3, 6, 10])
    XCTAssertEqual([1].reductions(+), [1])
    XCTAssertEqual(EmptyCollection<Int>().reductions(+), [])

    XCTAssertNoThrow(try [].reductions { _, _ in throw TestError() })
    XCTAssertNoThrow(try [1].reductions { _, _ in throw TestError() })
    XCTAssertThrowsError(try [1, 1].reductions { _, _ in throw TestError() })
  }
}
