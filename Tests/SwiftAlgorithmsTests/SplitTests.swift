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
// Tests for `SplitSequence` and `SplitCollection`
//===----------------------------------------------------------------------===//

final class SplitTests: XCTestCase {
  func testEmpty() {
    Validator(
      subject: [],
      separator: .element(0),
      maxSplits: 1
    ).validate()
  }

  // The following test names indicate the sequence being split, using the
  // notation
  // S: Separator
  // E: Element
  //
  // Values of `maxSplit` are interesting when they're less than the number of
  // splits that would occur with the default. That varies depending on whether
  // empty subsequences are omitted or included. `Validator` tests both the
  // default and the value provided, but there are cases below where the
  // provided `maxSplit` isn't less than the number of splits when empty
  // subsequences are omitted.

  //===--------------------------------------------------------------------===//
  // Length 1
  //===--------------------------------------------------------------------===//

  func testE() {
    Validator(subject: [1], separator: .element(0), maxSplits: 0).validate()
  }

  func testS() {
    Validator(subject: [0], separator: .element(0), maxSplits: 0).validate()
  }

  //===--------------------------------------------------------------------===//
  // Length 2
  //===--------------------------------------------------------------------===//

  func testEE() {
    Validator(subject: [1, 1], separator: .element(0), maxSplits: 0).validate()
  }

  func testSS() {
    Validator(subject: [0, 0], separator: .element(0), maxSplits: 1).validate()
  }

  func testES() {
    Validator(subject: [1, 0], separator: .element(0), maxSplits: 0).validate()
  }

  func testSE() {
    Validator(subject: [0, 1], separator: .element(0), maxSplits: 0).validate()
  }

  //===--------------------------------------------------------------------===//
  // Length 3
  //===--------------------------------------------------------------------===//

  func testEEE() {
    Validator(subject: [1, 1, 1], separator: .element(0), maxSplits: 0)
      .validate()
  }

  func testSSS() {
    Validator(subject: [0, 0, 0], separator: .element(0), maxSplits: 1)
      .validate()
  }

  func testAllEES() {
    let permutations = [[1, 1, 0], [1, 0, 1], [0, 1, 1]]

    for permutation in permutations {
      Validator(subject: permutation, separator: .element(0), maxSplits: 0)
        .validate()
    }
  }

  func testAllESS() {
    let permutations = [[1, 0, 0], [0, 1, 0], [0, 0, 1]]

    for permutation in permutations {
      Validator(subject: permutation, separator: .element(0), maxSplits: 1)
        .validate()
    }
  }

  //===--------------------------------------------------------------------===//
  // Length 4 with less than two separators.
  //===--------------------------------------------------------------------===//

  func testEEEE() {
    Validator(subject: [1, 1, 1, 1], separator: .element(0), maxSplits: 0)
      .validate()
  }

  func testAllEEES() {
    let permutations = [
      [1, 1, 1, 0], [1, 1, 0, 1], [1, 0, 1, 1], [0, 1, 1, 1]
    ]

    for permutation in permutations {
      Validator(subject: permutation, separator: .element(0), maxSplits: 0)
        .validate()
    }
  }

  //===--------------------------------------------------------------------===//
  // Unique permutations of sequences with at least two separators, so there can
  // be multiple adjacent separators at the beginning, middle, or end.
  //===--------------------------------------------------------------------===//

  // All separators.
  func testSSSS() {
    Validator(subject: [0, 0, 0, 0], separator: .element(0), maxSplits: 1)
      .validate()
  }

  // Equal numbers of elements and separators.
  func testAllEESS() {
    let permutations = [
      [1, 1, 0, 0], [1, 0, 1, 0], [1, 0, 0, 1],
      [0, 1, 1, 0], [0, 1, 0, 1], [0, 0, 1, 1],
    ]

    for permutation in permutations {
      Validator(subject: permutation, separator: .element(0), maxSplits: 1)
        .validate()
    }
  }

  // More separators than elements.
  func testAllEESSS() {
    let permutations = [
      [1, 1, 0, 0, 0], [1, 0, 1, 0, 0], [1, 0, 0, 1, 0], [1, 0, 0, 0, 1],
      [0, 1, 1, 0, 0], [0, 1, 0, 1, 0], [0, 1, 0, 0, 1], [0, 0, 1, 1, 0],
      [0, 0, 1, 0, 1], [0, 0, 0, 1, 1],
    ]

    for permutation in permutations {
      Validator(subject: permutation, separator: .element(0), maxSplits: 1)
        .validate()
    }
  }

