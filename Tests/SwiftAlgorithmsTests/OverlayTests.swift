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
@testable import Algorithms

final class ReplaceSubrangeTests: XCTestCase {

  func testAppend() {

    func _performAppendTest<Base, Overlay>(
      base: Base, appending newElements: Overlay,
      _ checkResult: (OverlayCollection<Base, Overlay>) -> Void
    ) {
      checkResult(base.overlay.appending(contentsOf: newElements))

      checkResult(base.overlay.inserting(contentsOf: newElements, at: base.endIndex))

      checkResult(base.overlay.replacingSubrange(base.endIndex..<base.endIndex, with: newElements))
    }

    // Base: non-empty
    // Appending: non-empty
    _performAppendTest(base: 0..<5, appending: [8, 9, 10]) { result in
      XCTAssertEqualCollections(result, [0, 1, 2, 3, 4, 8, 9, 10])
      IndexValidator().validate(result, expectedCount: 8)
    }

    // Base: non-empty
    // Appending: empty
    _performAppendTest(base: 0..<5, appending: EmptyCollection()) { result in
      XCTAssertEqualCollections(result, [0, 1, 2, 3, 4])
      IndexValidator().validate(result, expectedCount: 5)
    }

    // Base: empty
    // Appending: non-empty
    _performAppendTest(base: EmptyCollection(), appending: 5..<10) { result in
      XCTAssertEqualCollections(result, [5, 6, 7, 8, 9])
      IndexValidator().validate(result, expectedCount: 5)
    }

    // Base: empty
    // Appending: empty
    _performAppendTest(base: EmptyCollection<Int>(), appending: EmptyCollection()) { result in
      XCTAssertEqualCollections(result, [])
      IndexValidator().validate(result, expectedCount: 0)
    }
  }

  func testAppendSingle() {

    // Base: empty
    do {
      let base = EmptyCollection<Int>()
      let result = base.overlay.appending(99)
      XCTAssertEqualCollections(result, [99])
      IndexValidator().validate(result, expectedCount: 1)
    }

    // Base: non-empty
    do {
      let base = 2..<8
      let result = base.overlay.appending(99)
      XCTAssertEqualCollections(result, [2, 3, 4, 5, 6, 7, 99])
      IndexValidator().validate(result, expectedCount: 7)
    }
  }

  func testPrepend() {

    func _performPrependTest<Base, Overlay>(
      base: Base, prepending newElements: Overlay,
      _ checkResult: (OverlayCollection<Base, Overlay>) -> Void
    ) {
      checkResult(base.overlay.inserting(contentsOf: newElements, at: base.startIndex))

      checkResult(base.overlay.replacingSubrange(base.startIndex..<base.startIndex, with: newElements))
    }

    // Base: non-empty
    // Prepending: non-empty
    _performPrependTest(base: 0..<5, prepending: [8, 9, 10]) { result in
      XCTAssertEqualCollections(result, [8, 9, 10, 0, 1, 2, 3, 4])
      IndexValidator().validate(result, expectedCount: 8)
    }

    // Base: non-empty
    // Prepending: empty
    _performPrependTest(base: 0..<5, prepending: EmptyCollection()) { result in
      XCTAssertEqualCollections(result, [0, 1, 2, 3, 4])
      IndexValidator().validate(result, expectedCount: 5)
    }

    // Base: empty
    // Prepending: non-empty
    _performPrependTest(base: EmptyCollection(), prepending: 5..<10) { result in
      XCTAssertEqualCollections(result, [5, 6, 7, 8, 9])
      IndexValidator().validate(result, expectedCount: 5)
    }

    // Base: empty
    // Prepending: empty
    _performPrependTest(base: EmptyCollection<Int>(), prepending: EmptyCollection()) { result in
      XCTAssertEqualCollections(result, [])
      IndexValidator().validate(result, expectedCount: 0)
    }
  }

