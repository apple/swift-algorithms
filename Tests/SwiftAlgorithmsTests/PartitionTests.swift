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
  
  func testPartitioningIndexWithEmptyInput() {
    let input: [Int] = []
    
    let a = input.partitioningIndex(where: { _ in return true })
    XCTAssertEqual(a, input.startIndex)
    
    let b = input.partitioningIndex(where: { _ in return false })
    XCTAssertEqual(b, input.endIndex)
  }
  
  func testPartitioningIndexWithOneEmptyPartition() {
    let input: Range<Int> = (0 ..< 10)
    
    let a = input.partitioningIndex(where: { $0 > 10 })
    XCTAssertEqual(a, input.endIndex)
    
    let b = input.partitioningIndex(where: { $0 >= 0 })
    XCTAssertEqual(b, input.startIndex)
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
  
  func testPartitionedWithEmptyInput() {
    let input: [Int] = []
    
    let s0 = input.partitioned(by: { _ in return true })
    
    XCTAssertTrue(s0.0.isEmpty)
    XCTAssertTrue(s0.1.isEmpty)
  }
  
  /// Test the example given in the `partitioned(by:)` documentation
  func testPartitionedExample() throws {
    let cast = ["Vivien", "Marlon", "Kim", "Karl"]
    let (longNames, shortNames) = cast.partitioned(by: { $0.count < 5 })
    XCTAssertEqual(longNames, ["Vivien", "Marlon"])
    XCTAssertEqual(shortNames, ["Kim", "Karl"])
  }
  
  func testPartitionedWithPredicate() throws {
    let s0 = ["A", "B", "C", "D"].partitioned(by: { $0 == $0.lowercased() })
    let s1 = ["a", "B", "C", "D"].partitioned(by: { $0 == $0.lowercased() })
    let s2 = ["a", "B", "c", "D"].partitioned(by: { $0 == $0.lowercased() })
    let s3 = ["a", "B", "c", "d"].partitioned(by: { $0 == $0.lowercased() })
    
    XCTAssertEqual(s0.0, ["A", "B", "C", "D"])
    XCTAssertEqual(s0.1, [])
    
    XCTAssertEqual(s1.0, ["B", "C", "D"])
    XCTAssertEqual(s1.1, ["a"])
    
    XCTAssertEqual(s2.0, ["B", "D"])
    XCTAssertEqual(s2.1, ["a", "c"])
    
    XCTAssertEqual(s3.0, ["B"])
    XCTAssertEqual(s3.1, ["a", "c", "d"])
  }
}
