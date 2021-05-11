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
@testable import Algorithms

final class JoinedTests: XCTestCase {
  func testSequence() {
    for x in [0..<0, 0..<0, 0..<5, 5..<10, 10..<15, 15..<15].joined(by: [100, 101]) {
      print(x)
    }
  }
  
  func testJoinedIndexTraversals() {
    validateIndexTraversals(
      [].joined(),
      [[]].joined(),
      [[], []].joined(),
      [[0]].joined(),
      [[], [0], [1, 2], [3], []].joined(),
      [[], [], [0], [1], [], [], [2, 3], [], []].joined())
  }
  
  func testJoinedByIndexTraversals() {
    let elements: [[Range<Int>]] = [
      [],
      [0..<0],
      [0..<3],
      [0..<3, 3..<6],
      [0..<0, 0..<3, 3..<6, 6..<6],
      [0..<0, 0..<0, 0..<3, 3..<3, 3..<6, 6..<6, 6..<6]
    ]
    
    for collection in elements {
      validateIndexTraversals(collection.joined(by: 100))
    }
    
    let separators: [[Int]] = [[], [100], [100, 101]]
    
    for (collection, separator) in product(elements, separators) {
      validateIndexTraversals(collection.joined(by: separator))
    }
  }
}
