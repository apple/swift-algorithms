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

final class SplitTests: XCTestCase {
  func test() {
    XCTAssertEqual(
      "foo, bar, baz".split(separator: ", ", by: ==),
      ["foo", "bar", "baz"])
    XCTAssertEqual(
      ", foo, bar, baz, ".split(separator: ", ", by: ==),
      ["foo", "bar", "baz"])
    XCTAssertEqual(
      ", foo, bar, baz, ".split(separator: ", ", maxSplits: 2, by: ==),
      ["foo", "bar", "baz, "])
    XCTAssertEqual(
      ", foo, bar, baz, ".split(separator: ", ", maxSplits: 1, by: ==),
      ["foo", "bar, baz, "])
    XCTAssertEqual(
      ", foo, bar, baz, ".split(separator: ", ", maxSplits: 0, by: ==),
      [", foo, bar, baz, "])

    XCTAssertEqual(
      ", foo, bar, baz, ".split(separator: ", ", omittingEmptySubsequences: false, by: ==),
      ["", "foo", "bar", "baz", ""])
    XCTAssertEqual(
      ", foo, bar, baz, ".split(separator: ", ", maxSplits: 4, omittingEmptySubsequences: false, by: ==),
      ["", "foo", "bar", "baz", ""])
    XCTAssertEqual(
      ", foo, bar, baz, ".split(separator: ", ", maxSplits: 3, omittingEmptySubsequences: false, by: ==),
      ["", "foo", "bar", "baz, "])
    XCTAssertEqual(
      ", foo, bar, baz, ".split(separator: ", ", maxSplits: 2, omittingEmptySubsequences: false, by: ==),
      ["", "foo", "bar, baz, "])
    XCTAssertEqual(
      ", foo, bar, baz, ".split(separator: ", ", maxSplits: 1, omittingEmptySubsequences: false, by: ==),
      ["", "foo, bar, baz, "])
    XCTAssertEqual(
      ", foo, bar, baz, ".split(separator: ", ", maxSplits: 0, omittingEmptySubsequences: false, by: ==),
      [", foo, bar, baz, "])
  }
  
  func testLazy() {
    XCTAssertEqualSequences(
      "foo, bar, baz".split(separator: ", "),
      ["foo", "bar", "baz"])
    XCTAssertEqualSequences(
      ", foo, bar, baz, ".split(separator: ", "),
      ["foo", "bar", "baz"])
    XCTAssertEqualSequences(
      ", foo, bar, baz, ".split(separator: ", ", maxSplits: 2),
      ["foo", "bar", "baz, "])
    XCTAssertEqualSequences(
      ", foo, bar, baz, ".split(separator: ", ", maxSplits: 1),
      ["foo", "bar, baz, "])
    XCTAssertEqualSequences(
      ", foo, bar, baz, ".split(separator: ", ", maxSplits: 0),
      [", foo, bar, baz, "])
    
    XCTAssertEqualSequences(
      ", foo, bar, baz, ".split(separator: ", ", omittingEmptySubsequences: false),
      ["", "foo", "bar", "baz", ""])
    XCTAssertEqualSequences(
      ", foo, bar, baz, ".split(separator: ", ", maxSplits: 4, omittingEmptySubsequences: false),
      ["", "foo", "bar", "baz", ""])
    XCTAssertEqualSequences(
      ", foo, bar, baz, ".split(separator: ", ", maxSplits: 3, omittingEmptySubsequences: false),
      ["", "foo", "bar", "baz, "])
    XCTAssertEqualSequences(
      ", foo, bar, baz, ".split(separator: ", ", maxSplits: 2, omittingEmptySubsequences: false),
      ["", "foo", "bar, baz, "])
    XCTAssertEqualSequences(
      ", foo, bar, baz, ".split(separator: ", ", maxSplits: 1, omittingEmptySubsequences: false),
      ["", "foo, bar, baz, "])
    XCTAssertEqualSequences(
      ", foo, bar, baz, ".split(separator: ", ", maxSplits: 0, omittingEmptySubsequences: false),
      [", foo, bar, baz, "])
  }
}