  // More elements than separators.
  func testAllEEESS() {
    let permutations = [
      [1, 1, 1, 0, 0], [1, 1, 0, 1, 0], [1, 1, 0, 0, 1], [1, 0, 1, 1, 0],
      [1, 0, 1, 0, 1], [1, 0, 0, 1, 1], [0, 1, 1, 1, 0], [0, 1, 1, 0, 1],
      [0, 1, 0, 1, 1], [0, 0, 1, 1, 1],
    ]

    for permutation in permutations {
      Validator(subject: permutation, separator: .element(0), maxSplits: 1)
        .validate()
    }
  }

  //===--------------------------------------------------------------------===//
  // Unique permutations of sequences with at least three separators.
  //===--------------------------------------------------------------------===//

  func testAllESSS() {
    let permutations = [
      [1, 0, 0, 0], [0, 1, 0, 0], [0, 0, 1, 0], [0, 0, 0, 1],
    ]

    for permutation in permutations {
      Validator(subject: permutation, separator: .element(0), maxSplits: 1)
        .validate()
    }
  }

  func testAllEEEESSS() {
    let permutations = [
      [1, 1, 1, 1, 0, 0, 0], [1, 1, 1, 0, 1, 0, 0], [1, 1, 1, 0, 0, 1, 0],
      [1, 1, 1, 0, 0, 0, 1], [1, 1, 0, 1, 1, 0, 0], [1, 1, 0, 1, 0, 1, 0],
      [1, 1, 0, 1, 0, 0, 1], [1, 1, 0, 0, 1, 1, 0], [1, 1, 0, 0, 1, 0, 1],
      [1, 1, 0, 0, 0, 1, 1], [1, 0, 1, 1, 1, 0, 0], [1, 0, 1, 1, 0, 1, 0],
      [1, 0, 1, 1, 0, 0, 1], [1, 0, 1, 0, 1, 1, 0], [1, 0, 1, 0, 1, 0, 1],
      [1, 0, 1, 0, 0, 1, 1], [1, 0, 0, 1, 1, 1, 0], [1, 0, 0, 1, 1, 0, 1],
      [1, 0, 0, 1, 0, 1, 1], [1, 0, 0, 0, 1, 1, 1], [0, 1, 1, 1, 1, 0, 0],
      [0, 1, 1, 1, 0, 1, 0], [0, 1, 1, 1, 0, 0, 1], [0, 1, 1, 0, 1, 1, 0],
      [0, 1, 1, 0, 1, 0, 1], [0, 1, 1, 0, 0, 1, 1], [0, 1, 0, 1, 1, 1, 0],
      [0, 1, 0, 1, 1, 0, 1], [0, 1, 0, 1, 0, 1, 1], [0, 1, 0, 0, 1, 1, 1],
      [0, 0, 1, 1, 1, 1, 0], [0, 0, 1, 1, 1, 0, 1], [0, 0, 1, 1, 0, 1, 1],
      [0, 0, 1, 0, 1, 1, 1], [0, 0, 0, 1, 1, 1, 1],
    ]

    for permutation in permutations {
      Validator(subject: permutation, separator: .element(0), maxSplits: 1)
        .validate()
    }
  }

  //===--------------------------------------------------------------------===//
  // Unique permutations of sequences with at least four separators, so there
  // can be two runs of multiple adjacent separators: beginning and end,
  // beginning and middle, or end and middle.
  //===--------------------------------------------------------------------===//

