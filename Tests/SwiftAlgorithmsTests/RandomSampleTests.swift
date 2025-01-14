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

func validateRandomSamples<S: Sequence>(
  _ samples: [Int: Int],
  elements: S,
  expectedValue: Int,
  file: StaticString = (#file), line: UInt = #line
) where S.Element == Int {
  let expectedRange = ((expectedValue / 3) * 2) ... ((expectedValue / 3) * 4)
  XCTAssertEqualSequences(samples.keys.sorted(), elements,
    file: file, line: line)
  for v in samples.values {
    XCTAssert(expectedRange.contains(v), file: file, line: line)
  }
}

private let n = 100
private let k = 12
private let iterations = 10_000
private let c = 0..<n
private let s = sequence(first: 0, next: { $0 == n - 1 ? nil : $0 + 1 })

final class RandomSampleTests: XCTestCase {
  func testRandomStableSampleCollection() {
    let samples: [Int: Int] = (0..<iterations).reduce(into: [:]) { result, _ in
      let sample = c.randomStableSample(count: k)
      XCTAssert(sample.isSorted())
      for x in sample {
        result[x, default: 0] += 1
      }
    }
    validateRandomSamples(samples, elements: c, expectedValue: (k * iterations) / n)
  }
  
  func testRandomSampleCollection() {
    let samples: [Int: Int] = (0..<iterations).reduce(into: [:]) { result, _ in
      for x in c.randomSample(count: k) {
        result[x, default: 0] += 1
      }
    }
    validateRandomSamples(samples, elements: c, expectedValue: (k * iterations) / n)
  }
  
  func testRandomSampleSequence() {
    let samples: [Int: Int] = (0..<iterations).reduce(into: [:]) { result, _ in
      for x in s.randomSample(count: k) {
        result[x, default: 0] += 1
      }
    }
    validateRandomSamples(samples, elements: s, expectedValue: (k * iterations) / n)
  }
  
  func testRandomSampleEdgeCases() {
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
    var generator = SplitMix64(seed: 0)
    let sample1a = c.randomSample(count: k, using: &generator)
    generator = SplitMix64(seed: 0)
    let sample2a = c.randomSample(count: k, using: &generator)
    XCTAssertEqual(sample1a, sample2a)

    generator = SplitMix64(seed: 0)
    let sample1b = s.randomSample(count: k, using: &generator)
    generator = SplitMix64(seed: 0)
    let sample2b = s.randomSample(count: k, using: &generator)
    XCTAssertEqual(sample1b, sample2b)
    
    generator = SplitMix64(seed: 0)
    let sample1c = c.randomStableSample(count: k, using: &generator)
    generator = SplitMix64(seed: 0)
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
}
