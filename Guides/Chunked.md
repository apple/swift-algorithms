# Chunked

[[Source](https://github.com/apple/swift-algorithms/blob/main/Sources/Algorithms/Chunked.swift) | 
 [Tests](https://github.com/apple/swift-algorithms/blob/main/Tests/SwiftAlgorithmsTests/ChunkedTests.swift)]

Break a collection into subsequences where consecutive elements pass a binary
predicate, or where all elements in each chunk project to the same value.

There are two variations of the `chunked` method: `chunked(by:)` and
`chunked(on:)`. `chunked(by:)` uses a binary predicate to test consecutive
elements, separating chunks where the predicate returns `false`. For example,
you can chunk a collection into ascending sequences using this method:

```swift
let numbers = [10, 20, 30, 10, 40, 40, 10, 20]
let chunks = numbers.chunked(by: { $0 <= $1 })
// [[10, 20, 30], [10, 40, 40], [10, 20]]
```

The `chunk(on:)` method, by contrast, takes a projection of each element and
separates chunks where the projection of two consecutive elements is not equal.

```swift
let names = ["David", "Kyle", "Karoy", "Nate"]
let chunks = names.chunked(on: \.first!)
// [["David"], ["Kyle", "Karoy"], ["Nate"]] 
```

These methods are related to the [existing SE proposal][proposal] for chunking a
collection into subsequences of a particular size, potentially named something
like `chunked(length:)`. Unlike the `split` family of methods, the entire
collection is included in the chunked result — joining the resulting chunks
recreates the original collection.

```swift
c.elementsEqual(c.chunked(...).joined())
// true
```

[proposal]: https://github.com/apple/swift-evolution/pull/935

## Detailed Design

The two methods are added as extension to `Collection`, with two matching
versions that return a lazy wrapper added to `LazyCollectionProtocol`.

```swift
extension Collection {
    public func chunked(
        by belongInSameGroup: (Element, Element) -> Bool
    ) -> [SubSequence]

    public func chunked<Subject: Equatable>(
        on projection: (Element) -> Subject
    ) -> [SubSequence]
  }

  extension LazyCollectionProtocol {
    public func chunked(
        by belongInSameGroup: @escaping (Element, Element) -> Bool
    ) -> LazyChunked<Elements>

    public func chunked<Subject: Equatable>(
        on projection: @escaping (Element) -> Subject
    ) -> LazyChunked<Elements>
}
```

The `LazyChunked` type is bidirectional when the wrapped collection is
bidirectional.

### Complexity

The eager methods are O(_n_), the lazy methods are O(_1_).

### Naming

The operation performed by these methods is similar to other ways of breaking a collection up into subsequences. In particular, the predicate-based `split(where:)` method looks similar to `chunked(on:)`. You can draw a distinction between these different operations based on the resulting subsequences:

- `split`: *In the standard library.* Breaks a collection into subsequences, removing any elements that are considered "separators". The original collection cannot be recovered from the result of splitting.
- `chunked`: *In this package.* Breaks a collection into subsequences, preserving each element in its initial ordering. Joining the resulting subsequences re-forms the original collection.
- `sliced`: *Not included in this package or the stdlib.* Breaks a collection into potentially overlapping subsequences.


### Comparison with other langauges

**Ruby:** Ruby’s `Enumerable` class defines `chunk_while` and `chunk`, which map
to the proposed `chunked(by:)` and `chunked(on:)` methods.

**Rust:** Rust defines a variety of size-based `chunks` methods, but doesn’t
include any with the functionality described here.
