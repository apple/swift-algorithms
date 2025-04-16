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

import Algorithms
import XCTest

final class EndsWithTests: XCTestCase {
  func testEndsWithCorrectSuffix() {
    let a = 8...10
    let b = 1...10

    XCTAssertTrue(b.ends(with: a))
  }

  func testDoesntEndWithWrongSuffix() {
    let a = 8...9
    let b = 1...10

    XCTAssertFalse(b.ends(with: a))
  }

  func testDoesntEndWithTooLongSuffix() {
    XCTAssertFalse((2...5).ends(with: (1...10)))
  }

  func testEndsWithEmpty() {
    let a = 8...10
    let empty: [Int] = []
    XCTAssertTrue(a.ends(with: empty))
  }

  func testEmptyEndsWithEmpty() {
    let empty: [Int] = []
    XCTAssertTrue(empty.ends(with: empty))
  }

  func testEmptyDoesNotEndWithNonempty() {
    XCTAssertFalse([].ends(with: 1...10))
  }
}

final class EndsWithNonEquatableTests: XCTestCase {
  func testEndsWithCorrectSuffix() {
    let a = nonEq(8...10)
    let b = nonEq(1...10)

    XCTAssertTrue(b.ends(with: a, by: areEquivalent))
  }

  func testDoesntEndWithWrongSuffix() {
    let a = nonEq(8...9)
    let b = nonEq(1...10)

    XCTAssertFalse(b.ends(with: a, by: areEquivalent))
  }

  func testDoesntEndWithTooLongSuffix() {
    XCTAssertFalse(nonEq(2...5).ends(with: nonEq(1...10), by: areEquivalent))
  }

  func testEndsWithEmpty() {
    let a = nonEq(8...10)
    let empty: [NotEquatable<Int>] = []
    XCTAssertTrue(a.ends(with: empty, by: areEquivalent))
  }

  func testEmptyEndsWithEmpty() {
    let empty: [NotEquatable<Int>] = []
    XCTAssertTrue(empty.ends(with: empty, by: areEquivalent))
  }

  func testEmptyDoesNotEndWithNonempty() {
    XCTAssertFalse([].ends(with: nonEq(1...10), by: areEquivalent))
  }

  private func nonEq(_ range: ClosedRange<Int>) -> [NotEquatable<Int>] {
    range.map(NotEquatable.init)
  }

  private func areEquivalent<T: Equatable>(
    lhs: NotEquatable<T>, rhs: NotEquatable<T>
  ) -> Bool {
    lhs.value == rhs.value
  }

  private struct NotEquatable<T> {
    let value: T
  }
}
