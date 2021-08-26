//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift Algorithms open source project
//
// Copyright (c) 2021 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

import Foundation
import Algorithms
import CollectionsBenchmark

/// Benchmarks `.intersperse` from Swift Algorithms for Array<Int> sequences.
func benchmarkInterspersed() {
    var benchmark = Benchmark(title: "Interspersed Benchmark")

    benchmark.addSimple(
      title: "Array<Int> interspersed",
      input: Array<Int>.self
    ) { input in
      blackHole(input.interspersed(with: 9))
    }

    benchmark.main()
}

print(benchmarkInterspersed())
