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

final class ContainsCountsWhereTests: XCTestCase {
  func testCountInRangeDocumentationExample() {
    let animals = [
      "mountain lion",
      "lion",
      "snow leopard",
      "leopard",
      "tiger",
      "panther",
      "jaguar"
    ]
    XCTAssertTrue(animals.contains(countIn: 2..., where: { $0.contains("lion") }))
    
    XCTAssertTrue(animals.contains(atLeast: 2, where: { $0.contains("lion") }))
    XCTAssertTrue(animals.contains(exactly: 2, where: { $0.contains("lion") }))
    XCTAssertTrue(animals.contains(lessThanOrEqualTo: 2, where: { $0.contains("lion") }))
    XCTAssertTrue(animals.contains(lessThan: 3, where: { $0.contains("lion") }))
  }
  
  func testCountInRange() {
    let vowels = Set<String>(["A", "E", "I", "O", "U", "Y"])
    
    let a = ["A", "B", "C", "D", "E", "F", "G", "I"]
    XCTAssertTrue(a.contains(countIn: 2...3, where: { vowels.contains($0) }))
    XCTAssertTrue(a.contains(countIn: ...3, where: { vowels.contains($0) }))
    XCTAssertTrue(a.contains(countIn: ..<4, where: { vowels.contains($0) }))
    XCTAssertTrue(a.contains(countIn: 3..., where: { vowels.contains($0) }))
    
    let b = ["A", "B", "C"]
    XCTAssertFalse(b.contains(countIn: 2...3, where: { vowels.contains($0) }))
    XCTAssertFalse(b.contains(countIn: 2..., where: { vowels.contains($0) }))
    XCTAssertTrue(b.contains(countIn: ...3, where: { vowels.contains($0) }))
    XCTAssertTrue(b.contains(countIn: ...1, where: { vowels.contains($0) }))
  }
  
  func testCountIsExactlyDocumentationExample() {
    let animals = [
      "bear",
      "fox",
      "bear",
      "squirrel",
      "bear",
      "moose",
      "squirrel",
      "elk"
    ]
    XCTAssertFalse(animals.contains(exactly: 2, where: { $0 == "bear" }))
  }
  
  func testCountIsExactly() {
    let vowels = Set<String>(["A", "E", "I", "O", "U", "Y"])
    
    let a = ["A", "", "A", "B", "C", "D", "E", "F", "G", "I"]
    XCTAssertTrue(a.contains(exactly: 1, where: { $0 == "" }))
    XCTAssertTrue(a.contains(exactly: 2, where: { $0 == "A" }))
    XCTAssertTrue(a.contains(exactly: 4, where: { vowels.contains($0) }))
  }
  
  func testCountIsAtLeastDocumentationExample() {
    let numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    XCTAssertTrue(numbers.contains(atLeast: 2, where: { $0.isMultiple(of: 3) }))
  }
  
  func testCountIsAtLeast() {
    let vowels = Set<String>(["A", "E", "I", "O", "U", "Y"])
    
    let a = ["A", "A", "", "B", "C", "D", "E", "F", "G", "I"]
    XCTAssertTrue(a.contains(atLeast: 1, where: { $0 == "" }))
    XCTAssertTrue(a.contains(atLeast: 2, where: { $0 == "A" }))
    XCTAssertFalse(a.contains(atLeast: 3, where: { $0 == "A" }))
    XCTAssertTrue(a.contains(atLeast: 2, where: { vowels.contains($0) }))
    XCTAssertTrue(a.contains(atLeast: 3, where: { vowels.contains($0) }))
    XCTAssertFalse(a.contains(atLeast: 1, where: { $0 == "Z" }))
  }
  
  func testCountIsMoreThanDocumentationExample() {
    let numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    XCTAssertTrue(numbers.contains(moreThan: 2, where: { $0.isMultiple(of: 3) }))
  }
  
