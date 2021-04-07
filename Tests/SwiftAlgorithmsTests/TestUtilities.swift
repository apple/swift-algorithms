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

extension Sequence {
  func isSorted(by f: (Element, Element) -> Bool) -> Bool {
    zip(self, self.dropFirst()).allSatisfy { !f($1, $0) }
  }
}

extension Sequence where Element: Comparable {
  func isSorted() -> Bool {
    isSorted(by: <)
  }
}

extension Numeric {
  func factorial() -> Self {
    guard self != 0 else { return 1 }
    return self * (self - 1).factorial()
  }
}

struct SplitMix64: RandomNumberGenerator {
  private var state: UInt64
  
  init(seed: UInt64) {
    self.state = seed
  }
  
  mutating func next() -> UInt64 {
    self.state &+= 0x9e3779b97f4a7c15
    var z: UInt64 = self.state
    z = (z ^ (z &>> 30)) &* 0xbf58476d1ce4e5b9
    z = (z ^ (z &>> 27)) &* 0x94d049bb133111eb
    return z ^ (z &>> 31)
  }
}

// An eraser helper to any hashable sequence.
struct AnyHashableSequence<Base>
  where Base: Sequence, Base: Hashable {
  var base: Base
}

extension AnyHashableSequence: Hashable {}
extension AnyHashableSequence: Sequence {
  typealias Iterator = Base.Iterator
  
  func makeIterator() -> Iterator {
    base.makeIterator()
  }
}

extension Sequence where Self: Hashable {
  func eraseToAnyHashableSequence() -> AnyHashableSequence<Self> {
    AnyHashableSequence(base: self)
  }
}

// An eraser helper to any mutable collection
struct AnyMutableCollection<Base> where Base: MutableCollection {
  var base: Base
}

extension AnyMutableCollection: MutableCollection {
  typealias Index = Base.Index
  typealias Element = Base.Element
  
  var startIndex: Base.Index { base.startIndex }
  var endIndex: Base.Index { base.endIndex }

  func index(after i: Index) -> Index {
    return base.index(after: i)
  }

  subscript(position: Base.Index) -> Base.Element {
    _read { yield base[position] }
    set { base[position] = newValue }
  }
}

extension MutableCollection {
  func eraseToAnyMutableCollection() -> AnyMutableCollection<Self> {
    AnyMutableCollection(base: self)
  }
}

func XCTAssertEqualSequences<S1: Sequence, S2: Sequence>(
  _ expression1: @autoclosure () throws -> S1,
  _ expression2: @autoclosure () throws -> S2,
  _ message: @autoclosure () -> String = "",
  file: StaticString = #file, line: UInt = #line
) rethrows where S1.Element: Equatable, S1.Element == S2.Element {
  try XCTAssertEqualSequences(expression1(), expression2(), by: ==,
    message(), file: file, line: line)
}

// Two sequences contains exactly the same element but not necessarily in the same order.
func XCTAssertUnorderedEqualSequences<S1: Sequence, S2: Sequence>(
  _ expression1: @autoclosure () throws -> S1,
  _ expression2: @autoclosure () throws -> S2,
  file: StaticString = #file, line: UInt = #line
) rethrows where S1.Element: Equatable, S1.Element == S2.Element {
  var s1 = Array(try expression1())
  var missing: [S1.Element] = []
  for elt in try expression2() {
    guard let idx = s1.firstIndex(of: elt) else {
      missing.append(elt)
      continue
    }
    s1.remove(at: idx)
  }
  
  XCTAssertTrue(
    missing.isEmpty, "first sequence missing '\(missing)' elements from second sequence",
    file: file, line: line
  )

  XCTAssertTrue(
    s1.isEmpty, "first sequence contains \(s1) missing from second sequence",
    file: file, line: line
  )
}

func XCTAssertEqualSequences<S1: Sequence, S2: Sequence>(
  _ expression1: @autoclosure () throws -> S1,
  _ expression2: @autoclosure () throws -> S2,
  by areEquivalent: (S1.Element, S1.Element) -> Bool,
  _ message: @autoclosure () -> String = "",
  file: StaticString = #file, line: UInt = #line
) rethrows where S1.Element == S2.Element {

  func fail(_ reason: String) {
    let message = message()
    XCTFail(message.isEmpty ? reason : "\(message) - \(reason)",
            file: file, line: line)
  }

  var iter1 = try expression1().makeIterator()
  var iter2 = try expression2().makeIterator()
  var idx = 0
  while true {
    switch (iter1.next(), iter2.next()) {
    case let (e1?, e2?) where areEquivalent(e1, e2):
      idx += 1
      continue
    case let (e1?, e2?):
      fail("element \(e1) on first sequence does not match element \(e2) on second sequence at position \(idx)")
    case (_?, nil):
      fail("second sequence shorter than first")
    case (nil, _?):
      fail("first sequence shorter than second")
    case (nil, nil): break
    }
    return
  }
}

