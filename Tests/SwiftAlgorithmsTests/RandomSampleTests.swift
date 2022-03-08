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
@testable import Algorithms

func expectedRange(for value: Int) -> ClosedRange<Int> {
  ((value / 3) * 2) ... ((value / 3) * 4)
}

func validateRandomSamples<S: Sequence>(
  _ samples: [Int: Int],
  elements: S,
  expectedValue: Int,
  file: StaticString = #file, line: UInt = #line
) where S.Element == Int {
  let expectedRange = expectedRange(for: expectedValue)
  XCTAssertEqualSequences(samples.keys.sorted(), elements,
    file: file, line: line)
  for v in samples.values {
    XCTAssert(expectedRange.contains(v), file: file, line: line)
  }
}

private let n = 100
private let k = 12
private let iterations = 1000

/// A collection to sample from.
private let c = 0..<n
/// A sequence to sample from.
private let s = sequence(first: 0, next: { $0 == n - 1 ? nil : $0 + 1 })
/// An empty sequence
private let emptySequence = sequence(state: 0, next: { (_) -> Int? in nil })

final class RandomSampleTests: XCTestCase {
  func testRandomStableSampleCollection() {
    let samples: [Int: Int] = (0..<iterations).reduce(into: [:]) { result, _ in
      let sample = c.randomStableSample(count: k)
      XCTAssert(sample.isSorted())
      result.merge(sample.frequencies, uniquingKeysWith: +)
    }
    validateRandomSamples(samples, elements: c, expectedValue: (k * iterations) / n)
  }
  
  func testRandomSampleCollection() {
    let samples: [Int: Int] = (0..<iterations).reduce(into: [:]) { result, _ in
      result.merge(c.randomSample(count: k).frequencies, uniquingKeysWith: +)
    }
    validateRandomSamples(samples, elements: c, expectedValue: (k * iterations) / n)
  }
  
  func testRandomSampleSequence() {
    let samples: [Int: Int] = (0..<iterations).reduce(into: [:]) { result, _ in
      result.merge(s.randomSample(count: k).frequencies, uniquingKeysWith: +)
    }
    validateRandomSamples(samples, elements: s, expectedValue: (k * iterations) / n)
  }
  
  func testRandomSampleEdgeCases() {
    XCTAssert(emptySequence.randomSample(count: 10).isEmpty)
    XCTAssert(([] as [Int]).randomSample(count: 10).isEmpty)
    XCTAssert(([] as [Int]).randomStableSample(count: 10).isEmpty)

    XCTAssert(c.randomStableSample(count: 0).isEmpty)
    XCTAssertEqualSequences(c.randomStableSample(count: n), c)
    XCTAssertEqualSequences(c.randomStableSample(count: n * 2), c)

    XCTAssert(c.randomSample(count: 0).isEmpty)
    XCTAssertEqualSequences(c.randomSample(count: n).sorted(), c)
    XCTAssertEqualSequences(c.randomSample(count: n * 2).sorted(), c)
    
    XCTAssert(s.randomSample(count: 0).isEmpty)
    XCTAssertEqualSequences(s.randomSample(count: n).sorted(), c)
    XCTAssertEqualSequences(s.randomSample(count: n * 2).sorted(), c)
  }
  
  func testRandomSampleRepeatable() {
    let seed = UInt64.random(in: 0 ... .max)

    var generator = SplitMix64(seed: seed)
    let sample1a = c.randomSample(count: k, using: &generator)
    generator = SplitMix64(seed: seed)
    let sample2a = c.randomSample(count: k, using: &generator)
    XCTAssertEqual(sample1a, sample2a)

    generator = SplitMix64(seed: seed)
    let sample1b = s.randomSample(count: k, using: &generator)
    generator = SplitMix64(seed: seed)
    let sample2b = s.randomSample(count: k, using: &generator)
    XCTAssertEqual(sample1b, sample2b)
    
    generator = SplitMix64(seed: seed)
    let sample1c = c.randomStableSample(count: k, using: &generator)
    generator = SplitMix64(seed: seed)
    let sample2c = c.randomStableSample(count: k, using: &generator)
    XCTAssertEqual(sample1c, sample2c)
  }

  func testRandomSampleRandomEdgeCasesInternal() {
    struct ZeroGenerator: RandomNumberGenerator {
      mutating func next() -> UInt64 { 0 }
    }
    var zero = ZeroGenerator()
    _ = nextOffset(w: 1, using: &zero) // must not crash

    struct AlmostAllZeroGenerator: RandomNumberGenerator {
      private var forward: SplitMix64
      private var count: Int = 0

      init(seed: UInt64) {
        forward = SplitMix64(seed: seed)
      }

      mutating func next() -> UInt64 {
        defer { count &+= 1 }
        if count % 1000 == 0 { return forward.next() }
        return 0
      }
    }

    var almostAllZero = AlmostAllZeroGenerator(seed: 0)
    _ = s.randomSample(count: k, using: &almostAllZero) // must not crash
    almostAllZero = AlmostAllZeroGenerator(seed: 0)
    _ = c.randomSample(count: k, using: &almostAllZero) // must not crash
  }
  
  func testSequenceRandomElement() {
    XCTAssertNil(emptySequence.randomElement())
    
    let expectedRange = expectedRange(for: iterations)
    let randomElements = (0..<(n*iterations)).map { _ in
      s.randomElement()!
    }.frequencies
    XCTAssertEqual(randomElements.count, n)
    XCTAssert(randomElements.values.allSatisfy { expectedRange.contains($0) })
    
    let oneElementSequence = sequence(first: 0, next: { _ in nil })
    let randomOneElement = (0..<iterations).map { _ in
      oneElementSequence.randomElement()!
    }
    XCTAssert(randomOneElement.allSatisfy { $0 == 0 })
    
    let twoElementSequence = sequence(state: [1, 2].makeIterator(), next: { $0.next() })
    let randomTwoElement = (0..<(2*iterations)).map { _ in
      twoElementSequence.randomElement()!
    }.frequencies
    XCTAssertEqual(randomTwoElement.count, 2)
    XCTAssert(randomElements.values.allSatisfy { expectedRange.contains($0) })
  }

  func testSequenceRandomElementRepeatable() {
    let seed = UInt64.random(in: 0 ... .max)
    var generator = SplitMix64(seed: seed)
    let elements1 = (0..<500).map { _ in s.randomElement(using: &generator)! }
    generator = SplitMix64(seed: seed)
    let elements2 = (0..<500).map { _ in s.randomElement(using: &generator)! }
    XCTAssertEqual(elements1, elements2)
  }
}
