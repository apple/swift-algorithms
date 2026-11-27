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

final class CompactedTests: XCTestCase {

  let tests: [[Int?]] =
    [nil, nil, nil, 0, 1, 2]
    .uniquePermutations(ofCount: 0...)
    .map(Array.init)

  func testCompactedCompacted() {
    for collection in self.tests {
      let seq = AnySequence(collection)
      expectEqualSequences(
        seq.compactMap({ $0 }), seq.compacted())
      expectEqualSequences(
        collection.compactMap({ $0 }), collection.compacted())
    }
  }

  func testCompactedBidirectionalCollection() {
    for array in self.tests {
      expectEqualSequences(
        array.compactMap({ $0 }).reversed(),
        array.compacted().reversed())
    }
  }

  func testNegativeOffsetsThroughGenericWrapper() {
    // `LazyMapCollection` calls `index(_:offsetBy:)` and `distance(from:to:)`
    // on its base through the base's `Collection` conformance.
    let compacted = [nil, 1, nil, 2, 3, nil, nil, 4].compacted()
    IndexValidator().validate(compacted.lazy.map { $0 }, expectedCount: 4)
    expectEqualSequences(compacted.lazy.map { $0 }.suffix(2), [3, 4])
  }

  func testCollectionTraversals() {
    let validator = IndexValidator<CompactedCollection<[Int?], Int>>()
    for array in self.tests {
      validator.validate(array.compacted())
    }
  }
}
