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

/// Unit tests for `SetCombination`, `MergedSequence`, and `mergedSorted`.
final class MergeSortedTests: XCTestCase {
  /// Check the values and properties of `SetCollection`.
  func testSelectionType() {
    XCTAssertEqualSequences(SetCombination.allCases, [.nothing,
      .firstMinusSecond, .secondMinusFirst, .symmetricDifference, .intersection,
      .first, .second, .union, .sum
    ])

    // Use a merged-sequence's iterator to spy on the properties.
    // (The properties only depend on the case, not the source types nor the
    // predicate.)
    let iterators = SetCombination.allCases.map {
      MergedSequence(EmptyCollection<Double>(), EmptyCollection<Double>(),
                     keeping: $0, by: <).makeIterator()
    }
    XCTAssertEqualSequences(iterators.map(\.exclusivesFromFirst),
                  [false, true, false, true, false, true, false, true, true])
    XCTAssertEqualSequences(iterators.map(\.exclusivesFromSecond),
                  [false, false, true, true, false, false, true, true, true])
    XCTAssertEqualSequences(iterators.map(\.sharedFromFirst),
                  [false, false, false, false, true, true, false, true, true])
    XCTAssertEqualSequences(iterators.map(\.sharedFromSecond),
                  [false, false, false, false, false, false, true, false, true])
    XCTAssertEqualSequences(iterators.map(\.extractFromFirst),
                      [false, true, true, true, true, true, false, true, true])
    XCTAssertEqualSequences(iterators.map(\.extractFromSecond),
                      [false, true, true, true, true, false, true, true, true])
  }

  /// Check results from using empty operands, and using the generating methods.
  func testEmpty() {
    let empty = EmptyCollection<Double>()
    let emptyMergerArrays = SetCombination.allCases.map {
      empty.mergeSorted(with: empty, keeping: $0)
    }
    let emptyResults = Array(repeating: [Double](),
                             count: SetCombination.allCases.count)
    XCTAssertEqualSequences(emptyMergerArrays, emptyResults)

    // Call the lazy methods.
    let emptyMergerSingleLazy = SetCombination.allCases.map {
      empty.lazy.mergeSorted(with: empty, keeping: $0)
    }
    XCTAssertEqualSequences(emptyMergerSingleLazy.map(Array.init), emptyResults)

    let emptyMergerDoubleLazy = SetCombination.allCases.map {
      empty.lazy.mergeSorted(with: empty.lazy, keeping: $0)
    }
    XCTAssertEqualSequences(emptyMergerDoubleLazy.map(Array.init), emptyResults)
  }

  /// Check results from using one empty and one non-empty operand.
  func testExactlyOneEmpty() {
    let limit = Int.random(in: 1..<100), nonEmpty = 0..<limit,
        nonEmptyArray = Array(nonEmpty), empty = EmptyCollection<Int>()
    let nonEmptyVersusEmptyMergers = SetCombination.allCases.map {
      MergedSequence(nonEmpty, empty, keeping: $0, by: <)
    }
    XCTAssertEqualSequences(nonEmptyVersusEmptyMergers.map(Array.init), [
      [], nonEmptyArray, [], nonEmptyArray, [], nonEmptyArray, [],
      nonEmptyArray, nonEmptyArray
    ])

    let emptyVersusNonEmptyMergers = SetCombination.allCases.map {
      MergedSequence(empty, nonEmpty, keeping: $0, by: <)
    }
    XCTAssertEqualSequences(emptyVersusNonEmptyMergers.map(Array.init), [
      [], [], nonEmptyArray, nonEmptyArray, [], [], nonEmptyArray,
      nonEmptyArray, nonEmptyArray
    ])
  }

  /// Check results on using the same nonempty sequence for both operands.
  func testIdentical() {
    let sample = Array(1..<Int.random(in: 3..<100))
    let selfMergers = SetCombination.allCases.map {
      MergedSequence(sample, sample, keeping: $0, by: <)
    }
    XCTAssertEqualSequences(selfMergers.map(Array.init), [
      [], [], [], [], sample, sample, sample, sample,
      Array(sample.map { Array(repeating: $0, count: 2) }.joined())
    ])
  }

  /// Check results when one nonempty sequence is a subset of a longer one.
  func testProperSubset() {
    let sample = Array(0...20), subSample = [2, 3, 5, 7, 11, 13, 17, 19],
        inverted = [0, 1, 4, 6, 8, 9, 10, 12, 14, 15, 16, 18, 20]
    let sampleAndSubMergers = SetCombination.allCases.map {
      MergedSequence(sample, subSample, keeping: $0, by: <)
    }
    let primeRepeatingSample = Array(sample.map {
      Array(repeating: $0, count: $0.isPrime ? 2 : 1)
    }.joined())

    XCTAssertEqualSequences(sampleAndSubMergers.map(Array.init), [
      [], inverted, [], inverted, subSample, sample, subSample, sample,
      primeRepeatingSample
    ])

    let subAndSampleMergers = SetCombination.allCases.map {
      MergedSequence(subSample, sample, keeping: $0, by: <)
    }
    XCTAssertEqualSequences(subAndSampleMergers.map(Array.init), [
      [], [], inverted, inverted, subSample, subSample, sample, sample,
      primeRepeatingSample
    ])

    // Originally, I had "sample" stop before 20, and 20 was left out of
    // "inverted."  This mean that "sample" ended on an element that was also
    // part of "subSample."  This lead to some lines of code in the iterator
    // being missed.
  }

  /// Check results of two unrelated nonempty sequences.
  func testDisjoint() {
    let s1 = [2, 4, 6, 8, 10], s2 = [3, 5, 7, 9, 11], all = Array(2...11)
    let sample1To2Merger = SetCombination.allCases.map {
      MergedSequence(s1, s2, keeping: $0, by: <)
    }
    XCTAssertEqualSequences(sample1To2Merger.map(Array.init), [
      [], s1, s2, all, [], s1, s2, all, all
    ])

    let sample2To1Merger = SetCombination.allCases.map {
      MergedSequence(s2, s1, keeping: $0, by: <)
    }
    XCTAssertEqualSequences(sample2To1Merger.map(Array.init), [
      [], s2, s1, all, [], s2, s1, all, all
    ])
  }
}

//-----------------------------------------------------------------------------/

extension FixedWidthInteger {
  /// Confirms if this value is prime, but slowly.
  fileprivate var isPrime: Bool {
    guard self >= 2 else { return false }
    guard self >= 4 else { return true }

    for divisor in 2..<self {
      let (quotient, remainder) = quotientAndRemainder(dividingBy: divisor)
      guard remainder != 0 else { return false }
      guard quotient > divisor else { break }

      // The guards above cover everything.
    }
    return true
  }
}
