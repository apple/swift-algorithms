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

import Algorithms
import XCTest

final class UniqueTests: XCTestCase {
  func testUnique() {
    let a = repeatElement(1...10, count: 15).joined().shuffled()
    let b = a.uniqued()
    XCTAssertEqual(b.sorted(), Set(a).sorted())
    XCTAssertEqual(10, Array(b).count)

    let c: [Int] = []
    expectEqualSequences(c.uniqued(), [])

    let d = Array(repeating: 1, count: 10)
    expectEqualSequences(d.uniqued(), [1])
  }

  func testUniqueOn() {
    let a = [
      "Albemarle", "Abeforth", "Astrology", "Brandywine", "Beatrice", "Axiom",
    ]
    let b = a.uniqued(on: { $0.first })
    XCTAssertEqual(["Albemarle", "Brandywine"], b)

    let c: [Int] = []
    XCTAssertEqual(c.uniqued(on: { $0.bitWidth }), [])

    let d = Array(repeating: "Andromeda", count: 10)
    expectEqualSequences(d.uniqued(on: { $0.first }), ["Andromeda"])
  }

  func testLazyUniqueOn() {
    let a = [
      "Albemarle", "Abeforth", "Astrology", "Brandywine", "Beatrice", "Axiom",
    ]
    let b = a.lazy.uniqued(on: { $0.first })
    expectEqualSequences(b, ["Albemarle", "Brandywine"])
    requireLazySequence(b)

    let c: [Int] = []
    expectEqualSequences(c.lazy.uniqued(on: { $0.bitWidth }), [])

    let d = Array(repeating: "Andromeda", count: 10)
    expectEqualSequences(d.lazy.uniqued(on: { $0.first }), ["Andromeda"])
  }

  func testUniqueOnUniquingWith() {
    struct Person: Equatable {
      let id: Int
      var score: Int
    }

    let people = [
      Person(id: 1, score: 10),
      Person(id: 2, score: 20),
      Person(id: 1, score: 30),
      Person(id: 3, score: 5),
      Person(id: 2, score: 15),
    ]

    // Accumulate scores while preserving first occurrence order (id: 1, 2, 3)
    let combined = people.uniqued(on: \.id) { current, incoming in
      Person(id: current.id, score: current.score + incoming.score)
    }
    XCTAssertEqual(combined, [
      Person(id: 1, score: 40),
      Person(id: 2, score: 35),
      Person(id: 3, score: 5),
    ])

    // Empty sequence
    let empty: [Person] = []
    XCTAssertEqual(empty.uniqued(on: \.id, uniquingWith: { _, incoming in incoming }), [])

    // Throwing projection and combine
    struct CustomError: Error, Equatable {}
    XCTAssertThrowsError(
      try [1, 2, 3].uniqued(on: { (_: Int) -> Int in throw CustomError() }, uniquingWith: { a, _ in a })
    )
    XCTAssertThrowsError(
      try [1, 1].uniqued(on: { $0 }, uniquingWith: { _, _ in throw CustomError() })
    )
  }

  func testUniqueUniquingWith() {
    let numbers = [1, 2, 3, 1, 2, 4]
    let result = numbers.uniqued { current, incoming in
      current * 10 + incoming
    }
    XCTAssertEqual(result, [11, 22, 3, 4])
  }
}