  // Equal numbers of separators and elements.
  func testAllEEEESSSS() {
    let permutations = [
      [1, 1, 1, 1, 0, 0, 0, 0], [1, 1, 1, 0, 1, 0, 0, 0],
      [1, 1, 1, 0, 0, 1, 0, 0], [1, 1, 1, 0, 0, 0, 1, 0],
      [1, 1, 1, 0, 0, 0, 0, 1], [1, 1, 0, 1, 1, 0, 0, 0],
      [1, 1, 0, 1, 0, 1, 0, 0], [1, 1, 0, 1, 0, 0, 1, 0],
      [1, 1, 0, 1, 0, 0, 0, 1], [1, 1, 0, 0, 1, 1, 0, 0],
      [1, 1, 0, 0, 1, 0, 1, 0], [1, 1, 0, 0, 1, 0, 0, 1],
      [1, 1, 0, 0, 0, 1, 1, 0], [1, 1, 0, 0, 0, 1, 0, 1],
      [1, 1, 0, 0, 0, 0, 1, 1], [1, 0, 1, 1, 1, 0, 0, 0],
      [1, 0, 1, 1, 0, 1, 0, 0], [1, 0, 1, 1, 0, 0, 1, 0],
      [1, 0, 1, 1, 0, 0, 0, 1], [1, 0, 1, 0, 1, 1, 0, 0],
      [1, 0, 1, 0, 1, 0, 1, 0], [1, 0, 1, 0, 1, 0, 0, 1],
      [1, 0, 1, 0, 0, 1, 1, 0], [1, 0, 1, 0, 0, 1, 0, 1],
      [1, 0, 1, 0, 0, 0, 1, 1], [1, 0, 0, 1, 1, 1, 0, 0],
      [1, 0, 0, 1, 1, 0, 1, 0], [1, 0, 0, 1, 1, 0, 0, 1],
      [1, 0, 0, 1, 0, 1, 1, 0], [1, 0, 0, 1, 0, 1, 0, 1],
      [1, 0, 0, 1, 0, 0, 1, 1], [1, 0, 0, 0, 1, 1, 1, 0],
      [1, 0, 0, 0, 1, 1, 0, 1], [1, 0, 0, 0, 1, 0, 1, 1],
      [1, 0, 0, 0, 0, 1, 1, 1], [0, 1, 1, 1, 1, 0, 0, 0],
      [0, 1, 1, 1, 0, 1, 0, 0], [0, 1, 1, 1, 0, 0, 1, 0],
      [0, 1, 1, 1, 0, 0, 0, 1], [0, 1, 1, 0, 1, 1, 0, 0],
      [0, 1, 1, 0, 1, 0, 1, 0], [0, 1, 1, 0, 1, 0, 0, 1],
      [0, 1, 1, 0, 0, 1, 1, 0], [0, 1, 1, 0, 0, 1, 0, 1],
      [0, 1, 1, 0, 0, 0, 1, 1], [0, 1, 0, 1, 1, 1, 0, 0],
      [0, 1, 0, 1, 1, 0, 1, 0], [0, 1, 0, 1, 1, 0, 0, 1],
      [0, 1, 0, 1, 0, 1, 1, 0], [0, 1, 0, 1, 0, 1, 0, 1],
      [0, 1, 0, 1, 0, 0, 1, 1], [0, 1, 0, 0, 1, 1, 1, 0],
      [0, 1, 0, 0, 1, 1, 0, 1], [0, 1, 0, 0, 1, 0, 1, 1],
      [0, 1, 0, 0, 0, 1, 1, 1], [0, 0, 1, 1, 1, 1, 0, 0],
      [0, 0, 1, 1, 1, 0, 1, 0], [0, 0, 1, 1, 1, 0, 0, 1],
      [0, 0, 1, 1, 0, 1, 1, 0], [0, 0, 1, 1, 0, 1, 0, 1],
      [0, 0, 1, 1, 0, 0, 1, 1], [0, 0, 1, 0, 1, 1, 1, 0],
      [0, 0, 1, 0, 1, 1, 0, 1], [0, 0, 1, 0, 1, 0, 1, 1],
      [0, 0, 1, 0, 0, 1, 1, 1], [0, 0, 0, 1, 1, 1, 1, 0],
      [0, 0, 0, 1, 1, 1, 0, 1], [0, 0, 0, 1, 1, 0, 1, 1],
      [0, 0, 0, 1, 0, 1, 1, 1], [0, 0, 0, 0, 1, 1, 1, 1],
    ]

    for permutation in permutations {
      Validator(subject: permutation, separator: .element(0), maxSplits: 1)
        .validate()
    }
  }

  // More separators than elements.
  func testAllEEESSSS() {
    let permutations = [
      [1, 1, 1, 0, 0, 0, 0], [1, 1, 0, 1, 0, 0, 0], [1, 1, 0, 0, 1, 0, 0],
      [1, 1, 0, 0, 0, 1, 0], [1, 1, 0, 0, 0, 0, 1], [1, 0, 1, 1, 0, 0, 0],
      [1, 0, 1, 0, 1, 0, 0], [1, 0, 1, 0, 0, 1, 0], [1, 0, 1, 0, 0, 0, 1],
      [1, 0, 0, 1, 1, 0, 0], [1, 0, 0, 1, 0, 1, 0], [1, 0, 0, 1, 0, 0, 1],
      [1, 0, 0, 0, 1, 1, 0], [1, 0, 0, 0, 1, 0, 1], [1, 0, 0, 0, 0, 1, 1],
      [0, 1, 1, 1, 0, 0, 0], [0, 1, 1, 0, 1, 0, 0], [0, 1, 1, 0, 0, 1, 0],
      [0, 1, 1, 0, 0, 0, 1], [0, 1, 0, 1, 1, 0, 0], [0, 1, 0, 1, 0, 1, 0],
      [0, 1, 0, 1, 0, 0, 1], [0, 1, 0, 0, 1, 1, 0], [0, 1, 0, 0, 1, 0, 1],
      [0, 1, 0, 0, 0, 1, 1], [0, 0, 1, 1, 1, 0, 0], [0, 0, 1, 1, 0, 1, 0],
      [0, 0, 1, 1, 0, 0, 1], [0, 0, 1, 0, 1, 1, 0], [0, 0, 1, 0, 1, 0, 1],
      [0, 0, 1, 0, 0, 1, 1], [0, 0, 0, 1, 1, 1, 0], [0, 0, 0, 1, 1, 0, 1],
      [0, 0, 0, 1, 0, 1, 1], [0, 0, 0, 0, 1, 1, 1],
    ]

    for permutation in permutations {
      Validator(subject: permutation, separator: .element(0), maxSplits: 1)
        .validate()
    }
  }