func XCTAssertLazySequence<S: LazySequenceProtocol>(_: S) {}
func XCTAssertLazyCollection<S: LazyCollectionProtocol>(_: S) {}

/// Asserts two collections are equal by using their indices to access elements.
func XCTAssertEqualCollections<C1: Collection, C2: Collection>(
  _ expression1: @autoclosure () throws -> C1,
  _ expression2: @autoclosure () throws -> C2,
  _ message: @autoclosure () -> String = "",
  file: StaticString = #file, line: UInt = #line
) rethrows where C1.Element: Equatable, C1.Element == C2.Element {
  let c1 = try expression1()
  let c2 = try expression2()
  XCTAssertEqual(c1.indices.count, c2.indices.count, message(), file: file, line: line)
  for index in zip(c1.indices, c2.indices) {
    XCTAssertEqual(c1[index.0], c2[index.1], message(), file: file, line: line)
  }
}

func hash<T: Hashable>(_ value: T) -> Int {
  var hasher = Hasher()
  value.hash(into: &hasher)
  return hasher.finalize()
}

/// Asserts that two hashable instances produce the same hash value.
func XCTAssertEqualHashValue<T: Hashable, U: Hashable>(
  _ expression1: @autoclosure () throws -> T,
  _ expression2: @autoclosure () throws -> U,
  _ message: @autoclosure () -> String = "",
  file: StaticString = #file, line: UInt = #line
) {
  XCTAssertEqual(
    hash(try expression1()), hash(try expression2()),
    message(), file: file, line: line
  )
}

/// Asserts that two hashable instances don't produce the same hash value.
func XCTAssertNotEqualHashValue<T: Hashable, U: Hashable>(
  _ expression1: @autoclosure () throws -> T,
  _ expression2: @autoclosure () throws -> U,
  _ message: @autoclosure () -> String = "",
  file: StaticString = #file, line: UInt = #line
) {
  XCTAssertNotEqual(
    hash(try expression1()), hash(try expression2()),
    message(), file: file, line: line
  )
}