  func testPrependSingle() {

    // Base: empty
    do {
      let base = EmptyCollection<Int>()
      let result = base.overlay.inserting(99, at: base.startIndex)
      XCTAssertEqualCollections(result, [99])
      IndexValidator().validate(result, expectedCount: 1)
    }

    // Base: non-empty
    do {
      let base = 2..<8
      let result = base.overlay.inserting(99, at: base.startIndex)
      XCTAssertEqualCollections(result, [99, 2, 3, 4, 5, 6, 7])
      IndexValidator().validate(result, expectedCount: 7)
    }
  }

  func testInsert() {

    // Inserting: non-empty
    do {
      let base = 0..<10
      let i = base.index(base.startIndex, offsetBy: 5)
      let result = base.overlay.inserting(contentsOf: 20..<25, at: i)
      XCTAssertEqualCollections(result, [0, 1, 2, 3, 4, 20, 21, 22, 23, 24, 5, 6, 7, 8, 9])
      IndexValidator().validate(result, expectedCount: 15)
    }

    // Inserting: empty
    do {
      let base = 0..<10
      let i = base.index(base.startIndex, offsetBy: 5)
      let result = base.overlay.inserting(contentsOf: EmptyCollection(), at: i)
      XCTAssertEqualCollections(result, [0, 1, 2, 3, 4, 5, 6, 7, 8, 9])
      IndexValidator().validate(result, expectedCount: 10)
    }
  }

  func testInsertSingle() {

    let base = 2..<8
    let result = base.overlay.inserting(99, at: base.index(base.startIndex, offsetBy: 3))
    XCTAssertEqualCollections(result, [2, 3, 4, 99, 5, 6, 7])
    IndexValidator().validate(result, expectedCount: 7)
  }

  func testReplace() {

    // Location: anchored to start
    // Replacement: non-empty
    do {
      let base = "hello, world!"
      let i = base.index(base.startIndex, offsetBy: 3)
      let result = base.overlay.replacingSubrange(base.startIndex..<i, with: "goodbye".reversed())
      XCTAssertEqualCollections(result, "eybdooglo, world!")
      IndexValidator().validate(result, expectedCount: 17)
    }

    // Location: anchored to start
    // Replacement: empty
    do {
      let base = "hello, world!"
      let i = base.index(base.startIndex, offsetBy: 3)
      let result = base.overlay.replacingSubrange(base.startIndex..<i, with: EmptyCollection())
      XCTAssertEqualCollections(result, "lo, world!")
      IndexValidator().validate(result, expectedCount: 10)
    }

    // Location: middle
    // Replacement: non-empty
    do {
      let base = "hello, world!"
      let start = base.index(base.startIndex, offsetBy: 3)
      let end = base.index(start, offsetBy: 4)
      let result = base.overlay.replacingSubrange(start..<end, with: "goodbye".reversed())
      XCTAssertEqualCollections(result, "heleybdoogworld!")
      IndexValidator().validate(result, expectedCount: 16)
    }

    // Location: middle
    // Replacement: empty
    do {
      let base = "hello, world!"
      let start = base.index(base.startIndex, offsetBy: 3)
      let end = base.index(start, offsetBy: 4)
      let result = base.overlay.replacingSubrange(start..<end, with: EmptyCollection())
      XCTAssertEqualCollections(result, "helworld!")
      IndexValidator().validate(result, expectedCount: 9)
    }

    // Location: anchored to end
    // Replacement: non-empty
    do {
      let base = "hello, world!"
      let start = base.index(base.endIndex, offsetBy: -4)
      let result = base.overlay.replacingSubrange(start..<base.endIndex, with: "goodbye".reversed())
      XCTAssertEqualCollections(result, "hello, woeybdoog")
      IndexValidator().validate(result, expectedCount: 16)
    }

    // Location: anchored to end
    // Replacement: empty
    do {
      let base = "hello, world!"
      let start = base.index(base.endIndex, offsetBy: -4)
      let result = base.overlay.replacingSubrange(start..<base.endIndex, with: EmptyCollection())
      XCTAssertEqualCollections(result, "hello, wo")
      IndexValidator().validate(result, expectedCount: 9)
    }

    // Location: entire collection
    // Replacement: non-empty
    do {
      let base = "hello, world!"
      let result = base.overlay.replacingSubrange(base.startIndex..<base.endIndex, with: Array("blah blah blah"))
      XCTAssertEqualCollections(result, "blah blah blah")
      IndexValidator().validate(result, expectedCount: 14)
    }

    // Location: entire collection
    // Replacement: empty
    do {
      let base = "hello, world!"
      let result = base.overlay.replacingSubrange(base.startIndex..<base.endIndex, with: EmptyCollection())
      XCTAssertEqualCollections(result, "")
      IndexValidator().validate(result, expectedCount: 0)
    }
  }

