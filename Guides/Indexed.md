# Indexed

[[Source](https://github.com/apple/swift-algorithms/blob/main/Sources/Algorithms/Indexed.swift) | 
 [Tests](https://github.com/apple/swift-algorithms/blob/main/Tests/SwiftAlgorithmsTests/IndexedTests.swift)]

The `enumerated` method, but pairing each element with its index instead of an
incrementing integer counter.

This is essentially equivalent to `zip(x.indices, x)`:

```swift
let numbers = [10, 20, 30, 40, 50]
var matchingIndices: Set<Int> = []
for (i, n) in numbers.indexed() {
    if n.isMultiple(of: 20) { 
        matchingIndices.insert(i) 
    }
}
// matchingIndices == [1, 3]
```

## Detailed Design

The `indexed` method returns an `Indexed` type:

```swift
extension Sequence {
    func indexed() -> Indexed<Self>
}
```

`Indexed` scales from a sequence up to a random-access collection, depending on 
its base type.

