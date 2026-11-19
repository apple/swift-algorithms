//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift Algorithms open source project
//
// Copyright (c) 2023 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

import XCTest
import Algorithms

final class PartitionMapTests: XCTestCase {
  func testPartitionMap2WithEmptyInput() {
    let input: [Int] = []
    
    let (first, second) = input.partitionMap { _ -> PartitionMapResult2<Int, String> in
      .first(0)
    }
    
    XCTAssertTrue(first.isEmpty)
    XCTAssertTrue(second.isEmpty)
  }
  
  func testPartitionMap3WithEmptyInput() {
    let input: [Int] = []
    
    let (first, second, third) = input.partitionMap { _ -> PartitionMapResult3<Int, String, Data> in
      .first(0)
    }
    
    XCTAssertTrue(first.isEmpty)
    XCTAssertTrue(second.isEmpty)
    XCTAssertTrue(third.isEmpty)
  }
  
  func testPartitionMap2Example() throws {
    let nanString = String(describing: Double.nan)
    let numericStrings = ["", "^", "-1", "0", "1", "-1.5", "1.5", nanString]
    
    let (doubles, unrepresentable) = numericStrings
      .partitionMap { string -> PartitionMapResult2<Double, String> in
        if let double = Double(string) {
          return .first(double)
        } else {
          return .second(string)
        }
    }
    
    XCTAssertEqual(doubles.map(String.init(describing:)), ["-1.0", "0.0", "1.0", "-1.5", "1.5", nanString])
    XCTAssertEqual(unrepresentable, ["", "^"])
  }
  
  func testPartitionMap3Example() throws {
    let nanString = String(describing: Double.nan)
    let numericStrings = ["", "^", "-1", "0", "1", "-1.5", "1.5", nanString]
    
    let (integers, doubles, unrepresentable) = numericStrings
      .partitionMap { string -> PartitionMapResult3<Int, Double, String> in
        if let integer = Int(string) {
          return .first(integer)
        } else if let double = Double(string) {
          return .second(double)
        } else {
          return .third(string)
        }
    }
    
    XCTAssertEqual(integers, [-1, 0, 1])
    XCTAssertEqual(doubles.map(String.init(describing:)), ["-1.5", "1.5", nanString])
    XCTAssertEqual(unrepresentable, ["", "^"])
  }
  
    
  func testPartitionMap2WithPredicate() throws {
    let predicate: (Int) throws -> PartitionMapResult2<Int8, UInt8> = { number -> PartitionMapResult2<Int8, UInt8> in
      if let uint = UInt8(exactly: number) {
        return .second(uint)
      } else if let int = Int8(exactly: number) {
        return .first(int)
      } else {
        throw TestError()
      }
    }
    
    let s0 = try [1, 2, 3, 4].partitionMap(predicate)
    let s1 = try [-1, 2, 3, 4].partitionMap(predicate)
    let s2 = try [-1, 2, -3, 4].partitionMap(predicate)
    let s3 = try [-1, 2, -3, -4].partitionMap(predicate)
    
    XCTAssertThrowsError(try [256].partitionMap(predicate))
    XCTAssertThrowsError(try [-129].partitionMap(predicate))
    
    XCTAssertEqual(s0.0, [])
    XCTAssertEqual(s0.1, [1, 2, 3, 4])
    
    XCTAssertEqual(s1.0, [-1])
    XCTAssertEqual(s1.1, [2, 3, 4])
    
    XCTAssertEqual(s2.0, [-1, -3])
    XCTAssertEqual(s2.1, [2, 4])
    
    XCTAssertEqual(s3.0, [-1, -3, -4])
    XCTAssertEqual(s3.1, [2])
  }
  
  func testPartitionMap3WithPredicate() throws {
    let predicate: (Int) throws -> PartitionMapResult3<Int8, UInt8, Void> = { number -> PartitionMapResult3<Int8, UInt8, Void> in
      if number == 0 {
        return .third(Void())
      } else if let uint = UInt8(exactly: number) {
        return .second(uint)
      } else if let int = Int8(exactly: number) {
        return .first(int)
      } else {
        throw TestError()
      }
    }
    
    let s0 = try [0, 1, 2, 3, 4].partitionMap(predicate)
    let s1 = try [0, 0, -1, 2, 3, 4].partitionMap(predicate)
    let s2 = try [0, 0, -1, 2, -3, 4].partitionMap(predicate)
    let s3 = try [0, -1, 2, -3, -4].partitionMap(predicate)
    
    XCTAssertThrowsError(try [256].partitionMap(predicate))
    XCTAssertThrowsError(try [-129].partitionMap(predicate))
    
    XCTAssertEqual(s0.0, [])
    XCTAssertEqual(s0.1, [1, 2, 3, 4])
    XCTAssertEqual(s0.2.count, 1)
    
    XCTAssertEqual(s1.0, [-1])
    XCTAssertEqual(s1.1, [2, 3, 4])
    XCTAssertEqual(s1.2.count, 2)
    
    XCTAssertEqual(s2.0, [-1, -3])
    XCTAssertEqual(s2.1, [2, 4])
    XCTAssertEqual(s2.2.count, 2)
    
    XCTAssertEqual(s3.0, [-1, -3, -4])
    XCTAssertEqual(s3.1, [2])
    XCTAssertEqual(s3.2.count, 1)
  }
  
  private struct TestError: Error {}
}
