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

import Algorithms
import XCTest

final class ReductionsTests: XCTestCase {
  struct TestError: Error {}

  // MARK: - Exclusive Reductions

  func testExclusiveLazy() {
    expectEqualSequences(
      (1...).prefix(4).lazy.reductions(0, +), [0, 1, 3, 6, 10])
    expectEqualSequences((1...).prefix(1).lazy.reductions(0, +), [0, 1])
    expectEqualSequences((1...).prefix(0).lazy.reductions(0, +), [0])

    expectEqualCollections(
      [1, 2, 3, 4].lazy.reductions(0, +), [0, 1, 3, 6, 10])
    expectEqualCollections([1].lazy.reductions(0, +), [0, 1])
    expectEqualCollections(EmptyCollection<Int>().lazy.reductions(0, +), [0])

    XCTAssertEqual(
      [1, 2, 3, 4].lazy.reductions(into: 0, +=), [0, 1, 3, 6, 10])

    XCTAssertEqual([1].lazy.reductions(into: 0, +=), [0, 1])

    XCTAssertEqual(EmptyCollection<Int>().lazy.reductions(into: 0, +=), [0])

    requireLazySequence((1...).prefix(1).lazy.reductions(0, +))
    requireLazySequence([1].lazy.reductions(0, +))
    requireLazyCollection([1].lazy.reductions(0, +))
  }

  func testExclusiveEager() {
    XCTAssertEqual([1, 2, 3, 4].reductions(0, +), [0, 1, 3, 6, 10])
    XCTAssertEqual([1].reductions(0, +), [0, 1])
    XCTAssertEqual(EmptyCollection<Int>().reductions(0, +), [0])

    XCTAssertEqual([1, 2, 3, 4].reductions(into: 0, +=), [0, 1, 3, 6, 10])

    XCTAssertEqual([1].reductions(into: 0, +=), [0, 1])

    XCTAssertEqual(EmptyCollection<Int>().reductions(into: 0, +=), [0])

    XCTAssertNoThrow(try [].reductions(0) { _, _ in throw TestError() })
    XCTAssertThrowsError(try [1].reductions(0) { _, _ in throw TestError() })
  }

  func testExclusiveIndexTraversals() {
    let validator = IndexValidator<
      ExclusiveReductionsSequence<Range<Int>, Int>
    >()
    validator.validate((0..<0).lazy.reductions(0, +), expectedCount: 1)
    validator.validate((0..<1).lazy.reductions(0, +), expectedCount: 2)
    validator.validate((0..<4).lazy.reductions(0, +), expectedCount: 5)
  }

  // MARK: - Inclusive Reductions

  func testInclusiveLazy() {
    expectEqualSequences((1...).prefix(4).lazy.reductions(+), [1, 3, 6, 10])
    expectEqualSequences((1...).prefix(1).lazy.reductions(+), [1])
    expectEqualSequences((1...).prefix(0).lazy.reductions(+), [])

    expectEqualCollections([1, 2, 3, 4].lazy.reductions(+), [1, 3, 6, 10])
    expectEqualCollections([1].lazy.reductions(+), [1])
    expectEqualCollections(EmptyCollection<Int>().lazy.reductions(+), [])

    requireLazySequence((1...).prefix(1).lazy.reductions(+))
    requireLazySequence([1].lazy.reductions(+))
    requireLazyCollection([1].lazy.reductions(+))
  }

  func testInclusiveEager() {
    XCTAssertEqual([1, 2, 3, 4].reductions(+), [1, 3, 6, 10])
    XCTAssertEqual([1].reductions(+), [1])
    XCTAssertEqual(EmptyCollection<Int>().reductions(+), [])

    XCTAssertNoThrow(try [].reductions { _, _ in throw TestError() })
    XCTAssertNoThrow(try [1].reductions { _, _ in throw TestError() })
    XCTAssertThrowsError(try [1, 1].reductions { _, _ in throw TestError() })
  }

  func testInclusiveIndexTraversals() {
    let validator = IndexValidator<InclusiveReductionsSequence<Range<Int>>>()
    validator.validate((0..<0).lazy.reductions(+), expectedCount: 0)
    validator.validate((0..<1).lazy.reductions(+), expectedCount: 1)
    validator.validate((0..<4).lazy.reductions(+), expectedCount: 4)
  }
}
