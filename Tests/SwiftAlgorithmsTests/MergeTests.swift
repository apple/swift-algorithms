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


final class MergeTests: XCTestCase {
  func _createInput(seed: UInt64, count: Int) -> (input: [Int], pivot: Int) {
    var rng = SplitMix64(seed: seed)
    // Create array of numbers with two sorted partitions
    var numbers = (1...count).map { _ in Int.random(in: 1...10, using: &rng) }
    let pivot = Int.random(in: 0...numbers.count, using: &rng)
    numbers[..<pivot].sort()
    numbers[pivot...].sort()
    
    return (numbers, pivot)
  }
  
  func _runMergeTest(_ input: [Int], pivot: Int) {
    var numbers = input
    
    // Various copies for testing different merge strategies
    var inPlace = numbers
    var partial = numbers
    var partialInPlace = numbers
    var positional = Array(numbers.enumerated())
    var positionalInPlace = positional

    // Merge with extra storage & in-place, verify equal
    numbers.merge(at: pivot)
    XCTAssertTrue(numbers.isSorted())
    inPlace.mergeInPlace(at: pivot)
    XCTAssertEqualSequences(numbers, inPlace)

    // Merge subsequences with extra storage & in-place, verify expected
    let subrange = min(pivot, 5) ..< max(pivot, partial.count - 5)
    partial.merge(subrange: subrange, at: pivot, by: <)
    XCTAssertTrue(partial[subrange].isSorted(by: <))
    partialInPlace.mergeInPlace(subrange: subrange, at: pivot, by: <)
    XCTAssertEqualSequences(partial, partialInPlace)

    // Check merge stability
    positional.merge(at: pivot, by: { $0.element < $1.element })
    XCTAssertTrue(positional.isSorted(by: { ($0.element, $0.offset) < ($1.element, $1.offset) }))
    XCTAssertEqualSequences(numbers, positional.map { $0.element })
    positionalInPlace.mergeInPlace(at: pivot, by: { $0.element < $1.element })
    XCTAssert(positional.elementsEqual(positionalInPlace, by: ==))
  }

  func testMerge() {
    var empty: [Int] = []
    empty.merge(at: 0, by: <)
    empty.mergeInPlace(at: 0, by: <)

    let range = 1...100
    var numbers = Array(range)
    for i in 0...numbers.count {
      numbers.merge(at: i, by: <)
      XCTAssertEqualSequences(numbers, range)
      numbers.mergeInPlace(at: i, by: <)
      XCTAssertEqualSequences(numbers, range)
    }
    
    // Nonsense shouldn't crash or get stuck
    var nonsense = range.map { _ in Int.random(in: 1...10) }
    nonsense.merge(at: nonsense.count / 3, by: <)
    nonsense.mergeInPlace(at: nonsense.count / 3, by: <)
  }
  
  func testFuzzMerge() {
    for _ in 0..<100 {
      let seed: UInt64 = UInt64.random(in: 0 ... .max)
      let (input, pivot) = _createInput(seed: seed, count: 300)
      _runMergeTest(input, pivot: pivot)
    }
  }
  
  func testMergeCopyOnWrite() {
    var numbers = (1...100).shuffled()
    let pivot = 25
    numbers[..<pivot].sort()
    numbers[pivot...].sort()
    
    AssertNoCopyOnWrite(numbers) { array in
      array.mergeInPlace(at: pivot, by: <)
    }
  }
}
