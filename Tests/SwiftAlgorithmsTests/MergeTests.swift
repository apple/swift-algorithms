//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift Algorithms open source project
//
// Copyright (c) 2022 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

import XCTest
import Algorithms

/// Tests for the `merge` and `lazilyMerge` functions, including the
/// `SetOperation` support type.
final class MergeTests: XCTestCase {
  /// Check the members of `SetOperation`.
  func testSetOperation() {
    // Case iteration and value
    XCTAssertEqualSequences(SetOperation.allCases, [
      .none, .firstWithoutSecond, .secondWithoutFirst, .symmetricDifference,
      .intersection, .first, .second, .union, .sum
    ])
    XCTAssertEqualSequences(SetOperation.allCases.map(\.rawValue),
                            [0, 1, 2, 3, 4, 5, 6, 7, 15])

    // Subset confirmation
    XCTAssertEqualSequences(
      SetOperation.allCases.map(\.usesExclusivesFromFirst),
      [false, true, false, true, false, true, false, true, true]
    )
    XCTAssertEqualSequences(
      SetOperation.allCases.map(\.usesExclusivesFromSecond),
      [false, false, true, true, false, false, true, true, true]
    )
    XCTAssertEqualSequences(
      SetOperation.allCases.map(\.usesShared),
      [false, false, false, false, true, true, true, true, true]
    )
    XCTAssertEqualSequences(
      SetOperation.allCases.map(\.duplicatesShared),
      [false, false, false, false, false, false, false, false, true]
    )

    // Initializer
    XCTAssertEqual(.none, SetOperation(keepExclusivesToFirst: false,
                                       keepExclusivesToSecond: false,
                                       keepShared: false))
    XCTAssertEqual(.firstWithoutSecond, SetOperation(
      keepExclusivesToFirst: true, keepExclusivesToSecond: false,
      keepShared: false))
    XCTAssertEqual(.secondWithoutFirst, SetOperation(
      keepExclusivesToFirst: false, keepExclusivesToSecond: true,
      keepShared: false))
    XCTAssertEqual(.symmetricDifference, SetOperation(
      keepExclusivesToFirst: true, keepExclusivesToSecond: true,
      keepShared: false))
    XCTAssertEqual(.intersection, SetOperation(keepExclusivesToFirst: false,
                                               keepExclusivesToSecond: false,
                                               keepShared: true))
    XCTAssertEqual(.first, SetOperation(keepExclusivesToFirst: true,
                                        keepExclusivesToSecond: false,
                                        keepShared: true))
    XCTAssertEqual(.second, SetOperation(keepExclusivesToFirst: false,
                                         keepExclusivesToSecond: true,
                                         keepShared: true))
    XCTAssertEqual(.union, SetOperation(keepExclusivesToFirst: true,
                                        keepExclusivesToSecond: true,
                                        keepShared: true))
  }

  /// Check the eager versions of merging.
  func testEagerMerge() {
    // Same (collection) type
    let first = "acegg", second = "bdfgh", sum = "abcdefgggh"
    XCTAssertEqual(merge(first, second), sum)
    XCTAssertEqual(merge([1, 2, 4, 5], [3, 6, 8, 9]), [1, 2, 3, 4, 5, 6, 8, 9])

    // Different sequence types
    XCTAssertEqual(merge(first[...], second), Array(sum))

    // Various set operations
    XCTAssertEqual(merge(first, second, keeping: .none), "")
    XCTAssertEqual(merge(first, second, keeping: .firstWithoutSecond), "aceg")
    XCTAssertEqual(merge(first, second, keeping: .secondWithoutFirst), "bdfh")
    XCTAssertEqual(merge(first,second,keeping: .symmetricDifference),"abcdefgh")
    XCTAssertEqual(merge(first, second, keeping: .intersection), "g")
    XCTAssertEqual(merge(first, second, keeping: .first), first)
    XCTAssertEqual(merge(first, second, keeping: .second), second)
    XCTAssertEqual(merge(first, second, keeping: .union), "abcdefggh")
    XCTAssertEqual(merge(first, second, keeping: .sum), sum)

    // Flip which sequence gets exhausted first.
    XCTAssertEqual(merge(second, first, keeping: .none), "")
    XCTAssertEqual(merge(second, first, keeping: .firstWithoutSecond), "bdfh")
    XCTAssertEqual(merge(second, first, keeping: .secondWithoutFirst), "aceg")
    XCTAssertEqual(merge(second,first,keeping: .symmetricDifference),"abcdefgh")
    XCTAssertEqual(merge(second, first, keeping: .intersection), "g")
    XCTAssertEqual(merge(second, first, keeping: .first), second)
    XCTAssertEqual(merge(second, first, keeping: .second), first)
    XCTAssertEqual(merge(second, first, keeping: .union), "abcdefggh")
    XCTAssertEqual(merge(second, first, keeping: .sum), sum)

    // Custom check when both sequences end at the same time
    XCTAssertEqual(merge("", ""), "")
  }