/// Tests that all index traversal methods behave as expected.
///
/// Verifies the correctness of the implementations of `startIndex`, `endIndex`,
/// `indices`, `count`, `isEmpty`, `index(before:)`, `index(after:)`,
/// `index(_:offsetBy:)`, `index(_:offsetBy:limitedBy:)`, and
/// `distance(from:to:)` by calling them with just about all possible input
/// combinations. When provided, the `indices` function is used to to test the
/// collection methods against.
///
/// - Parameters:
///   - collections: The collections to be validated.
///   - indices: A closure that returns the expected indices of the given
///     collection, including its `endIndex`, in ascending order. Only use this
///     parameter if you are able to compute the indices of the collection
///     independently of the `Collection` conformance, e.g. by using the
///     contents of the collection directly.
///
/// - Complexity: O(*n*^3) for each collection, where *n* is the length of the
///   collection.
func validateIndexTraversals<C>(
  _ collections: C...,
  indices: ((C) -> [C.Index])? = nil,
  file: StaticString = #file, line: UInt = #line
) where C: BidirectionalCollection {
  for c in collections {
    let indicesIncludingEnd = indices?(c) ?? (c.indices + [c.endIndex])
    let count = indicesIncludingEnd.count - 1
    
    XCTAssertEqual(
      c.count, count,
      "Count mismatch",
      file: file, line: line)
    XCTAssertEqual(
      c.isEmpty, count == 0,
      "Emptiness mismatch",
      file: file, line: line)
    XCTAssertEqual(
      c.startIndex, indicesIncludingEnd.first,
      "`startIndex` does not equal the first index",
      file: file, line: line)
    XCTAssertEqual(
      c.endIndex, indicesIncludingEnd.last,
      "`endIndex` does not equal the last index",
      file: file, line: line)
    
    // `index(after:)`
    do {
      var index = c.startIndex
      
      for (offset, expected) in indicesIncludingEnd.enumerated().dropFirst() {
        c.formIndex(after: &index)
        XCTAssertEqual(
          index, expected,
          """
          `startIndex` incremented \(offset) times does not equal index at \
          offset \(offset)
          """,
          file: file, line: line)
      }
    }
    
    // `index(before:)`
    do {
      var index = c.endIndex

      for (offset, expected) in indicesIncludingEnd.enumerated().dropLast().reversed() {
        c.formIndex(before: &index)
        XCTAssertEqual(
          index, expected,
          """
          `endIndex` decremented \(count - offset) times does not equal index \
          at offset \(offset)
          """,
          file: file, line: line)
      }
    }
    
    // `indices`
    XCTAssertEqual(c.indices.count, count)
    for (offset, index) in c.indices.enumerated() {
      XCTAssertEqual(
        index, indicesIncludingEnd[offset],
        "Index mismatch at offset \(offset) in `indices`",
        file: file, line: line)
    }
    
    // index comparison
    for (offsetA, a) in indicesIncludingEnd.enumerated() {
      XCTAssertEqual(
        a, a,
        "Index at offset \(offsetA) does not equal itself",
        file: file, line: line)
      XCTAssertFalse(
        a < a,
        "Index at offset \(offsetA) is less than itself",
        file: file, line: line)
      
      for (offsetB, b) in indicesIncludingEnd[..<offsetA].enumerated() {
        XCTAssertNotEqual(
          a, b,
          "Index at offset \(offsetA) equals index at offset \(offsetB)",
          file: file, line: line)
        XCTAssertLessThan(
          b, a,
          """
          Index at offset \(offsetB) is not less than index at offset \(offsetA)
          """,
          file: file, line: line)
      }
    }
    
    // `index(_:offsetBy:)` and `distance(from:to:)`
    for (startOffset, start) in indicesIncludingEnd.enumerated() {
      for (endOffset, end) in indicesIncludingEnd.enumerated() {
        let distance = endOffset - startOffset
        
        XCTAssertEqual(
          c.index(start, offsetBy: distance), end,
          """
          Index at offset \(startOffset) offset by \(distance) does not equal \
          index at offset \(endOffset)
          """,
          file: file, line: line)
        XCTAssertEqual(
          c.distance(from: start, to: end), distance,
          """
          Distance from index at offset \(startOffset) to index at offset \
          \(endOffset) does not equal \(distance)
          """,
          file: file, line: line)
      }
    }
    
    // `index(_:offsetBy:limitedBy:)`
    for (startOffset, start) in indicesIncludingEnd.enumerated() {
      for (limitOffset, limit) in indicesIncludingEnd.enumerated() {
        // verifies that the target index corresponding to each offset in
        // `range` can or cannot be reached from `start` using
        // `chain.index(start, offsetBy: _, limitedBy: limit)`, depending on the
        // value of `pastLimit`
        func checkTargetRange(_ range: ClosedRange<Int>, pastLimit: Bool) {
          for targetOffset in range {
            let distance = targetOffset - startOffset
            let end = c.index(start, offsetBy: distance, limitedBy: limit)
            
            if pastLimit {
              XCTAssertNil(
                end,
                """
                Index at offset \(startOffset) offset by \(distance) limited \
                by index at offset \(limitOffset) does not equal `nil`
                """,
                file: file, line: line)
            } else {
              XCTAssertEqual(
                end, indicesIncludingEnd[targetOffset],
                """
                Index at offset \(startOffset) offset by \(distance) limited \
                by index at offset \(limitOffset) does not equal index at \
                offset \(targetOffset)
                """,
                file: file, line: line)
            }
          }
        }
        
        // forward offsets
        if limit >= start {
          // the limit has an effect
          checkTargetRange(startOffset...limitOffset, pastLimit: false)
          checkTargetRange((limitOffset + 1)...(count + 1), pastLimit: true)
        } else {
          // the limit has no effect
          checkTargetRange(startOffset...count, pastLimit: false)
        }
        
        // backward offsets
        if limit <= start {
          // the limit has an effect
          checkTargetRange(limitOffset...startOffset, pastLimit: false)
          checkTargetRange(-1...(limitOffset - 1), pastLimit: true)
        } else {
          // the limit has no effect
          checkTargetRange(0...startOffset, pastLimit: false)
        }
      }
    }
  }
}
