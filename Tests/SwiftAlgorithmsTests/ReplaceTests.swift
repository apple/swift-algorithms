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

final class ReplaceTests: XCTestCase {
  func test() {
    XCTAssertEqual(
      "ababab".replacingOccurrences(of: "ab", with: "AB"),
      "ABABAB")
    XCTAssertEqual(
      "ababab".replacingOccurrences(of: "ab", with: "AB", maxReplacements: 0),
      "ababab")
    XCTAssertEqual(
      "ababab".replacingOccurrences(of: "ab", with: "AB", maxReplacements: 1),
      "ABabab")
    XCTAssertEqual(
      "ababab".replacingOccurrences(of: "ab", with: "AB", maxReplacements: 2),
      "ABABab")
    XCTAssertEqual(
      "ababab".replacingOccurrences(of: "ab", with: "AB", maxReplacements: 3),
      "ABABAB")
    XCTAssertEqual(
      "ababab".replacingOccurrences(of: "ab", with: "AB", maxReplacements: 4),
      "ABABAB")
    
    XCTAssertEqual("aaaaa".replacingOccurrences(of: "aa", with: "AA"), "AAAAa")
    XCTAssertEqual("abc".replacingOccurrences(of: "X", with: "Y"), "abc")
    XCTAssertEqual("".replacingOccurrences(of: "abc", with: "ABC"), "")
  }
}
