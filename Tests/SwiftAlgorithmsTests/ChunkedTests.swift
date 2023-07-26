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

final class ChunkedTests: XCTestCase {
  let fruits = [
      "Apple", "Apricot", "Avocado", "Banana",
      "Bilberry", "Blackberry", "Blackcurrant", "Blueberry",
      "Currant", "Cherry", "Cherimoya", "Clementine",
      "Date", "Damson", "Dragonfruit", "Durian",
      "Eggplant", "Elderberry", "Feijoa",
      "Grape", "Grapefruit", "Guava",
  ]

  func validateFruitChunks<C: BidirectionalCollection>(_ fruitChunks: C)
    where C.Element == ArraySlice<String>
  {
    let expectedChunks: Array<ArraySlice<String>> = [
      fruits[0..<3],
      fruits[3..<8],
      fruits[8..<12],
      fruits[12..<16],
      fruits[16..<18],
      fruits[18..<19],
      fruits[19..<22],
    ]
    XCTAssertEqualSequences(expectedChunks, fruitChunks, by: ==)
    
    XCTAssertEqual(fruits[19..<22], fruitChunks.last)
    
    XCTAssertEqual("Currant", fruitChunks.first(where: { $0.count == 4 })?.first)
    XCTAssertEqual("Date", fruitChunks.last(where: { $0.count == 4 })?.first)
    XCTAssertNil(fruitChunks.first(where: { $0.count == 0 }))
    XCTAssertNil(fruitChunks.last(where: { $0.count == 0 }))
  }
  
  func testSimple() {
    // Example
    let names = ["David", "Kyle", "Karoy", "Nate"]
    let chunks = names.chunked(on: { $0.first! })
    let expected: [(Character, ArraySlice<String>)] = [
      ("D", ["David"]),
      ("K", ["Kyle", "Karoy"]),
      ("N", ["Nate"])]
    XCTAssertEqualSequences(expected, chunks, by: ==)
    
    // Empty sequence
    XCTAssertEqual(0, names.prefix(0).chunked(on: { $0.first }).count)

    // Single chunk
    let namesStartingWithD = ["David", "Don", "Darren"]
    XCTAssertEqual(1, namesStartingWithD.chunked(on: { $0.first }).count)
  }
  
  func testChunkedOn() {
    validateFruitChunks(fruits.chunked(on: { $0.first }).map { $1 })
    
    let lazyChunks = fruits.lazy.chunked(on: { $0.first })
    validateFruitChunks(lazyChunks.map { $1 })
    IndexValidator().validate(lazyChunks)
  }

  func testChunkedBy() {
    validateFruitChunks(fruits.chunked(by: { $0.first == $1.first }))
    
    let lazyChunks = fruits.lazy.chunked(by: { $0.first == $1.first })
    validateFruitChunks(lazyChunks)
    IndexValidator().validate(lazyChunks)
  }
  
  func testChunkedByComparesConsecutiveElements() {
    XCTAssertEqualSequences(
      [1, 2, 3, 4, 6, 7, 8, 9].chunked(by: { $1 - $0 == 1 }),
      [[1, 2, 3, 4], [6, 7, 8, 9]])
    
    XCTAssertEqualSequences(
      [1, 2, 3, 4, 6, 7, 8, 9].lazy.chunked(by: { $1 - $0 == 1 }),
      [[1, 2, 3, 4], [6, 7, 8, 9]])
    
    XCTAssertEqualSequences(
      [1, 2, 3, 4, 6, 7, 8, 9].lazy.chunked(by: { $1 - $0 == 1 }).reversed(),
      [[6, 7, 8, 9], [1, 2, 3, 4]])
    
    IndexValidator().validate([1, 2, 3].lazy.chunked(by: { $1 - $0 == 1 }))
  }
  
  func testChunkedLazy() {
    XCTAssertLazySequence(fruits.lazy.chunked(by: { $0.first == $1.first }))
    XCTAssertLazySequence(fruits.lazy.chunked(on: { $0.first }))
  }
  
  //===----------------------------------------------------------------------===//
  // Tests for `chunks(ofCount:)`
  //===----------------------------------------------------------------------===//
  
