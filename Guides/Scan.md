# Scan

[[Source](https://github.com/apple/swift-algorithms/blob/main/Sources/Algorithms/Scan.swift) |
 [Tests](https://github.com/apple/swift-algorithms/blob/main/Tests/SwiftAlgorithmsTests/ScanTests.swift)]

Produces a sequence of values.

This has the behaviour of reduce, but instead of returning the final result
value, it returns the a sequence of the results returned from each element.

```swift
let accumulation = (1...5).scan(0, +)
print(Array(accumulation))
// prints [1, 3, 6, 10, 15]

let runningMinimum = [3, 4, 2, 3, 1].scan(.max, min)
print(Array(runningMinimum))
// prints [3, 3, 2, 2, 1]
```

## Detailed Design

One new method is added to sequences:

```swift
extension Sequence {
  func scan<Result>(
    _ initial: Result, 
    _ transform: @escaping (Result, Element) -> Result
  ) -> Scan<Result, Self>
}
```

### Complexity

Calling these methods is O(_1_).

### Naming



### Comparison with other langauges

**C++:** As of C++17, the `<algorithm>` library includes an `inclusive_scan` function.

**Haskell:** Haskell includes a `scan` function for its `Traversable` type,
which is akin to Swift's `Sequence`.

**Python:** Python’s `itertools` includes an `accumulate` method. In version
3.3, a function paramenter was added. Version 3.8 added the optional initial
parameter.

**Rust:** Rust provides a `scan` function.
