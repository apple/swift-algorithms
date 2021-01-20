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

final class SuffixTests: XCTestCase {
  
  func testSuffix() {
    let a = 0...10
    XCTAssertEqualSequences(a.suffix(while: { $0 > 5 }), (6...10))
}