  /// Check the lazy versions of merging.
  func testLazyMerge() {
    let array1 = [0, 2, 3, 4, 4, 7], array2 = [-3, 0, 1, 6, 7, 7, 10]
    let lazyMergers = SetOperation.allCases.map {
      lazilyMerge(array1.lazy, array2.lazy, keeping: $0)
    }
    XCTAssertEqualSequences(lazyMergers.map(Array.init), [
      [], [2, 3, 4, 4], [-3, 1, 6, 7, 10], [-3, 1, 2, 3, 4, 4, 6, 7, 10],
      [0, 7], array1, array2, [-3, 0, 1, 2, 3, 4, 4, 6, 7, 7, 10],
      [-3, 0, 0, 1, 2, 3, 4, 4, 6, 7, 7, 7, 10]
    ])

    // Check the non-traversal operations.
    XCTAssertEqualSequences(lazyMergers.map(\.underestimatedCount), [
      0, 0, 1, 1, 0, 6, 7, 7, 13
    ])

    // - Check memory access; needs sequence type that uses memory blocks.
    XCTAssertEqualSequences(lazyMergers.map({ merger in
      return merger.withContiguousStorageIfAvailable { buffer in
        buffer.baseAddress == nil
      }
    }), [true, nil, nil, nil, nil, false, false, nil, nil])

    // - Check containment; needs sequence type with customized `contains`.
    let set1: Set = [5], set2: Set = [6]
    let setMergers = SetOperation.allCases.map {
      lazilyMerge(set1.lazy, set2.lazy, keeping: $0)
    }
    XCTAssertEqualSequences(setMergers.map(Array.init), [
      [], [5], [6], [5, 6], [], [5], [6], [5, 6], [5, 6]
    ])
    XCTAssertEqualSequences(setMergers.map({ merger in
      return merger._customContainsEquatableElement(4)
    }), [false, nil, nil, nil, nil, false, false, nil, false])
    XCTAssertEqualSequences(setMergers.map({ merger in
      return merger._customContainsEquatableElement(5)
    }), [false, nil, nil, nil, nil, true, false, nil, true])
    XCTAssertEqualSequences(setMergers.map({ merger in
      return merger._customContainsEquatableElement(6)
    }), [false, nil, nil, nil, nil, false, true, nil, true])

    // - Check containment, with mixed types that differ in `contains` support.
    let mixedMerger1 = SetOperation.allCases.map {
      lazilyMerge(array2.lazy, set2.lazy, keeping: $0)
    }
    XCTAssertEqualSequences(mixedMerger1.map(Array.init), [
      [], [-3, 0, 1, 7, 7, 10], [], [-3, 0, 1, 7, 7, 10], [6],
      [-3, 0, 1, 6, 7, 7, 10], [6], [-3, 0, 1, 6, 7, 7, 10],
      [-3, 0, 1, 6, 6, 7, 7, 10]
    ])
    XCTAssertEqualSequences(mixedMerger1.map({ merger in
      return merger._customContainsEquatableElement(4)
    }), [false, nil, nil, nil, nil, nil, false, nil, nil])
    XCTAssertEqualSequences(mixedMerger1.map({ merger in
      return merger._customContainsEquatableElement(6)
    }), [false, nil, nil, nil, nil, nil, true, nil, true])

    let mixedMerger2 = SetOperation.allCases.map {
      lazilyMerge(set2.lazy, array2.lazy, keeping: $0)
    }
    XCTAssertEqualSequences(mixedMerger2.map(Array.init), [
      [], [], [-3, 0, 1, 7, 7, 10], [-3, 0, 1, 7, 7, 10], [6],
      [6], [-3, 0, 1, 6, 7, 7, 10], [-3, 0, 1, 6, 7, 7, 10],
      [-3, 0, 1, 6, 6, 7, 7, 10]
    ])
    XCTAssertEqualSequences(mixedMerger2.map({ merger in
      return merger._customContainsEquatableElement(4)
    }), [false, nil, nil, nil, nil, false, nil, nil, nil])
    XCTAssertEqualSequences(mixedMerger2.map({ merger in
      return merger._customContainsEquatableElement(6)
    }), [false, nil, nil, nil, nil, true, nil, nil, true])

    // (Pseudo-)infinite sequences
    let big = lazilyMerge(repeatElement(1.0, count: .max).lazy,
                          repeatElement(2.0, count: .max).lazy)
    XCTAssertEqual(big.underestimatedCount, .max)
  }
}
