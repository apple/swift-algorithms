# Chain

[[Source](https://github.com/apple/swift-algorithms/blob/main/Sources/Algorithms/Chain.swift) | 
 [Tests](https://github.com/apple/swift-algorithms/blob/main/Tests/SwiftAlgorithmsTests/ChainTests.swift)]

Concatenates two collections with the same element type, one after another.

This operation is available for any two sequences by calling the `chain(_:_:)`
function.

```swift
let numbers = chain([10, 20, 30], 1...5)
// Array(numbers) == [10, 20, 30, 1, 2, 3, 4, 5]

let letters = chain("abcde", "FGHIJ")
// String(letters) == "abcdeFGHIJ"
```

Unlike placing two collections in an array and calling `joined()`, chaining
permits different collection types, performs no allocations, and can preserve
the shared conformances of the two underlying types.

## Detailed Design

The `chain(_:_:)` function takes two sequences as arguments:

```swift
public func chain<S1, S2>(_ s1: S1, _ s2: S2) -> Chain2Sequence<S1, S2>
    where S1.Element == S2.Element
```

The resulting `Chain2Sequence` type is a sequence, with conditional conformance
to `Collection`, `BidirectionalCollection`, and `RandomAccessCollection` when
both the first and second arguments conform.

### Naming

This function's and type's name match the term of art used in other languages
and libraries.

This operation was previously implemented as a `Sequence` method named
`chained(with:)`, and was switched to a free function to align with APIs like
`zip` and `product` after [a lengthy forum discussion][naming]. Alternative
suggestions for method names include `appending(contentsOf:)`, `followed(by:)`,
and `concatenated(to:)`.

[naming]: https://forums.swift.org/t/naming-of-chained-with/40999/

### Comparison with other languages

**Rust:** Rust provides a `chain` function that concatenates two iterators.

**Ruby/Python:** Ruby and Python’s `itertools` both define a `chain` function
for concatenating collections of different kinds.
