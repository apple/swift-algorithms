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

//===----------------------------------------------------------------------===//
// Tests for `LazySplitSequence` and `LazySplitCollection`
//===----------------------------------------------------------------------===//

final class LazySplitTests: XCTestCase {
  // Sequences to be split are patterns of separators and non-separators. Non-
  // separators are hereafter referred to as "elements". All elements are
  // equivalent from the algorithm's perspective, so the patterns can be
  // represented as strings of "E" for elements, and "|" for separators. For
  // example, ||EE is a pattern that begins with two separators and ends with
  // two elements.
  //
  // The strategy is to validate splits of patterns representing all possible
  // relative positions of multiple adjacent separators--which seem to be
  // involved in most edge cases. Specifically, patterns where at least two
  // separators are located at the beginning, in the middle, at the end, and all
  // combinations thereof, are validated.
  //
  // That is accomplished by testing all unique permutations of all subsets of
  // of lengths 0 to 10 of the pattern ||||||||||SSSSSSSSSS. In particular, that
  // covers all patterns of length <= 10 containing:
  // - two separators, allowing for multiple adjacent separators at the
  //   beginning, middle, or end (e.g. ||EE, EEEE||EEEE, E||);
  // - four separators, allowing for multiple adjacent separators at any two of
  //   those positions (e.g. ||EEE||, EEE||E||, ||E||EEEEE);
  // - and six separators, allowing for multiple adjacent separators at any or
  //   all three of those positions (e.g. ||EE||EE||).
  //
  // Testing patterns of length as much as 10 allows for adding at least one
  // element to the beginning and/or end of the patterns containing three sets
  // of two adjacent separators (e.g. EE||E||E||, ||E||E||EE, E||E||E||E).

  func testAllLength0Through10() {
    let permutations = [
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      1, 1, 1, 1, 1, 1, 1, 1, 1, 1
    ].uniquePermutations(ofCount: 0...10)

    for p in permutations {
      Validator(subject: p, separator: .element(0)).validate()
    }
  }

  //===--------------------------------------------------------------------===//
  // Specific examples of interest.
  //===--------------------------------------------------------------------===//

  // The motivating example from
  // https://github.com/apple/swift-algorithms/issues/59.
  func testSplitFilenameComponents() {
    Validator(
      subject: "archive.tar.gz",
      separator: .element("."),
      maxSplits: 1
    ).validate()
  }

  // Examples from documentation.
  func testSequenceDocExamples() {
    // Closure version.
    let numbers = stride(from: 1, through: 16, by: 1)
    Validator(
      subject: Array(numbers),
      separator: .closure({ $0 % 3 == 0 || $0 % 5 == 0 }),
      maxSplits: 1
    ).validate()

    // Equatable element version.
    let numbers2 = [1, 2, 0, 3, 4, 0, 0, 5]
    Validator(subject: numbers2, separator: .element(0), maxSplits: 1)
      .validate()
  }

  func testCollectionDocExample() {
    let line = "BLANCHE:   I don't want realism. I want magic!"
    Validator(subject: line, separator: .element("."), maxSplits: 1).validate()
  }

  // Patterns tested in a previous version of this file which aren't tested
  // above. Preserved to ensure we're not losing any test coverage.
  func testVintagePatterns() {
    let pattern1 = [1, 2, 42, 3, 4, 42, 5, 6, 42, 7]
    Validator(subject: pattern1, separator: .element(42), maxSplits: 2)
      .validate()
    Validator(subject: pattern1, separator: .element(42), maxSplits: 0)
      .validate()

    let pattern2 = [42, 1, 2, 42, 3, 4, 42, 5, 6, 42, 7]
    Validator(subject: pattern2, separator: .element(42), maxSplits: 2)
      .validate()

    let pattern3 = [1, 2, 42, 3, 4, 42, 42, 5, 6, 42, 7]
    Validator(subject: pattern3, separator: .element(42), maxSplits: 2)
      .validate()

    let pattern4 = [1, 2, 42, 3, 4, 42, 42, 5, 6, 42, 7, 42, 42, 42]
    Validator(subject: pattern4, separator: .element(42), maxSplits: 1)
      .validate()
  }

  //===--------------------------------------------------------------------===//
  // Protocol conformance.
  //===--------------------------------------------------------------------===//

