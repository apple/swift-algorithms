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

final class PartitionTests: XCTestCase {
  func testStablePartition() {
    for l in 0..<13 {
      let a = Array(0..<l)

      for p in a.startIndex...a.endIndex {
        let prefix = a[..<p]
        for q in p...l {
          let suffix = a[q...]

          let subrange = a[p..<q]

          for modulus in 1...5 {
            let f = { $0 % modulus != 0 }
            let notf = { !f($0) }

            var b = a
            var r = b[p..<q].stablePartition(by: f)
            XCTAssertEqualSequences(b[..<p], prefix)
            XCTAssertEqualSequences(b[q...], suffix)
            XCTAssertEqualSequences(b[p..<r], subrange.filter(notf))
            XCTAssertEqualSequences(b[r..<q], subrange.filter(f))

            b = a
            r = b[p..<q].stablePartition(by: notf)
            XCTAssertEqualSequences(b[..<p], prefix)
            XCTAssertEqualSequences(b[q...], suffix)
            XCTAssertEqualSequences(b[p..<r], subrange.filter(f))
            XCTAssertEqualSequences(b[r..<q], subrange.filter(notf))
          }
        }

        for modulus in 1...5 {
          let f = { $0 % modulus != 0 }
          let notf = { !f($0) }
          var b = a
          var r = b.stablePartition(by: f)
          XCTAssertEqualSequences(b[..<r], a.filter(notf))
          XCTAssertEqualSequences(b[r...], a.filter(f))

          b = a
          r = b.stablePartition(by: notf)
          XCTAssertEqualSequences(b[..<r], a.filter(f))
          XCTAssertEqualSequences(b[r...], a.filter(notf))
        }
      }
    }
  }
  
  func testPartitioningIndex() {
    for i in 0..<7 {
      for j in i..<11 {
        for k in i...j {
          let p = (i..<j).partitioningIndex { $0 >= k }
          XCTAssertGreaterThanOrEqual(p, i)
          XCTAssertLessThanOrEqual(p, j)
          XCTAssertEqual(p, k)
        }
      }
    }
  }
}
