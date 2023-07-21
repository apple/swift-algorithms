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

    XCTAssertEqualCollections([1, 2, 3, 4].lazy.reductions(0, +), [0, 1, 3, 6, 10])
    XCTAssertEqualCollections([1].lazy.reductions(0, +), [0, 1])
    XCTAssertEqualCollections(EmptyCollection<Int>().lazy.reductions(0, +), [0])

    XCTAssertEqual([1, 2, 3, 4].lazy.reductions(into: 0, +=), [0, 1, 3, 6, 10])

    XCTAssertEqual([1].lazy.reductions(into: 0, +=), [0, 1])

    XCTAssertEqual(EmptyCollection<Int>().lazy.reductions(into: 0, +=), [0])

    XCTAssertLazySequence((1...).prefix(1).lazy.reductions(0, +))
    XCTAssertLazySequence([1].lazy.reductions(0, +))
    XCTAssertLazyCollection([1].lazy.reductions(0, +))
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
    let validator = IndexValidator<ExclusiveReductionsSequence<Range<Int>, Int>>()
    validator.validate((0..<0).lazy.reductions(0, +), expectedCount: 1)
    validator.validate((0..<1).lazy.reductions(0, +), expectedCount: 2)
    validator.validate((0..<4).lazy.reductions(0, +), expectedCount: 5)
  }

  // MARK: - Inclusive Reductions

  func testInclusiveLazy() {
    XCTAssertEqualSequences((1...).prefix(4).lazy.reductions(+), [1, 3, 6, 10])
    XCTAssertEqualSequences((1...).prefix(1).lazy.reductions(+), [1])
    XCTAssertEqualSequences((1...).prefix(0).lazy.reductions(+), [])

    XCTAssertEqualCollections([1, 2, 3, 4].lazy.reductions(+), [1, 3, 6, 10])
    XCTAssertEqualCollections([1].lazy.reductions(+), [1])
    XCTAssertEqualCollections(EmptyCollection<Int>().lazy.reductions(+), [])

    XCTAssertLazySequence((1...).prefix(1).lazy.reductions(+))
    XCTAssertLazySequence([1].lazy.reductions(+))
    XCTAssertLazyCollection([1].lazy.reductions(+))
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