  func testLaziness() {
    let splitSequence = AnySequence([1, 2, 42, 3]).lazy.split(separator: 42)
    XCTAssertLazySequence(splitSequence)

    let splitCollection = "foo.bar".lazy.split(separator: ".")
    XCTAssertLazySequence(splitCollection)
    XCTAssertLazyCollection(splitCollection)
  }

  // TODO: Need a version of `validateIndexTraversals` that doesn't require
  // `BidirectionalCollection` conformance.

  //===--------------------------------------------------------------------===//
  // Validator
  //===--------------------------------------------------------------------===//

  /// Splits a collection as both a lazy sequence and a lazy collection, using
  /// the provided separator, and compares the results to those of the Standard
  /// Library's eager splits, which are assumed to be correct.
  ///
  /// Tests all combinations of default and provided `maxSplits` arguments and
  /// default (true) and explicit false for `omittingEmptySubsequences`.
  ///
  /// - Parameters:
  ///  - subject: The collection whose splits will be validated.
  ///  - separator: The element of the collection--or a predicate function to
  ///    determine the element--on which to split.
  ///  - maxSplits: Optional value to pass for `maxSplits` during validation. If
  ///    not provided, a value less than the number of splits generated using
  ///    the default `maxSplits` is computed and used. The default value is also
  ///    validated.
  fileprivate struct Validator<C: Collection>
  where C.Element: Equatable, C.SubSequence: Equatable {
    enum Separator {
      case element(C.Element)
      case closure((C.Element) -> Bool)
    }

    let subject: C
    let separator: Separator
    let maxSplits: Int?

    init(subject: C, separator: Separator, maxSplits: Int? = nil) {
      self.subject = subject
      self.separator = separator
      self.maxSplits = maxSplits
    }

    func validate() {
      validateAsSequence(AnySequence(subject))
      validateAsCollection(subject)
    }

    private enum MaxSplits: CustomStringConvertible {
      case provided(Int)
      case defaultValue

      var description: String {
        switch self {
        case .provided(let value):
          return "maxSplits: \(value)"
        case .defaultValue:
          return "maxSplits: default"
        }
      }
    }

    private enum OmittingEmptySubsequences: CustomStringConvertible {
      case provided(Bool)
      case defaultValue

      var description: String {
        switch self {
        case .provided(let value):
          return "omittingEmptySubsequences: \(value)"
        case .defaultValue:
          return "omittingEmptySubsequences: default"
        }
      }
    }

    private func failureMessage<L: LazySequenceProtocol, S: Sequence>(
      actual: L,
      expected: S,
      maxSplits: MaxSplits,
      omittingEmptySubsequences: OmittingEmptySubsequences
    ) -> String {
      "for \(Array(subject).debugDescription), \(maxSplits), \(omittingEmptySubsequences): \(Array(actual).debugDescription) != \(Array(expected).debugDescription)"
    }

    private func validateAsSequence<T: Sequence>(_ s: T)
    where T.Element == C.Element {
      // Default max splits, omitting empty sequences
      var testSplitCountOmittingEmpties: Int
      switch separator {
      case let .element(element):
        let expected = s.split(separator: element).map { Array($0) }
        let actual = s.lazy.split(separator: element)

        // Compute an interesting `maxSplits` value to use later, if none was
        // provided--a value less than the number of splits obtained using the
        // default.
        testSplitCountOmittingEmpties = max(0, Array(actual).count - 2)

        XCTAssertEqualSequences(
          expected,
          actual,
          failureMessage(
            actual: actual, expected: expected, maxSplits: .defaultValue,
            omittingEmptySubsequences: .defaultValue)
        )
      case let .closure(closure):
        let expected = s.split(whereSeparator: closure).map { Array($0) }
        let actual = s.lazy.split(whereSeparator: closure)

        // Compute an interesting `maxSplits` value to use later, if none was
        // provided--a value less than the number of splits obtained using the
        // default.
        testSplitCountOmittingEmpties = max(0, Array(actual).count - 2)

        XCTAssertEqualSequences(
          expected,
          actual,
          failureMessage(
            actual: actual, expected: expected, maxSplits: .defaultValue,
            omittingEmptySubsequences: .defaultValue)
        )
      }

      // Specified max splits, omitting empty sequences
      var testSplitCount = maxSplits ?? testSplitCountOmittingEmpties
      switch separator {
      case let .element(element):
        let expected = s.split(
          separator: element,
          maxSplits: testSplitCount
        ).map { Array($0) }
        let actual = s.lazy.split(
          separator: element,
          maxSplits: testSplitCount
        )
        XCTAssertEqualSequences(
          expected,
          actual,
          failureMessage(
            actual: actual, expected: expected,
            maxSplits: .provided(testSplitCount),
            omittingEmptySubsequences: .defaultValue)
        )
      case let .closure(closure):
        let expected = s.split(
          maxSplits: testSplitCount,
          whereSeparator: closure
        ).map { Array($0) }
        let actual = s.lazy.split(
          maxSplits: testSplitCount,
          whereSeparator: closure
        )
        XCTAssertEqualSequences(
          expected,
          actual,
          failureMessage(
            actual: actual, expected: expected,
            maxSplits: .provided(testSplitCount),
            omittingEmptySubsequences: .defaultValue)
        )
      }

      // Default max splits, including empty sequences
      var testSplitCountIncludingEmpties: Int
      switch separator {
      case let .element(element):
        let expected = s.split(
          separator: element,
          omittingEmptySubsequences: false
        ).map { Array($0) }
        let actual = s.lazy.split(
          separator: element,
          omittingEmptySubsequences: false
        )

        // Compute an interesting `maxSplits` value to use later, if none was
        // provided--a value less than the number of splits obtained using the
        // default.
        testSplitCountIncludingEmpties = max(0, Array(actual).count - 2)

        XCTAssertEqualSequences(
          expected,
          actual,
          failureMessage(
            actual: actual, expected: expected, maxSplits: .defaultValue,
            omittingEmptySubsequences: .provided(false))
        )
      case let .closure(closure):
        let expected = s.split(
          omittingEmptySubsequences: false,
          whereSeparator: closure
        ).map { Array($0) }
        let actual = s.lazy.split(
          omittingEmptySubsequences: false,
          whereSeparator: closure
        )

        // Compute an interesting `maxSplits` value to use later, if none was
        // provided--a value less than the number of splits obtained using the
        // default.
        testSplitCountIncludingEmpties = max(0, Array(actual).count - 2)

        XCTAssertEqualSequences(
          expected,
          actual,
          failureMessage(
            actual: actual, expected: expected, maxSplits: .defaultValue,
            omittingEmptySubsequences: .provided(false))
        )
      }

      // Specified max splits, including empty sequences
      testSplitCount = maxSplits ?? testSplitCountIncludingEmpties
      switch separator {
      case let .element(element):
        let expected = s.split(
          separator: element,
          maxSplits: testSplitCount,
          omittingEmptySubsequences: false
        ).map { Array($0) }
        let actual = s.lazy.split(
          separator: element,
          maxSplits: testSplitCount,
          omittingEmptySubsequences: false
        )
        XCTAssertEqualSequences(
          expected,
          actual,
          failureMessage(
            actual: actual, expected: expected,
            maxSplits: .provided(testSplitCount),
            omittingEmptySubsequences: .provided(false))
        )
      case let .closure(closure):
        let expected = s.split(
          maxSplits: testSplitCount,
          omittingEmptySubsequences: false,
          whereSeparator: closure
        ).map { Array($0) }
        let actual = s.lazy.split(
          maxSplits: testSplitCount,
          omittingEmptySubsequences: false,
          whereSeparator: closure
        )
        XCTAssertEqualSequences(
          expected,
          actual,
          failureMessage(
            actual: actual, expected: expected,
            maxSplits: .provided(testSplitCount),
            omittingEmptySubsequences: .provided(false))
        )
      }
    }

    private func validateAsCollection(_ c: C) {
      // Default max splits, omitting empty sequences
      var testSplitCountOmittingEmpties: Int
      switch separator {
      case let .element(element):
        let expected = c.split(separator: element)
        let actual = c.lazy.split(separator: element)

        // Compute an interesting `maxSplits` value to use later, if none was
        // provided--a value less than the number of splits obtained using the
        // default.
        testSplitCountOmittingEmpties = max(0, actual.count - 2)

        XCTAssertEqualSequences(
          expected,
          actual,
          failureMessage(
            actual: actual, expected: expected, maxSplits: .defaultValue,
            omittingEmptySubsequences: .defaultValue)
        )
      case let .closure(closure):
        let expected = c.split(whereSeparator: closure)
        let actual = c.lazy.split(whereSeparator: closure)

        // Compute an interesting `maxSplits` value to use later, if none was
        // provided--a value less than the number of splits obtained using the
        // default.
        testSplitCountOmittingEmpties = max(0, actual.count - 2)

        XCTAssertEqualSequences(
          expected,
          actual,
          failureMessage(
            actual: actual, expected: expected, maxSplits: .defaultValue,
            omittingEmptySubsequences: .defaultValue)
        )
      }

      // Specified max splits, omitting empty sequences
      var testSplitCount = maxSplits ?? testSplitCountOmittingEmpties
      switch separator {
      case let .element(element):
        let expected = c.split(
          separator: element,
          maxSplits: testSplitCount
        )
        let actual = c.lazy.split(
          separator: element,
          maxSplits: testSplitCount
        )
        XCTAssertEqualSequences(
          expected,
          actual,
          failureMessage(
            actual: actual, expected: expected,
            maxSplits: .provided(testSplitCount),
            omittingEmptySubsequences: .defaultValue)
        )
      case let .closure(closure):
        let expected = c.split(
          maxSplits: testSplitCount,
          whereSeparator: closure
        )
        let actual = c.lazy.split(
          maxSplits: testSplitCount,
          whereSeparator: closure
        )
        XCTAssertEqualSequences(
          expected,
          actual,
          failureMessage(
            actual: actual, expected: expected,
            maxSplits: .provided(testSplitCount),
            omittingEmptySubsequences: .defaultValue)
        )
      }

      // Default max splits, including empty sequences
      var testSplitCountIncludingEmpties: Int
      switch separator {
      case let .element(element):
        let expected = c.split(
          separator: element,
          omittingEmptySubsequences: false
        )
        let actual = c.lazy.split(
          separator: element,
          omittingEmptySubsequences: false
        )

        // Compute an interesting `maxSplits` value to use later, if none was
        // provided--a value less than the number of splits obtained using the
        // default.
        testSplitCountIncludingEmpties = max(0, actual.count - 2)

        XCTAssertEqualSequences(
          expected,
          actual,
          failureMessage(
            actual: actual, expected: expected, maxSplits: .defaultValue,
            omittingEmptySubsequences: .provided(false))
        )
      case let .closure(closure):
        let expected = c.split(
          omittingEmptySubsequences: false,
          whereSeparator: closure
        )
        let actual = c.lazy.split(
          omittingEmptySubsequences: false,
          whereSeparator: closure
        )

        // Compute an interesting `maxSplits` value to use later, if none was
        // provided--a value less than the number of splits obtained using the
        // default.
        testSplitCountIncludingEmpties = max(0, actual.count - 2)

        XCTAssertEqualSequences(
          expected,
          actual,
          failureMessage(
            actual: actual, expected: expected, maxSplits: .defaultValue,
            omittingEmptySubsequences: .provided(false))
        )
      }

      // Specified max splits, including empty sequences
      testSplitCount = maxSplits ?? testSplitCountIncludingEmpties
      switch separator {
      case let .element(element):
        let expected = c.split(
          separator: element,
          maxSplits: testSplitCount,
          omittingEmptySubsequences: false
        )
        let actual = c.lazy.split(
          separator: element,
          maxSplits: testSplitCount,
          omittingEmptySubsequences: false
        )
        XCTAssertEqualSequences(
          expected,
          actual,
          failureMessage(
            actual: actual, expected: expected,
            maxSplits: .provided(testSplitCount),
            omittingEmptySubsequences: .provided(false))
        )
      case let .closure(closure):
        let expected = c.split(
          maxSplits: testSplitCount,
          omittingEmptySubsequences: false,
          whereSeparator: closure
        )
        let actual = c.lazy.split(
          maxSplits: testSplitCount,
          omittingEmptySubsequences: false,
          whereSeparator: closure
        )
        XCTAssertEqualSequences(
          expected,
          actual,
          failureMessage(
            actual: actual, expected: expected,
            maxSplits: .provided(testSplitCount),
            omittingEmptySubsequences: .provided(false))
        )
      }
    }
  }
}