  // More elements than separators.
  func testAllEEEEESSSS() {
    let permutations = [
      [1, 1, 1, 1, 1, 0, 0, 0, 0], [1, 1, 1, 1, 0, 1, 0, 0, 0],
      [1, 1, 1, 1, 0, 0, 1, 0, 0], [1, 1, 1, 1, 0, 0, 0, 1, 0],
      [1, 1, 1, 1, 0, 0, 0, 0, 1], [1, 1, 1, 0, 1, 1, 0, 0, 0],
      [1, 1, 1, 0, 1, 0, 1, 0, 0], [1, 1, 1, 0, 1, 0, 0, 1, 0],
      [1, 1, 1, 0, 1, 0, 0, 0, 1], [1, 1, 1, 0, 0, 1, 1, 0, 0],
      [1, 1, 1, 0, 0, 1, 0, 1, 0], [1, 1, 1, 0, 0, 1, 0, 0, 1],
      [1, 1, 1, 0, 0, 0, 1, 1, 0], [1, 1, 1, 0, 0, 0, 1, 0, 1],
      [1, 1, 1, 0, 0, 0, 0, 1, 1], [1, 1, 0, 1, 1, 1, 0, 0, 0],
      [1, 1, 0, 1, 1, 0, 1, 0, 0], [1, 1, 0, 1, 1, 0, 0, 1, 0],
      [1, 1, 0, 1, 1, 0, 0, 0, 1], [1, 1, 0, 1, 0, 1, 1, 0, 0],
      [1, 1, 0, 1, 0, 1, 0, 1, 0], [1, 1, 0, 1, 0, 1, 0, 0, 1],
      [1, 1, 0, 1, 0, 0, 1, 1, 0], [1, 1, 0, 1, 0, 0, 1, 0, 1],
      [1, 1, 0, 1, 0, 0, 0, 1, 1], [1, 1, 0, 0, 1, 1, 1, 0, 0],
      [1, 1, 0, 0, 1, 1, 0, 1, 0], [1, 1, 0, 0, 1, 1, 0, 0, 1],
      [1, 1, 0, 0, 1, 0, 1, 1, 0], [1, 1, 0, 0, 1, 0, 1, 0, 1],
      [1, 1, 0, 0, 1, 0, 0, 1, 1], [1, 1, 0, 0, 0, 1, 1, 1, 0],
      [1, 1, 0, 0, 0, 1, 1, 0, 1], [1, 1, 0, 0, 0, 1, 0, 1, 1],
      [1, 1, 0, 0, 0, 0, 1, 1, 1], [1, 0, 1, 1, 1, 1, 0, 0, 0],
      [1, 0, 1, 1, 1, 0, 1, 0, 0], [1, 0, 1, 1, 1, 0, 0, 1, 0],
      [1, 0, 1, 1, 1, 0, 0, 0, 1], [1, 0, 1, 1, 0, 1, 1, 0, 0],
      [1, 0, 1, 1, 0, 1, 0, 1, 0], [1, 0, 1, 1, 0, 1, 0, 0, 1],
      [1, 0, 1, 1, 0, 0, 1, 1, 0], [1, 0, 1, 1, 0, 0, 1, 0, 1],
      [1, 0, 1, 1, 0, 0, 0, 1, 1], [1, 0, 1, 0, 1, 1, 1, 0, 0],
      [1, 0, 1, 0, 1, 1, 0, 1, 0], [1, 0, 1, 0, 1, 1, 0, 0, 1],
      [1, 0, 1, 0, 1, 0, 1, 1, 0], [1, 0, 1, 0, 1, 0, 1, 0, 1],
      [1, 0, 1, 0, 1, 0, 0, 1, 1], [1, 0, 1, 0, 0, 1, 1, 1, 0],
      [1, 0, 1, 0, 0, 1, 1, 0, 1], [1, 0, 1, 0, 0, 1, 0, 1, 1],
      [1, 0, 1, 0, 0, 0, 1, 1, 1], [1, 0, 0, 1, 1, 1, 1, 0, 0],
      [1, 0, 0, 1, 1, 1, 0, 1, 0], [1, 0, 0, 1, 1, 1, 0, 0, 1],
      [1, 0, 0, 1, 1, 0, 1, 1, 0], [1, 0, 0, 1, 1, 0, 1, 0, 1],
      [1, 0, 0, 1, 1, 0, 0, 1, 1], [1, 0, 0, 1, 0, 1, 1, 1, 0],
      [1, 0, 0, 1, 0, 1, 1, 0, 1], [1, 0, 0, 1, 0, 1, 0, 1, 1],
      [1, 0, 0, 1, 0, 0, 1, 1, 1], [1, 0, 0, 0, 1, 1, 1, 1, 0],
      [1, 0, 0, 0, 1, 1, 1, 0, 1], [1, 0, 0, 0, 1, 1, 0, 1, 1],
      [1, 0, 0, 0, 1, 0, 1, 1, 1], [1, 0, 0, 0, 0, 1, 1, 1, 1],
      [0, 1, 1, 1, 1, 1, 0, 0, 0], [0, 1, 1, 1, 1, 0, 1, 0, 0],
      [0, 1, 1, 1, 1, 0, 0, 1, 0], [0, 1, 1, 1, 1, 0, 0, 0, 1],
      [0, 1, 1, 1, 0, 1, 1, 0, 0], [0, 1, 1, 1, 0, 1, 0, 1, 0],
      [0, 1, 1, 1, 0, 1, 0, 0, 1], [0, 1, 1, 1, 0, 0, 1, 1, 0],
      [0, 1, 1, 1, 0, 0, 1, 0, 1], [0, 1, 1, 1, 0, 0, 0, 1, 1],
      [0, 1, 1, 0, 1, 1, 1, 0, 0], [0, 1, 1, 0, 1, 1, 0, 1, 0],
      [0, 1, 1, 0, 1, 1, 0, 0, 1], [0, 1, 1, 0, 1, 0, 1, 1, 0],
      [0, 1, 1, 0, 1, 0, 1, 0, 1], [0, 1, 1, 0, 1, 0, 0, 1, 1],
      [0, 1, 1, 0, 0, 1, 1, 1, 0], [0, 1, 1, 0, 0, 1, 1, 0, 1],
      [0, 1, 1, 0, 0, 1, 0, 1, 1], [0, 1, 1, 0, 0, 0, 1, 1, 1],
      [0, 1, 0, 1, 1, 1, 1, 0, 0], [0, 1, 0, 1, 1, 1, 0, 1, 0],
      [0, 1, 0, 1, 1, 1, 0, 0, 1], [0, 1, 0, 1, 1, 0, 1, 1, 0],
      [0, 1, 0, 1, 1, 0, 1, 0, 1], [0, 1, 0, 1, 1, 0, 0, 1, 1],
      [0, 1, 0, 1, 0, 1, 1, 1, 0], [0, 1, 0, 1, 0, 1, 1, 0, 1],
      [0, 1, 0, 1, 0, 1, 0, 1, 1], [0, 1, 0, 1, 0, 0, 1, 1, 1],
      [0, 1, 0, 0, 1, 1, 1, 1, 0], [0, 1, 0, 0, 1, 1, 1, 0, 1],
      [0, 1, 0, 0, 1, 1, 0, 1, 1], [0, 1, 0, 0, 1, 0, 1, 1, 1],
      [0, 1, 0, 0, 0, 1, 1, 1, 1], [0, 0, 1, 1, 1, 1, 1, 0, 0],
      [0, 0, 1, 1, 1, 1, 0, 1, 0], [0, 0, 1, 1, 1, 1, 0, 0, 1],
      [0, 0, 1, 1, 1, 0, 1, 1, 0], [0, 0, 1, 1, 1, 0, 1, 0, 1],
      [0, 0, 1, 1, 1, 0, 0, 1, 1], [0, 0, 1, 1, 0, 1, 1, 1, 0],
      [0, 0, 1, 1, 0, 1, 1, 0, 1], [0, 0, 1, 1, 0, 1, 0, 1, 1],
      [0, 0, 1, 1, 0, 0, 1, 1, 1], [0, 0, 1, 0, 1, 1, 1, 1, 0],
      [0, 0, 1, 0, 1, 1, 1, 0, 1], [0, 0, 1, 0, 1, 1, 0, 1, 1],
      [0, 0, 1, 0, 1, 0, 1, 1, 1], [0, 0, 1, 0, 0, 1, 1, 1, 1],
      [0, 0, 0, 1, 1, 1, 1, 1, 0], [0, 0, 0, 1, 1, 1, 1, 0, 1],
      [0, 0, 0, 1, 1, 1, 0, 1, 1], [0, 0, 0, 1, 1, 0, 1, 1, 1],
      [0, 0, 0, 1, 0, 1, 1, 1, 1], [0, 0, 0, 0, 1, 1, 1, 1, 1],
    ]

    for permutation in permutations {
      Validator(subject: permutation, separator: .element(0), maxSplits: 1)
        .validate()
    }
  }

