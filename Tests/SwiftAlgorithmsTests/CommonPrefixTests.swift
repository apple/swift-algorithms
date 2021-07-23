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
      XCTAssertEqualSequences(AnySequence(a).commonPrefix(with: AnySequence(b), by: ==), c)
      
      // lazy sequence
      XCTAssertEqualSequences(AnySequence(a).lazy.commonPrefix(with: AnySequence(b), by: ==), c)
      
      // eager collection
      XCTAssertEqualSequences(a.commonPrefix(with: b, by: ==), c)
      
      // lazy collection
      XCTAssertEqualSequences(a.lazy.commonPrefix(with: b, by: ==), c)
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
}
