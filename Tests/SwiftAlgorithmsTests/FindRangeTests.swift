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

extension Collection {
  fileprivate func range(at offsets: Range<Int>) -> Range<Index> {
    let low = index(startIndex, offsetBy: offsets.lowerBound)
    let high = index(low, offsetBy: offsets.count)
    return low..<high
  }
}

fileprivate let input = "abababaabaaba"

final class FindTests: XCTestCase {
  func testFirstRangeOf() {
    XCTAssertNil("".firstRange(of: "input"))
    XCTAssertNil("".firstRange(of: ""))
    XCTAssertNil(input.firstRange(of: ""))
    
    XCTAssertEqual(input.firstRange(of: "ababa"), input.range(at: 0..<5))
    XCTAssertEqual(input.firstRange(of: "baba"), input.range(at: 1..<5))
    XCTAssertEqual(input.firstRange(of: "abaa"), input.range(at: 4..<8))
    XCTAssertEqual(input.firstRange(of: "aabaaba"), input.range(at: 6..<13))
    XCTAssertEqual(input.firstRange(of: input), input.range(at: 0..<13))
    XCTAssertNil(input.firstRange(of: "aabaabaa"))
    XCTAssertNil(input.firstRange(of: "abababab"))
    
    XCTAssertEqual(input.dropFirst().firstRange(of: "ababa"), input.range(at: 2..<7))
    XCTAssertEqual(input.dropFirst(5).firstRange(of: "abaa"), input.range(at: 7..<11))
    XCTAssertNil(input.dropFirst(7).firstRange(of: "aabaaba"))
  }
  
  func testLastRangeOf() {
    XCTAssertNil("".lastRange(of: "a"))
    XCTAssertNil("".lastRange(of: ""))
    XCTAssertNil(input.lastRange(of: ""))

    XCTAssertEqual(input.lastRange(of: "ababa"), input.range(at: 2..<7))
    XCTAssertEqual(input.lastRange(of: "baba"), input.range(at: 3..<7))
    XCTAssertEqual(input.lastRange(of: "abaa"), input.range(at: 7..<11))
    XCTAssertEqual(input.lastRange(of: "aabaaba"), input.range(at: 6..<13))
    XCTAssertEqual(input.lastRange(of: input), input.range(at: 0..<13))
    XCTAssertNil(input.lastRange(of: "aabaabaa"))
    XCTAssertNil(input.lastRange(of: "abababab"))
    
    XCTAssertEqual(input.dropLast(7).lastRange(of: "ababa"), input.range(at: 0..<5))
    XCTAssertEqual(input.dropLast(3).lastRange(of: "abaa"), input.range(at: 4..<8))
    XCTAssertNil(input.dropLast(6).lastRange(of: "abababaa"))
  }
  
  func testAllRangesOf() {
    XCTAssertEqual("".allRanges(of: "abc").count, 0)
    XCTAssertEqual("".allRanges(of: "").count, 0)
    XCTAssertEqual(input.allRanges(of: "abc").count, 0)
    XCTAssertEqual(input.allRanges(of: "").count, 0)

    XCTAssertEqual(input.allRanges(of: "ab").count, 5)
    XCTAssertEqual(input.allRanges(of: "ba").count, 5)
    XCTAssertEqual(input.allRanges(of: "aba").count, 5)

    XCTAssertEqualSequences(
      input.allRanges(of: "ababa"),
      [input.range(at: 0..<5), input.range(at: 2..<7)])
    XCTAssertEqual(input.allRanges(of: "ababa").last, input.range(at: 2..<7))
    XCTAssertEqualSequences(
      input.allRanges(of: "aaba"),
      [input.range(at: 6..<10), input.range(at: 9..<13)])
    XCTAssertEqualSequences(
      input.allRanges(of: "aaba").reversed(),
      [input.range(at: 9..<13), input.range(at: 6..<10)])
    XCTAssertEqual(input.allRanges(of: "aaba").last, input.range(at: 9..<13))
  }
  
  func testCollectionConformance() {
    let matches = input.allRanges(of: "ab")
    validateIndexTraversals(matches)
  }
}
