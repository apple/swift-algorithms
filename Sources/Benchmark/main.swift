import Darwin
import Algorithms

struct Benchmark {
  var name: String
  var `default`: Int
  var body: (Int) -> Int
}

let benchmarks = [
  Benchmark(name: "chain", default: 100) { count in
    let x = String(repeating: "_", count: 10_000)
      .chained(with: String(repeating: "-", count: 10_000))
      .chained(with: "0")
    var v = 0
    for _ in 0..<count {
      let i = x.firstIndex(of: "0")!
      let d = x.distance(from: x.startIndex, to: i)
      v &+= d
    }
    return v
  },
  
  Benchmark(name: "chunked", default: 1000) { count in
    let x = (1...1000).shuffled()
    var v = 0
    for _ in 0..<count {
      let y = x.chunked(by: <=)
      v &+= y.count
    }
    return v
  },
  
  Benchmark(name: "lazy chunked", default: 1000) { count in
    let x = (1...1000).shuffled()
    var v = 0
    for _ in 0..<count {
      let y = x.lazy.chunked(by: <=)
      v &+= y.count
    }
    return v
  },
  
  Benchmark(name: "combinations", default: 100) { count in
    let x = 1...30
    var v = 0
    for _ in 0..<count {
      let y = x.combinations(ofCount: 4)
      let combo = y.first(where: { combo in combo.allSatisfy { $0.isMultiple(of: 2) }})!
      v &+= combo.reduce(0, +)
    }
    return v
  },
  
  Benchmark(name: "stable partition", default: 100) { count in
    var v = 0
    for _ in 0..<count {
      var x = Array(1...10000)
      let i = x.stablePartition(by: { $0.isMultiple(of: 3) })
      v &+= i
    }
    return v
  },
  
  Benchmark(name: "permutations", default: 10) { count in
    let x = 1...20
    var v = 0
    for _ in 0..<count {
      let y = x.permutations(ofCount: 4)
      let perm = y.first(where: { perm in perm.allSatisfy { $0.isMultiple(of: 2) }})!
      v &+= perm.reduce(0, +)
    }
    return v
  },
  
  Benchmark(name: "product", default: 1000) { count in
    let x = product(1...100, "abcdefghijklmnopqrstuvwxyz")
    var v = 0
    for _ in 0..<count {
      let i = x.firstIndex(where: { $0 == 77 && $1 == "m" })!
      let d = x.distance(from: x.startIndex, to: i)
      v &+= d
    }
    return v
  },
  
  Benchmark(name: "sample", default: 1000) { count in
    let x = 1...10000
    var v = 0
    for _ in 0..<count {
      let r = x.randomSample(count: 20)
      v &+= r.reduce(0, +)
    }
    return v
  },
  
  Benchmark(name: "stable sample", default: 1000) { count in
    let x = 1...10000
    var v = 0
    for _ in 0..<count {
      let r = x.randomStableSample(count: 20)
      v &+= r.reduce(0, +)
    }
    return v
  },
  
  Benchmark(name: "uniqued", default: 1000) { count in
    let x = repeatElement(1...1000, count: 1000)
    var v = 0
    for _ in 0..<count {
      let r = x.uniqued()
      v &+= r.count
    }
    return v
  },
]

func printChoices() -> Never {
  print(benchmarks.enumerated().map { "\($0): \($1.name)" }.joined(separator: "\n"))
  exit(0)
}

if CommandLine.arguments.count <= 1 {
  printChoices()
} else {
  guard let choice = Int(CommandLine.arguments[1]), benchmarks.indices.contains(choice) else {
    print("Invalid choice:")
    printChoices()
  }
  
  let bench = benchmarks[choice]
  let count: Int
  if CommandLine.arguments.count > 2, let c = Int(CommandLine.arguments[2]) {
    count = c
  } else {
    count = bench.default
  }
  
  print(bench.body(count))
}
