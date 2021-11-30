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

final class RotateTests: XCTestCase {
  /// Tests the example given in `_reverse(subrange:until:)`’s documentation
  func testUnderscoreReverse() {
    var input = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p"]
    let limit: Int = 4
    let (lower, upper) = input._reverse(subrange: input.startIndex..<input.endIndex, until: input.startIndex.advanced(by: limit))
    let expected = ["p", "o", "n", "m", "e", "f", "g", "h", "i", "j", "k", "l", "d", "c", "b", "a"]
    XCTAssertEqual(input, expected)
    XCTAssertEqual(lower, input.startIndex.advanced(by: limit))
    XCTAssertEqual(upper, input.endIndex.advanced(by: -limit))
  }
  
  /// Tests the example given in `reverse(subrange:)`’s documentation
  func testReverse() {
    var numbers = [10, 20, 30, 40, 50, 60, 70, 80]
    numbers.reverse(subrange: 0..<4)
    XCTAssertEqual(numbers, [40, 30, 20, 10, 50, 60, 70, 80])
  }
  
  /// Tests `rotate(subrange:toStartAt:)` with an empty subrange
  /// The order of elements are unchanged
  func testRotateEmptySubrange() {
    var numbers = [10, 20, 30, 40, 50, 60, 70, 80]
    let oldStart = numbers.rotate(subrange: 3..<3, toStartAt: 3)
    XCTAssertEqual(numbers, [10, 20, 30, 40, 50, 60, 70, 80])
    XCTAssertEqual(numbers[oldStart], 40)
  }
  
  /// Tests `rotate(subrange:toStartAt:)` with an empty collection
  func testRotateSubrangeOnEmptyCollection() {
    var numbers = [Int]()
    let oldStart = numbers.rotate(subrange: 0..<0, toStartAt: 0)
    XCTAssertEqual(numbers, [])
    XCTAssertEqual(oldStart, numbers.startIndex)
  }
  
  /// Tests `rotate(subrange:toStartAt:)` with the full range of the collection
  func testRotateFullRange() {
    var numbers = [10, 20, 30, 40, 50, 60, 70, 80]
    let oldStart = numbers.rotate(subrange: 0..<8, toStartAt: 1)
    XCTAssertEqual(numbers, [20, 30, 40, 50, 60, 70, 80, 10])
    XCTAssertEqual(numbers[oldStart], 10)
  }
  
  /// Tests the example given in `rotate(subrange:toStartAt:)`’s documentation
  func testRotateSubrange() {
    var numbers = [10, 20, 30, 40, 50, 60, 70, 80]
    let oldStart = numbers.rotate(subrange: 0..<4, toStartAt: 2)
    XCTAssertEqual(numbers, [30, 40, 10, 20, 50, 60, 70, 80])
    XCTAssertEqual(numbers[oldStart], 10)
  }
  
  /// Tests the example given in `rotate(toStartAt:)`’s documentation
  func testRotateExample() {
    var numbers = [10, 20, 30, 40, 50, 60, 70, 80]
    let oldStart = numbers.rotate(toStartAt: 3)
    XCTAssertEqual(numbers, [40, 50, 60, 70, 80, 10, 20, 30])
    XCTAssertEqual(numbers[oldStart], 10)
  }
  
  /// Tests `rotate(toStartAt:)` on collections of varying lengths, at different
  /// starting points
  func testRotate() {
    for length in 0...15 {
      let a = Array(0..<length)
      var b = a
      for j in 0..<length {
        let i = b.rotate(toStartAt: j)
        XCTAssertEqualSequences(a[j...] + a[..<j], b)
        b.rotate(toStartAt: i)
        XCTAssertEqual(a, b)
      }
    }
  }

//===----------------------------------------------------------------------===//
// RotatedCollection Tests
//===----------------------------------------------------------------------===//
  
  /// Tests lazy `rotated(subrange:toStartAt:)` with an empty collection
  func testLazyRotateSubrangeOnEmptyCollection() {
    let numbers = [Int]()
    let actual = numbers.rotated(subrange: 0..<0, toStartAt: 0)
    XCTAssertEqualSequences(actual, [])
  }
  
  /// Tests lazy `rotated(subrange:toStartAt:)` with the full range of the
  /// collection.
  func testLazyRotatedFullRange() {
    let numbers = [10, 20, 30, 40, 50, 60, 70, 80]
    let actual = numbers.rotated(subrange: 0..<8, toStartAt: 1)
    XCTAssertEqualSequences(actual, [20, 30, 40, 50, 60, 70, 80, 10])
  }
  
  /// Tests the example given in lazy `rotated(subrange:toStartAt:)`’s
  /// documentation.
  func testLazyRotatedSubrange() {
    let numbers = [10, 20, 30, 40, 50, 60, 70, 80]
    let actual = numbers.rotated(subrange: 0..<4, toStartAt: 2)
    XCTAssertEqualSequences(actual, [30, 40, 10, 20, 50, 60, 70, 80])
  }
  
  /// Tests the example given in lazy `rotated(toStartAt:)`’s documentation.
  func testLazyRotatedExample() {
    let numbers = [10, 20, 30, 40, 50, 60, 70, 80]
    let actual = numbers.rotated(toStartAt: 3)
    XCTAssertEqualSequences(actual, [40, 50, 60, 70, 80, 10, 20, 30])
  }
  
  /// Tests the `RotatedCollection` bidirectional conformance.
  func testLazyRotatedReversed() {
    let numbers = [10, 20, 30, 40, 50, 60, 70, 80]
    let actual = numbers.rotated(toStartAt: 3)
    XCTAssertEqualSequences(actual, [40, 50, 60, 70, 80, 10, 20, 30])
    let reversed: ReversedCollection<RotatedCollection<[Int]>> = actual.reversed()
    XCTAssertEqualSequences(reversed, [30, 20, 10, 80, 70, 60, 50, 40])
  }
  
  /// Tests lazy `rotated(toStartAt:)` on collections of varying lengths,
  /// at different starting points.
  func testLazyRotated() {
    for length in 0...15 {
      let a = Array(0..<length)
      var b = a
      for j in 0..<length {
        let bRotatedJ = b.rotated(toStartAt: j)
        let i = b.rotate(toStartAt: j)
        XCTAssertEqualSequences(a[j...] + a[..<j], b)
        
        // Lazy RotatedCollection of `b` produces same
        // result as in-place rotation.
        XCTAssertEqualSequences(b, bRotatedJ)
        
        b.rotate(toStartAt: i)
        
        // Test rotating a `RotatedCollection<[Int]>`
        let iRotatedIdx = bRotatedJ.index(bRotatedJ.startIndex, offsetBy: i)
        let bRotatedI = bRotatedJ.rotated(toStartAt: iRotatedIdx)
        
        // Assert that both in-place rotated and lazy
        // composed RotatedCollection of `b` produces `a`.
        XCTAssertEqual(a, b)
        XCTAssertEqualSequences(a, bRotatedI)
      }
    }
  }

  /// Tests lazy `rotated(toStartAt:)` index traversals.
  func testIndexTraversals() {
    let validator = IndexValidator<RotatedCollection<[Int]>>()
    for length in 0...15 {
      let a = Array(0..<length)
      for j in 0..<length {
        let aRotated = a.rotated(toStartAt: j)
        validator.validate(aRotated, expectedCount: length)
      }
    }
  }
}
