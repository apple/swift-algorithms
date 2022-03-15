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

final class IntersperseTests: XCTestCase {
  func testSequence() {
    let interspersed = (1...).prefix(5).interspersed(with: 0)
    XCTAssertEqualSequences(interspersed, [1,0,2,0,3,0,4,0,5])
  }

  func testSequenceEmpty() {
    let interspersed = (1...).prefix(0).interspersed(with: 0)
    XCTAssertEqualSequences(interspersed, [])
  }

  func testString() {
    let interspersed = "ABCDE".interspersed(with: "-")
    XCTAssertEqualSequences(interspersed, "A-B-C-D-E")
  }

  func testStringEmpty() {
    let interspersed = "".interspersed(with: "-")
    XCTAssertEqualSequences(interspersed, "")
  }

  func testArray() {
    let interspersed = [1,2,3,4].interspersed(with: 0)
    XCTAssertEqualSequences(interspersed, [1,0,2,0,3,0,4])
  }

  func testArrayEmpty() {
    let interspersed = [].interspersed(with: 0)
    XCTAssertEqualSequences(interspersed, [])
  }

  func testCollection() {
    let interspersed = ["A","B","C","D"].interspersed(with: "-")
    XCTAssertEqual(interspersed.count, 7)
  }

  func testBidirectionalCollection() {
    let reversed = "ABCDE".interspersed(with: "-").reversed()
    XCTAssertEqualSequences(reversed, "E-D-C-B-A")
  }
  
  func testIndexTraversals() {
    let validator = IndexValidator<InterspersedSequence<String>>()
    validator.validate("".interspersed(with: "-"), expectedCount: 0)
    validator.validate("A".interspersed(with: "-"), expectedCount: 1)
    validator.validate("AB".interspersed(with: "-"), expectedCount: 3)
    validator.validate("ABCDE".interspersed(with: "-"), expectedCount: 9)
  }

  func testIntersperseLazy() {
    XCTAssertLazySequence((1...).prefix(0).lazy.interspersed(with: 0))
    XCTAssertLazyCollection("ABCDE".lazy.interspersed(with: "-"))
  }
  
  func testInterspersedMap() {
    XCTAssertEqualSequences(
      (0..<0).lazy.interspersedMap({ $0 }, with: { _, _ in 100 }),
      [])
    
    XCTAssertEqualSequences(
      (0..<1).lazy.interspersedMap({ $0 }, with: { _, _ in 100 }),
      [0])
    
    XCTAssertEqualSequences(
      (0..<5).lazy.interspersedMap({ $0 }, with: { $0 + $1 + 100 }),
      [0, 101, 1, 103, 2, 105, 3, 107, 4])
  }
  
  func testInterspersedMapLazy() {
    XCTAssertLazySequence(AnySequence([]).lazy.interspersedMap({ $0 }, with: { _, _ in 100 }))
    XCTAssertLazyCollection((0..<0).lazy.interspersedMap({ $0 }, with: { _, _ in 100 }))
  }
    
  func testInterspersedMapIndexTraversals() {
    let validator = IndexValidator<InterspersedMapSequence<Range<Int>, Int>>()
    validator.validate(
      (0..<0).lazy.interspersedMap({ $0 }, with: {_, _ in 100 }),
      expectedCount: 0)
    validator.validate(
      (0..<1).lazy.interspersedMap({ $0 }, with: {_, _ in 100 }),
      expectedCount: 1)
    validator.validate(
      (0..<2).lazy.interspersedMap({ $0 }, with: {_, _ in 100 }),
      expectedCount: 3)
    validator.validate(
      (0..<5).lazy.interspersedMap({ $0 }, with: {_, _ in 100 }),
      expectedCount: 9)
  }
}