  func testRemove() {

    // Location: anchored to start
    do {
      let base = "hello, world!"
      let i = base.index(base.startIndex, offsetBy: 3)
      let result = base.overlay.removingSubrange(base.startIndex..<i)
      XCTAssertEqualCollections(result, "lo, world!")
      IndexValidator().validate(result, expectedCount: 10)
    }

    // Location: middle
    do {
      let base = "hello, world!"
      let start = base.index(base.startIndex, offsetBy: 3)
      let end = base.index(start, offsetBy: 4)
      let result = base.overlay.removingSubrange(start..<end)
      XCTAssertEqualCollections(result, "helworld!")
      IndexValidator().validate(result, expectedCount: 9)
    }

    // Location: anchored to end
    do {
      let base = "hello, world!"
      let start = base.index(base.endIndex, offsetBy: -4)
      let result = base.overlay.removingSubrange(start..<base.endIndex)
      XCTAssertEqualCollections(result, "hello, wo")
      IndexValidator().validate(result, expectedCount: 9)
    }

    // Location: entire collection
    do {
      let base = "hello, world!"
      let result = base.overlay.removingSubrange(base.startIndex..<base.endIndex)
      XCTAssertEqualCollections(result, "")
      IndexValidator().validate(result, expectedCount: 0)
    }
  }

  func testRemoveSingle() {

    // Location: start
    do {
      let base = "hello, world!"
      let result = base.overlay.removing(at: base.startIndex)
      XCTAssertEqualCollections(result, "ello, world!")
      IndexValidator().validate(result, expectedCount: 12)
    }

    // Location: middle
    do {
      let base = "hello, world!"
      let i = base.index(base.startIndex, offsetBy: 3)
      let result = base.overlay.removing(at: i)
      XCTAssertEqualCollections(result, "helo, world!")
      IndexValidator().validate(result, expectedCount: 12)
    }

    // Location: end
    do {
      let base = "hello, world!"
      let i = base.index(before: base.endIndex)
      let result = base.overlay.removing(at: i)
      XCTAssertEqualCollections(result, "hello, world")
      IndexValidator().validate(result, expectedCount: 12)
    }

    // Location: entire collection
    do {
      let base = "x"
      let result = base.overlay.removing(at: base.startIndex)
      XCTAssertEqualCollections(result, "")
      IndexValidator().validate(result, expectedCount: 0)
    }
  }

  func testConditionalReplacement() {

    func getNumbers(shouldInsert: Bool) -> OverlayCollection<Range<Int>, CollectionOfOne<Int>> {
      (0..<5).overlay(if: shouldInsert) { $0.inserting(42, at: 2) }
    }

    do {
      let result = getNumbers(shouldInsert: true)
      XCTAssertEqualCollections(result, [0, 1, 42, 2, 3, 4])
      IndexValidator().validate(result, expectedCount: 6)
    }

    do {
      let result = getNumbers(shouldInsert: false)
      XCTAssertEqualCollections(result, [0, 1, 2, 3, 4])
      IndexValidator().validate(result, expectedCount: 5)
    }
  }
}