  func testChunksOfCount() {
    XCTAssertEqualSequences([Int]().chunks(ofCount: 1), [])
    XCTAssertEqualSequences([Int]().chunks(ofCount: 5), [])

    let collection1 = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    XCTAssertEqualSequences(collection1.chunks(ofCount: 1),
                            [[1], [2], [3], [4], [5], [6], [7], [8], [9], [10]])
    XCTAssertEqualSequences(collection1.chunks(ofCount: 3),
                            [[1, 2, 3], [4, 5, 6], [7, 8, 9], [10]])
    XCTAssertEqualSequences(collection1.chunks(ofCount: 5),
                            [[1, 2, 3, 4, 5], [6, 7, 8, 9, 10]])
    XCTAssertEqualSequences(collection1.chunks(ofCount: 11),
                            [[1, 2, 3, 4, 5, 6, 7, 8, 9, 10]])
    
    let collection2 = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]
    XCTAssertEqualSequences(collection2.chunks(ofCount: 3),
                            [[1, 2, 3], [4, 5, 6], [7, 8, 9], [10, 11]])
  }
  
  func testChunksOfCountBidirectional() {
    let collection1 = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

    XCTAssertEqualSequences(collection1.chunks(ofCount: 1).reversed(),
                            [[10], [9], [8], [7], [6], [5], [4], [3], [2], [1]])
    XCTAssertEqualSequences(collection1.chunks(ofCount: 3).reversed(),
                            [[10], [7, 8, 9], [4, 5, 6], [1, 2, 3]])
    XCTAssertEqualSequences(collection1.chunks(ofCount: 5).reversed(),
                            [[6, 7, 8, 9, 10], [1, 2, 3, 4, 5]])
    XCTAssertEqualSequences(collection1.chunks(ofCount: 11).reversed(),
                            [[1, 2, 3, 4, 5, 6, 7, 8, 9, 10]])
    
    let collection2 = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]
    XCTAssertEqualSequences(collection2.chunks(ofCount: 3).reversed(),
                            [[10, 11], [7, 8, 9], [4, 5, 6], [1, 2, 3]])
  }
  
  func testChunksOfCountCount() {
    XCTAssertEqual([Int]().chunks(ofCount: 1).count, 0)
    XCTAssertEqual([Int]().chunks(ofCount: 5).count, 0)

    let collection1 = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    XCTAssertEqual(collection1.chunks(ofCount: 1).count, 10)
    XCTAssertEqual(collection1.chunks(ofCount: 3).count, 4)
    XCTAssertEqual(collection1.chunks(ofCount: 5).count, 2)
    XCTAssertEqual(collection1.chunks(ofCount: 11).count, 1)
    
    let collection2 = (1...50).map { $0 }
    XCTAssertEqual(collection2.chunks(ofCount: 9).count, 6)
  }

  func testEmptyChunksOfCountTraversal() {
    let emptyChunks = [Int]().chunks(ofCount: 1)
    
    IndexValidator().validate(emptyChunks, expectedCount: 0)
  }
  
  func testChunksOfCountTraversal() {
    let validator = IndexValidator<ChunksOfCountCollection<ClosedRange<Int>>>()
    
    for i in 1...10 {
      let range = 1...50
      let chunks = range.chunks(ofCount: i)
      validator.validate(
        chunks,
        expectedCount: range.count / i + (range.count % i).signum())
    }
  }
  
  func testEvenChunks() {
    XCTAssertEqualSequences(
      (0..<10).evenlyChunked(in: 4),
      [0..<3, 3..<6, 6..<8, 8..<10])
    
    XCTAssertEqualSequences(
      (0..<3).evenlyChunked(in: 5),
      [0..<1, 1..<2, 2..<3, 3..<3, 3..<3])
    
    XCTAssertEqualSequences(
      "".evenlyChunked(in: 0),
      [])
    
    XCTAssertEqualSequences(
      "".evenlyChunked(in: 1),
      [""])
  }
  
  func testEvenChunksIndexTraversals() {
    let validator = IndexValidator<EvenlyChunkedCollection<Range<Int>>>()

    [
      (0..<10).evenlyChunked(in: 1),
      (0..<10).evenlyChunked(in: 2),
      (0..<10).evenlyChunked(in: 3),
      (0..<10).evenlyChunked(in: 10),
      (0..<10).evenlyChunked(in: 20),
      (0..<0).evenlyChunked(in: 0),
      (0..<0).evenlyChunked(in: 1),
      (0..<0).evenlyChunked(in: 10),
    ].forEach { validator.validate($0) }
  }
}
