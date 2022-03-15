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
import Algorithms

final class CompactedTests: XCTestCase {

  let tests: [[Int?]] =
    [nil, nil, nil, 0, 1, 2]
        .uniquePermutations(ofCount: 0...)
        .map(Array.init)
  
  func testCompactedCompacted() {
    for collection in self.tests {
      let seq = AnySequence(collection)
      XCTAssertEqualSequences(
        seq.compactMap({ $0 }), seq.compacted())
      XCTAssertEqualSequences(
        collection.compactMap({ $0 }), collection.compacted())
    }
  }

  func testCompactedBidirectionalCollection() {
    for array in self.tests {
      XCTAssertEqualSequences(array.compactMap({ $0 }).reversed(),
                              array.compacted().reversed())
    }
  }
  
  func testCollectionTraversals() {
    let validator = IndexValidator<CompactedCollection<[Int?], Int>>()
    for array in self.tests {
      validator.validate(array.compacted())
    }
  }
}
