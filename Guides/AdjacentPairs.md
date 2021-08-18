# AdjacentPairs

[[Source](https://github.com/apple/swift-algorithms/blob/main/Sources/Algorithms/AdjacentPairs.swift) | 
 [Tests](https://github.com/apple/swift-algorithms/blob/main/Tests/SwiftAlgorithmsTests/AdjacentPairsTests.swift)]
 
Lazily iterates over tuples of adjacent elements.

This operation is available for any sequence by calling the `adjacentPairs()`
method.

```swift
let numbers = (1...5)
let pairs = numbers.adjacentPairs()
// Array(pairs) == [(1, 2), (2, 3), (3, 4), (4, 5)]
```

## Detailed Design

The `adjacentPairs()` method is declared as a `Sequence` extension returning
`AdjacentPairsSequence` and as a `Collection` extension returning
`AdjacentPairsCollection`.

```swift
extension Sequence {
    public func adjacentPairs() -> AdjacentPairsSequence<Self>
}
```

```swift
extension Collection {
    public func adjacentPairs() -> AdjacentPairsCollection<Self>
}
```

The `AdjacentPairsSequence` type is a sequence, and the
`AdjacentPairsCollection` type is a collection with conditional conformance to
`BidirectionalCollection` and `RandomAccessCollection` when the underlying
collection conforms.

### Complexity

Calling `adjacentPairs` is an O(1) operation.

### Naming

This method is named for clarity while remaining agnostic to any particular
domain of programming. In natural language processing, this operation is akin to 
computing a list of bigrams; however, this algorithm is not specific to this use 
case.

### Comparison with other languages

This function is often written as a `zip` of a sequence together with itself, 
minus its first element.

**Haskell:** This operation is spelled ``s `zip` tail s``.

**Python:** Python users may write `zip(s, s[1:])` for a list with at least one 
element. For natural language processing, the `nltk` package offers a `bigrams` 
function akin to this method.

 Note that in Swift, the spelling `zip(s, s.dropFirst())` is undefined behavior 
 for a single-pass sequence `s`.
