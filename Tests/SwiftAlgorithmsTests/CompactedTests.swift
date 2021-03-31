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
    for array in self.tests {
      validateIndexTraversals(array.compacted())
    }
  }

  func testCollectionEquatableConformances() {
    for array in self.tests {
      XCTAssertEqual(
        array.eraseToAnyHashableSequence().compacted(),
        array.compactMap({ $0 }).eraseToAnyHashableSequence().compacted()
      )
      XCTAssertEqual(
        array.compacted(), array.compactMap({ $0 }).compacted()
      )
    }
  }
  
  func testCollectionHashableConformances() {
    for array1 in self.tests {
      for array2 in self.tests {
        // For non-equal Collections and Sequences that produce the same
        // compacted, the compacted wrapper should produce the same hash.
        // e.g. [1, 2, 3, nil, nil, 4].compacted() should produce the
        // same hash as [1, nil, 2, nil, 3, 4].compacted()
        guard !array1.elementsEqual(array2) &&
               array1.compacted() == array2.compacted() else {
          continue
        }
        
        let seq = array1.eraseToAnyHashableSequence()
        let seq2 = array2.eraseToAnyHashableSequence()
        
        XCTAssertEqualHashValue(
          seq.compacted(), seq2.compacted()
        )
        XCTAssertEqualHashValue(
          array1.compacted(), array2.compacted()
        )
      }
    }
  }
}