  //===--------------------------------------------------------------------===//
  // Permutations of a sequence with six separators, so there can be multiple
  // adjacent separators at the beginning, middle, _and_ end.
  //===--------------------------------------------------------------------===//

  // More separators than elements.
  func testAllEEESSSSSS() {
    let permutations = [
      [1, 1, 1, 0, 0, 0, 0, 0, 0], [1, 1, 0, 1, 0, 0, 0, 0, 0],
      [1, 1, 0, 0, 1, 0, 0, 0, 0], [1, 1, 0, 0, 0, 1, 0, 0, 0],
      [1, 1, 0, 0, 0, 0, 1, 0, 0], [1, 1, 0, 0, 0, 0, 0, 1, 0],
      [1, 1, 0, 0, 0, 0, 0, 0, 1], [1, 0, 1, 1, 0, 0, 0, 0, 0],
      [1, 0, 1, 0, 1, 0, 0, 0, 0], [1, 0, 1, 0, 0, 1, 0, 0, 0],
      [1, 0, 1, 0, 0, 0, 1, 0, 0], [1, 0, 1, 0, 0, 0, 0, 1, 0],
      [1, 0, 1, 0, 0, 0, 0, 0, 1], [1, 0, 0, 1, 1, 0, 0, 0, 0],
      [1, 0, 0, 1, 0, 1, 0, 0, 0], [1, 0, 0, 1, 0, 0, 1, 0, 0],
      [1, 0, 0, 1, 0, 0, 0, 1, 0], [1, 0, 0, 1, 0, 0, 0, 0, 1],
      [1, 0, 0, 0, 1, 1, 0, 0, 0], [1, 0, 0, 0, 1, 0, 1, 0, 0],
      [1, 0, 0, 0, 1, 0, 0, 1, 0], [1, 0, 0, 0, 1, 0, 0, 0, 1],
      [1, 0, 0, 0, 0, 1, 1, 0, 0], [1, 0, 0, 0, 0, 1, 0, 1, 0],
      [1, 0, 0, 0, 0, 1, 0, 0, 1], [1, 0, 0, 0, 0, 0, 1, 1, 0],
      [1, 0, 0, 0, 0, 0, 1, 0, 1], [1, 0, 0, 0, 0, 0, 0, 1, 1],
      [0, 1, 1, 1, 0, 0, 0, 0, 0], [0, 1, 1, 0, 1, 0, 0, 0, 0],
      [0, 1, 1, 0, 0, 1, 0, 0, 0], [0, 1, 1, 0, 0, 0, 1, 0, 0],
      [0, 1, 1, 0, 0, 0, 0, 1, 0], [0, 1, 1, 0, 0, 0, 0, 0, 1],
      [0, 1, 0, 1, 1, 0, 0, 0, 0], [0, 1, 0, 1, 0, 1, 0, 0, 0],
      [0, 1, 0, 1, 0, 0, 1, 0, 0], [0, 1, 0, 1, 0, 0, 0, 1, 0],
      [0, 1, 0, 1, 0, 0, 0, 0, 1], [0, 1, 0, 0, 1, 1, 0, 0, 0],
      [0, 1, 0, 0, 1, 0, 1, 0, 0], [0, 1, 0, 0, 1, 0, 0, 1, 0],
      [0, 1, 0, 0, 1, 0, 0, 0, 1], [0, 1, 0, 0, 0, 1, 1, 0, 0],
      [0, 1, 0, 0, 0, 1, 0, 1, 0], [0, 1, 0, 0, 0, 1, 0, 0, 1],
      [0, 1, 0, 0, 0, 0, 1, 1, 0], [0, 1, 0, 0, 0, 0, 1, 0, 1],
      [0, 1, 0, 0, 0, 0, 0, 1, 1], [0, 0, 1, 1, 1, 0, 0, 0, 0],
      [0, 0, 1, 1, 0, 1, 0, 0, 0], [0, 0, 1, 1, 0, 0, 1, 0, 0],
      [0, 0, 1, 1, 0, 0, 0, 1, 0], [0, 0, 1, 1, 0, 0, 0, 0, 1],
      [0, 0, 1, 0, 1, 1, 0, 0, 0], [0, 0, 1, 0, 1, 0, 1, 0, 0],
      [0, 0, 1, 0, 1, 0, 0, 1, 0], [0, 0, 1, 0, 1, 0, 0, 0, 1],
      [0, 0, 1, 0, 0, 1, 1, 0, 0], [0, 0, 1, 0, 0, 1, 0, 1, 0],
      [0, 0, 1, 0, 0, 1, 0, 0, 1], [0, 0, 1, 0, 0, 0, 1, 1, 0],
      [0, 0, 1, 0, 0, 0, 1, 0, 1], [0, 0, 1, 0, 0, 0, 0, 1, 1],
      [0, 0, 0, 1, 1, 1, 0, 0, 0], [0, 0, 0, 1, 1, 0, 1, 0, 0],
      [0, 0, 0, 1, 1, 0, 0, 1, 0], [0, 0, 0, 1, 1, 0, 0, 0, 1],
      [0, 0, 0, 1, 0, 1, 1, 0, 0], [0, 0, 0, 1, 0, 1, 0, 1, 0],
      [0, 0, 0, 1, 0, 1, 0, 0, 1], [0, 0, 0, 1, 0, 0, 1, 1, 0],
      [0, 0, 0, 1, 0, 0, 1, 0, 1], [0, 0, 0, 1, 0, 0, 0, 1, 1],
      [0, 0, 0, 0, 1, 1, 1, 0, 0], [0, 0, 0, 0, 1, 1, 0, 1, 0],
      [0, 0, 0, 0, 1, 1, 0, 0, 1], [0, 0, 0, 0, 1, 0, 1, 1, 0],
      [0, 0, 0, 0, 1, 0, 1, 0, 1], [0, 0, 0, 0, 1, 0, 0, 1, 1],
      [0, 0, 0, 0, 0, 1, 1, 1, 0], [0, 0, 0, 0, 0, 1, 1, 0, 1],
      [0, 0, 0, 0, 0, 1, 0, 1, 1], [0, 0, 0, 0, 0, 0, 1, 1, 1],
    ]

    for permutation in permutations {
      Validator(subject: permutation, separator: .element(0), maxSplits: 1)
        .validate()
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
  /// Tests all combinations of default and provided `maxSplit` arguments and
  /// default (true) and explicit false for `omittingEmptySubsequences`.
  ///
  /// - Parameters:
  ///  - subject: The collection whose splits will be validated.
  ///  - separator: The element of the collection--or a predicate function to
  ///    determine the element--on which to split.
  ///  - maxSplits: The value to pass for `maxSplits` during validation. The
  ///    default value is also validated.
  fileprivate struct Validator<C: Collection>
  where C.Element: Equatable, C.SubSequence: Equatable {
    enum Separator {
      case element(C.Element)
      case closure((C.Element) -> Bool)
    }

    let subject: C
    let separator: Separator
    let maxSplits: Int

    func validate() {
      _validateAsSequence(AnySequence(subject))
      _validateAsCollection(subject)
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

    private func _validateAsSequence<T: Sequence>(_ s: T)
    where T.Element == C.Element {
      // Default max splits, omitting empty sequences
      switch separator {
      case let .element(element):
        let expected = s.split(separator: element).map { Array($0) }
        let actual = s.lazy.split(separator: element)
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
        XCTAssertEqualSequences(
          expected,
          actual,
          failureMessage(
            actual: actual, expected: expected, maxSplits: .defaultValue,
            omittingEmptySubsequences: .defaultValue)
        )
      }

      // Provided max splits, omitting empty sequences
      switch separator {
      case let .element(element):
        let expected = s.split(
          separator: element,
          maxSplits: maxSplits
        ).map { Array($0) }
        let actual = s.lazy.split(
          separator: element,
          maxSplits: maxSplits
        )
        XCTAssertEqualSequences(
          expected,
          actual,
          failureMessage(
            actual: actual, expected: expected, maxSplits: .provided(maxSplits),
            omittingEmptySubsequences: .defaultValue)
        )
      case let .closure(closure):
        let expected = s.split(
          maxSplits: maxSplits,
          whereSeparator: closure
        ).map { Array($0) }
        let actual = s.lazy.split(
          maxSplits: maxSplits,
          whereSeparator: closure
        )
        XCTAssertEqualSequences(
          expected,
          actual,
          failureMessage(
            actual: actual, expected: expected, maxSplits: .provided(maxSplits),
            omittingEmptySubsequences: .defaultValue)
        )
      }

      // Default max splits, including empty sequences
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
        XCTAssertEqualSequences(
          expected,
          actual,
          failureMessage(
            actual: actual, expected: expected, maxSplits: .defaultValue,
            omittingEmptySubsequences: .provided(false))
        )
      }

      // Provided max splits, including empty sequences
      switch separator {
      case let .element(element):
        let expected = s.split(
          separator: element,
          maxSplits: maxSplits,
          omittingEmptySubsequences: false
        ).map { Array($0) }
        let actual = s.lazy.split(
          separator: element,
          maxSplits: maxSplits,
          omittingEmptySubsequences: false
        )
        XCTAssertEqualSequences(
          expected,
          actual,
          failureMessage(
            actual: actual, expected: expected, maxSplits: .provided(maxSplits),
            omittingEmptySubsequences: .provided(false))
        )
      case let .closure(closure):
        let expected = s.split(
          maxSplits: maxSplits,
          omittingEmptySubsequences: false,
          whereSeparator: closure
        ).map { Array($0) }
        let actual = s.lazy.split(
          maxSplits: maxSplits,
          omittingEmptySubsequences: false,
          whereSeparator: closure
        )
        XCTAssertEqualSequences(
          expected,
          actual,
          failureMessage(
            actual: actual, expected: expected, maxSplits: .provided(maxSplits),
            omittingEmptySubsequences: .provided(false))
        )
      }
    }

    private func _validateAsCollection(_ c: C) {
      // Default max splits, omitting empty sequences
      switch separator {
      case let .element(element):
        let expected = c.split(separator: element)
        let actual = c.lazy.split(separator: element)
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
        XCTAssertEqualSequences(
          expected,
          actual,
          failureMessage(
            actual: actual, expected: expected, maxSplits: .defaultValue,
            omittingEmptySubsequences: .defaultValue)
        )
      }

      // Provided max splits, omitting empty sequences
      switch separator {
      case let .element(element):
        let expected = c.split(
          separator: element,
          maxSplits: maxSplits
        )
        let actual = c.lazy.split(
          separator: element,
          maxSplits: maxSplits
        )
        XCTAssertEqualSequences(
          expected,
          actual,
          failureMessage(
            actual: actual, expected: expected, maxSplits: .provided(maxSplits),
            omittingEmptySubsequences: .defaultValue)
        )
      case let .closure(closure):
        let expected = c.split(
          maxSplits: maxSplits,
          whereSeparator: closure
        )
        let actual = c.lazy.split(
          maxSplits: maxSplits,
          whereSeparator: closure
        )
        XCTAssertEqualSequences(
          expected,
          actual,
          failureMessage(
            actual: actual, expected: expected, maxSplits: .provided(maxSplits),
            omittingEmptySubsequences: .defaultValue)
        )
      }

      // Default max splits, including empty sequences
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
        XCTAssertEqualSequences(
          expected,
          actual,
          failureMessage(
            actual: actual, expected: expected, maxSplits: .defaultValue,
            omittingEmptySubsequences: .provided(false))
        )
      }

      // Provided max splits, including empty sequences
      switch separator {
      case let .element(element):
        let expected = c.split(
          separator: element,
          maxSplits: maxSplits,
          omittingEmptySubsequences: false
        )
        let actual = c.lazy.split(
          separator: element,
          maxSplits: maxSplits,
          omittingEmptySubsequences: false
        )
        XCTAssertEqualSequences(
          expected,
          actual,
          failureMessage(
            actual: actual, expected: expected, maxSplits: .provided(maxSplits),
            omittingEmptySubsequences: .provided(false))
        )
      case let .closure(closure):
        let expected = c.split(
          maxSplits: maxSplits,
          omittingEmptySubsequences: false,
          whereSeparator: closure
        )
        let actual = c.lazy.split(
          maxSplits: maxSplits,
          omittingEmptySubsequences: false,
          whereSeparator: closure
        )
        XCTAssertEqualSequences(
          expected,
          actual,
          failureMessage(
            actual: actual, expected: expected, maxSplits: .provided(maxSplits),
            omittingEmptySubsequences: .provided(false))
        )
      }
    }
  }
}