  func testCountIsMoreThan() {
    let vowels = Set<String>(["A", "E", "I", "O", "U", "Y"])
    
    let a = ["A", "A", "", "B", "C", "D", "E", "F", "G", "I"]
    XCTAssertTrue(a.contains(moreThan: 0, where: { $0 == "" }))
    XCTAssertFalse(a.contains(moreThan: 1, where: { $0 == "" }))
    XCTAssertTrue(a.contains(moreThan: 1, where: { $0 == "A" }))
    XCTAssertFalse(a.contains(moreThan: 2, where: { $0 == "A" }))
    XCTAssertTrue(a.contains(moreThan: 2, where: { vowels.contains($0) }))
    XCTAssertTrue(a.contains(moreThan: 3, where: { vowels.contains($0) }))
    XCTAssertFalse(a.contains(moreThan: 4, where: { vowels.contains($0) }))
    XCTAssertFalse(a.contains(moreThan: 1, where: { $0 == "Z" }))
  }
  
  func testCountIsLessThanDocumentationExample() {
    let numbers = [1, 2, 5, 10, 20, 50, 100, 1, 1, 5, 2]
    XCTAssertTrue(numbers.contains(lessThan: 5, where: { $0.isMultiple(of: 10) }))
  }
  
  func testCountIsLessThan() {
    let vowels = Set<String>(["A", "E", "I", "O", "U", "Y"])
    
    let a = ["A", "A", "", "B", "C", "D", "E", "F", "G", "I"]
    XCTAssertFalse(a.contains(lessThan: 1, where: { $0 == "" }))
    XCTAssertTrue(a.contains(lessThan: 3, where: { $0 == "A" }))
    XCTAssertFalse(a.contains(lessThan: 2, where: { $0 == "A" }))
    XCTAssertTrue(a.contains(lessThan: 5, where: { vowels.contains($0) }))
    XCTAssertFalse(a.contains(lessThan: 4, where: { vowels.contains($0) }))
    XCTAssertTrue(a.contains(lessThan: 1, where: { $0 == "Z" }))
  }
  
  func testCountIsLessThanOrEqualToDocumentationExample() {
    let numbers = [1, 2, 5, 10, 20, 50, 100, 1000, 1, 1, 5, 2]
    XCTAssertTrue(numbers.contains(lessThanOrEqualTo: 5, where: { $0.isMultiple(of: 10) }))
  }
  
  func testCountIsLessThanOrEqualTo() {
    let vowels = Set<String>(["A", "E", "I", "O", "U", "Y"])
    
    let a = ["A", "A", "", "B", "C", "D", "E", "F", "G", "I"]
    XCTAssertTrue(a.contains(lessThanOrEqualTo: 1, where: { $0 == "" }))
    XCTAssertTrue(a.contains(lessThanOrEqualTo: 2, where: { $0 == "A" }))
    XCTAssertFalse(a.contains(lessThanOrEqualTo: 1, where: { $0 == "A" }))
    XCTAssertTrue(a.contains(lessThanOrEqualTo: 4, where: { vowels.contains($0) }))
    XCTAssertFalse(a.contains(lessThanOrEqualTo: 3, where: { vowels.contains($0) }))
    XCTAssertTrue(a.contains(lessThanOrEqualTo: 1, where: { $0 == "Z" }))
  }
  
  func testZeroCount() {
    let a = ["A", "B", "C"]
    XCTAssertTrue(a.contains(atLeast: 0, where: { _ in false }))
    XCTAssertTrue(a.contains(atLeast: 0, where: { _ in true }))
    XCTAssertFalse(a.contains(lessThan: 0, where: { _ in false }))
    XCTAssertFalse(a.contains(lessThan: 0, where: { _ in true }))
    XCTAssertTrue(a.contains(lessThanOrEqualTo: 0, where: { _ in false }))
    XCTAssertFalse(a.contains(lessThanOrEqualTo: 0, where: { _ in true }))
    
    let b = [String]()
    XCTAssertTrue(b.contains(atLeast: 0, where: { _ in false }))
    XCTAssertTrue(b.contains(atLeast: 0, where: { _ in true }))
    XCTAssertFalse(b.contains(lessThan: 0, where: { _ in false }))
    XCTAssertFalse(b.contains(lessThan: 0, where: { _ in true }))
    XCTAssertTrue(b.contains(lessThanOrEqualTo: 0, where: { _ in false }))
    XCTAssertTrue(b.contains(lessThanOrEqualTo: 0, where: { _ in true }))
  }
}
