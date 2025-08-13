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
  let expectedRange = ((expectedValue / 3) * 2)...((expectedValue / 3) * 4)
  expectEqualSequences(
    samples.keys.sorted(), elements,
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
    validateRandomSamples(
      samples, elements: c, expectedValue: (k * iterations) / n)
  }
}
