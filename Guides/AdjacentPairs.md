# AdjacentPairs

[[Source](https://github.com/apple/swift-algorithms/blob/main/Sources/Algorithms/AdjacentPairs.swift) | 
 [Tests](https://github.com/apple/swift-algorithms/blob/main/Tests/SwiftAlgorithmsTests/AdjacentPairsTests.swift)]
 
Lazily iterates over tuples of adjacent elements.

This operation is available for any sequence by calling the `adjacentPairs()` method.

```swift
let numbers = (1...5)
let pairs = numbers.adjacentPairs()
// Array(pairs) == [(1, 2), (2, 3), (3, 4), (4, 5)]
```

## Detailed Design

The `adjacentPairs()` method is declared as a `Sequence` extension returning `AdjacentPairs`.

```swift
extension Sequence {
  public func adjacentPairs() -> AdjacentPairs<Self>
}
```

The resulting `AdjacentPairs` type is a sequence, with conditional conformance to `Collection`, `BidirectionalCollection`, and `RandomAccessCollection` when the underlying sequence conforms.

The spelling `zip(s, s.dropFirst())` for a sequence `s` is an equivalent operation on collection types; however, this implementation is undefined behavior on single-pass sequences, and `Zip2Sequence` does not conditionally conform to the `Collection` family of protocols.

### Complexity

Calling `adjacentPairs` is an O(1) operation.

### Naming

This method is named for clarity while remaining agnostic to any particular domain of programming. In natural language processing, this operation is akin to computing a list of bigrams; however, this algorithm is not specific to this use case.

[naming]: https://forums.swift.org/t/naming-of-chained-with/40999/

### Comparison with other languages

This function is often written as a `zip` of a sequence together with itself, minus its first element.

**Haskell:** This operation is spelled ``s `zip` tail s``.

**Python:** Python users may write `zip(s, s[1:])` for a list with at least one element. For natural language processing, the `nltk` package offers a `bigrams` function akin to this method.
