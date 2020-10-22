# Chain

[[Source](https://github.com/apple/swift-algorithms/blob/main/Sources/Algorithms/Chain.swift) | 
 [Tests](https://github.com/apple/swift-algorithms/blob/main/Tests/SwiftAlgorithmsTests/ChainTests.swift)]

Concatenates two collections with the same element type, one after another.

This operation is available through the `chained(with:)` method on any sequence.

```swift
let numbers = [10, 20, 30].chained(with: 1...5)
// Array(numbers) == [10, 20, 30, 1, 2, 3, 4, 5]
// 
let letters = "abcde".chained(with: "FGHIJ")
// String(letters) == "abcdeFGHIJ"
```

Unlike placing two collections in an array and calling `joined()`, chaining
permits different collection types, performs no allocations, and can preserve
the shared conformances of the two underlying types.

## Detailed Design

The `chained(with:)` method is added as an extension method on the `Sequence`
protocol:

```swift
extension Sequence {
    public func chained<S: Sequence>(with other: S) -> Concatenation<Self, S>
        where Element == S.Element
}
```

The resulting `Chain` type is a sequence, with conditional conformance to
`Collection`, `BidirectionalCollection`, and `RandomAccessCollection` when both
the first and second arguments conform. `Chain` also conforms to
`LazySequenceProtocol` when the first argument conforms.

### Naming

This method’s and type’s name match the term of art used in other languages and
libraries.

### Comparison with other languages

**Rust:** Rust provides a `chain` function that concatenates two iterators.

**Ruby/Python:** Ruby and Python’s `itertools` both define a `chain` function
for concatenating collections of different kinds.
