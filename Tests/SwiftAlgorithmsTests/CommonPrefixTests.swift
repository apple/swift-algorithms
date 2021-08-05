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

final class CommonPrefixTests: XCTestCase {
  func testCommonPrefix() {
    func testCommonPrefix(of a: String, and b: String, equals c: String) {
      // eager sequence
      XCTAssertEqualSequences(AnySequence(a).commonPrefix(with: AnySequence(b)), c)
      
      // lazy sequence
      XCTAssertEqualSequences(AnySequence(a).lazy.commonPrefix(with: AnySequence(b)), c)
      
      // eager collection
      XCTAssertEqualSequences(a.commonPrefix(with: b), c)
      
      // lazy collection
      XCTAssertEqualSequences(a.lazy.commonPrefix(with: b), c)
    }
    
    testCommonPrefix(of: "abcdef", and: "abcxyz", equals: "abc")
    testCommonPrefix(of: "abc",    and: "abcxyz", equals: "abc")
    testCommonPrefix(of: "abcdef", and: "abc",    equals: "abc")
    testCommonPrefix(of: "abc",    and: "abc",    equals: "abc")
    
    testCommonPrefix(of: "abc", and: "xyz", equals: "")
    testCommonPrefix(of: "",    and: "xyz", equals: "")
    testCommonPrefix(of: "abc", and: "",    equals: "")
    testCommonPrefix(of: "",    and: "",    equals: "")
    
    XCTAssertLazySequence(
      AnySequence([1, 2, 3]).lazy.commonPrefix(with: AnySequence([4, 5, 6])))
    XCTAssertLazyCollection([1, 2, 3].lazy.commonPrefix(with: [4, 5, 6]))
  }
  
  func testCommonPrefixIteratorKeepsReturningNil() {
    var iter = AnySequence("12A34").commonPrefix(with: "12B34").makeIterator()
    XCTAssertEqual(iter.next(), "1")
    XCTAssertEqual(iter.next(), "2")
    XCTAssertEqual(iter.next(), nil)
    XCTAssertEqual(iter.next(), nil)
    XCTAssertEqual(iter.next(), nil)
  }
  
  func testCommonSuffix() {
    func testCommonSuffix(of a: String, and b: String, equals c: String) {
      XCTAssertEqualSequences(a.commonSuffix(with: b, by: ==), c)
    }
    
    testCommonSuffix(of: "abcxyz", and: "uvwxyz", equals: "xyz")
    testCommonSuffix(of:    "xyz", and: "uvwxyz", equals: "xyz")
    testCommonSuffix(of: "abcxyz", and:    "xyz", equals: "xyz")
    testCommonSuffix(of:    "xyz", and:    "xyz", equals: "xyz")
    
    testCommonSuffix(of: "abc", and: "xyz", equals: "")
    testCommonSuffix(of: "",    and: "xyz", equals: "")
    testCommonSuffix(of: "abc", and: "",    equals: "")
    testCommonSuffix(of: "",    and: "",    equals: "")
    
    XCTAssertLazySequence([1, 2, 3].lazy.commonSuffix(with: [4, 5, 6]))
  }
  
  func testEndOfCommonPrefix() {
    XCTAssert([1, 2, 3].endOfCommonPrefix(with: [1, 2, 3]) == (3, 3))
    XCTAssert([1, 2, 3].endOfCommonPrefix(with: [4, 5]) == (0, 0))
    XCTAssert([1, 2, 3].endOfCommonPrefix(with: [1, 2]) == (2, 2))
    XCTAssert([1, 2, 3].endOfCommonPrefix(with: [1, 2, 4]) == (2, 2))
    XCTAssert([1, 2].endOfCommonPrefix(with: [1, 2, 3]) == (2, 2))
  }
  
  func testStartOfCommonSuffix() {
    XCTAssert([1, 2, 3].startOfCommonSuffix(with: [1, 2, 3]) == (0, 0))
    XCTAssert([1, 2, 3].startOfCommonSuffix(with: [4, 5]) == (3, 2))
    XCTAssert([1, 2, 3].startOfCommonSuffix(with: [2, 3]) == (1, 0))
    XCTAssert([0, 1, 2, 3].startOfCommonSuffix(with: [0, 2, 3]) == (2, 1))
    XCTAssert([2, 3].startOfCommonSuffix(with: [1, 2, 3]) == (0, 1))
  }
}
