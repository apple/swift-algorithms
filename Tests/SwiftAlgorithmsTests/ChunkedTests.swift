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
    validateIndexTraversals(lazyChunks)
  }

  func testChunkedBy() {
    validateFruitChunks(fruits.chunked(by: { $0.first == $1.first }))
    
    let lazyChunks = fruits.lazy.chunked(by: { $0.first == $1.first })
    validateFruitChunks(lazyChunks)
    validateIndexTraversals(lazyChunks)
  }
  
  func testChunkedByComparesConsecutiveElements() {
    XCTAssertEqualSequences(
      [1, 2, 3, 4, 6, 7, 8, 9].chunked(by: { $1 - $0 == 1 }),
      [[1, 2, 3, 4], [6, 7, 8, 9]])
    
    XCTAssertEqualSequences(
      [1, 2, 3, 4, 6, 7, 8, 9].lazy.chunked(by: { $1 - $0 == 1 }),
      [[1, 2, 3, 4], [6, 7, 8, 9]])
    
    print(Array([1, 2, 3].lazy.chunked(by: { $1 - $0 == 1 })))
    print(Array([1, 2, 3].lazy.chunked(by: { $1 - $0 == 1 }).reversed()))
    
    XCTAssertEqualSequences(
      [1, 2, 3, 4, 6, 7, 8, 9].lazy.chunked(by: { $1 - $0 == 1 }).reversed(),
      [[6, 7, 8, 9], [1, 2, 3, 4]])
    
    validateIndexTraversals([1, 2, 3].lazy.chunked(by: { $1 - $0 == 1 }))
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
    
    validateIndexTraversals(emptyChunks)
  }
  
  func testChunksOfCountTraversal() {
    for i in 1..<10 {
      let collection = (1...50).map { $0 }
      let chunks = collection.chunks(ofCount: i)
      
      validateIndexTraversals(chunks)
    }
  }
}

//===----------------------------------------------------------------------===//
// Tests for eager and lazy `chunkedByReduction(into:_)`
//===----------------------------------------------------------------------===//

class ChunkedByReductionTests: XCTestCase {
  fileprivate struct Thing: Equatable {
    let width: Int
  }

  fileprivate let thingPredicate: (inout Int, Thing) -> Bool = { sum, elem in
    sum += elem.width
    return sum <= 16
  }

  fileprivate let intPredicate: (inout Int, Int) -> Bool = { sum, elem in
    sum += elem
    return sum <= 16
  }

  func testSumObjectProperty() throws {
    let things = [16, 8, 8, 5, 5, 5, 19, 4, 4, 4, 4, 4].map { Thing(width: $0) }
    let expectedChunks: [[Thing]] = [
      [16].map { Thing(width: $0) },
      [8, 8].map { Thing(width: $0) },
      [5, 5, 5].map { Thing(width: $0) },
      [19].map { Thing(width: $0) },
      [4, 4, 4, 4].map { Thing(width: $0) },
      [4].map { Thing(width: $0) }
    ]

    validateChunkedByReduction(
      base: things,
      predicate: thingPredicate,
      initialValue: 0,
      expectedResult: expectedChunks
    )
  }

  func testAveragingPredicate() throws {
    let samples = [2.5, 16.2, 1.5, 3.14, 5.0, 5.75, 7.9, 10.2, 18.6]
    let expectedChunks = [
      [2.5],
      [16.2],
      [1.5, 3.14, 5.0, 5.75, 7.9],
      [10.2],
      [18.6]
    ]

    validateChunkedByReduction(
      base: samples,
      predicate: { result, elem in
        result.0 += elem
        result.1 += 1
        return result.0/Double(result.1) <= 5.0
      },
      initialValue: (0.0, 0),
      expectedResult: expectedChunks
    )
  }

  func testEmpty() throws {
    let things: [Thing] = []
    validateChunkedByReduction(
      base: things,
      predicate: thingPredicate,
      initialValue: 0,
      expectedResult: []
    )
  }

  func testAllFailPredicate() throws {
    validateChunkedByReduction(
      base: [19, 19, 19, 19],
      predicate: intPredicate,
      initialValue: 0,
      expectedResult: [[19], [19], [19], [19]]
    )
  }

  func testNoneFailPredicate() throws {
    validateChunkedByReduction(
      base: [1, 1, 1, 1],
      predicate: intPredicate,
      initialValue: 0,
      expectedResult: [[1, 1, 1, 1]]
    )
  }
}

fileprivate func validateChunkedByReduction<Base: Collection, Accumulator>(
  base: Base,
  predicate: @escaping (inout Accumulator, Base.Element) -> Bool,
  initialValue: Accumulator,
  expectedResult: [[Base.Element]]
)
where Base.Element: Equatable {
  let eagerChunks = base.chunkedByReduction(into: initialValue, predicate)
  XCTAssertEqual(eagerChunks.map { Array($0) }, expectedResult)

  let lazyChunks = base.lazy.chunkedByReduction(into: initialValue, predicate)
  XCTAssertEqual(lazyChunks.map { Array($0) }, expectedResult)
}
