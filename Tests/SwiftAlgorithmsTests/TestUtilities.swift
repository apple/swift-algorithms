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

extension Sequence {
  func isSorted(by f: (Element, Element) -> Bool) -> Bool {
    zip(self, self.dropFirst()).allSatisfy { !f($1, $0) }
  }
}

extension Sequence where Element: Comparable {
  func isSorted() -> Bool {
    isSorted(by: <)
  }
}

extension Numeric {
  func factorial() -> Self {
    guard self != 0 else { return 1 }
    return self * (self - 1).factorial()
  }
}

struct SplitMix64: RandomNumberGenerator {
  private var state: UInt64
  
  init(seed: UInt64) {
    self.state = seed
  }
  
  mutating func next() -> UInt64 {
    self.state &+= 0x9e3779b97f4a7c15
    var z: UInt64 = self.state
    z = (z ^ (z &>> 30)) &* 0xbf58476d1ce4e5b9
    z = (z ^ (z &>> 27)) &* 0x94d049bb133111eb
    return z ^ (z &>> 31)
  }
}

func XCTAssertEqualSequences<S1: Sequence, S2: Sequence>(
  _ expression1: @autoclosure () throws -> S1,
  _ expression2: @autoclosure () throws -> S2,
  _ message: @autoclosure () -> String = "",
  file: StaticString = #file, line: UInt = #line
) rethrows where S1.Element: Equatable, S1.Element == S2.Element {
  try XCTAssert(expression1().elementsEqual(expression2()), message(), file: file, line: line)
}

func XCTAssertEqualSequences<S1: Sequence, S2: Sequence>(
  _ expression1: @autoclosure () throws -> S1,
  _ expression2: @autoclosure () throws -> S2,
  by areEquivalent: (S1.Element, S1.Element) -> Bool,
  _ message: @autoclosure () -> String = "",
  file: StaticString = #file, line: UInt = #line
) rethrows where S1.Element == S2.Element {
  try XCTAssert(expression1().elementsEqual(expression2(), by: areEquivalent), message(), file: file, line: line)
}

