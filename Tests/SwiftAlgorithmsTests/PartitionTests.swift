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
  
  func testStablePartitionWithSubrange() {
    for length in 10...20 {
      let a = Array(0..<length)
      for i in 0..<length {
        for j in 0...i {
          var b = a
          let partitionRange = j..<i
          let condition = { $0 < i - 1 }
          let p = b.stablePartition(subrange: partitionRange, by: condition)

          XCTAssertEqual(p, partitionRange.count == 0 ? j : j + 1)
          XCTAssertEqualSequences(b[partitionRange.lowerBound..<p], a[partitionRange].filter { !condition($0) })
          XCTAssertEqualSequences(b[p..<partitionRange.upperBound], a[partitionRange].filter(condition))
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
  
  func testPartitionWithSubrangeBidirectionalCollection() {
    for length in 10...20 {
      let a = Array(0..<length)
      for i in 0..<length {
        for j in 0...i {
          var b = a
          let partitionRange = j..<i
          let condition = { $0 < i - 1 }
          let p = b.partition(subrange: partitionRange, by: condition)
          
          XCTAssertEqual(p, partitionRange.count == 0 ? j : j + 1)
          XCTAssertEqualSequences(b[partitionRange.lowerBound..<p], a[partitionRange].filter { !condition($0) })
          XCTAssertUnorderedEqualSequences(b[p..<partitionRange.upperBound], a[partitionRange].filter(condition))
        }
      }
    }
  }

  func testPartitionWithSubrangeMutableCollection() {
    for length in 10...20 {
      let a = Array(0..<length)
      for i in 0..<length {
        for j in 0...i {
          var b = a.eraseToAnyMutableCollection()
          var bdc = a
          let partitionRange = j..<i
          let condition = { $0 < i - 1 }
          let p = b.partition(subrange: partitionRange, by: condition)
          let bdcp = bdc.partition(subrange: partitionRange, by: condition)
          
          XCTAssertEqual(p, partitionRange.count == 0 ? j : j + 1)
          XCTAssertEqualSequences(b[partitionRange.lowerBound..<p], a[partitionRange].filter { !condition($0) })
          XCTAssertUnorderedEqualSequences(b[p..<partitionRange.upperBound], a[partitionRange].filter(condition))
          
          // Must produce the same result as the `BidirectionalCollection` specialized overload.
          XCTAssertEqualSequences(b[partitionRange.lowerBound..<p], bdc[partitionRange.lowerBound..<bdcp])
          XCTAssertUnorderedEqualSequences(b[p..<partitionRange.upperBound], bdc[bdcp..<partitionRange.upperBound])
        }
      }
    }
  }
}
