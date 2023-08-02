# Chunked

[[Source](https://github.com/apple/swift-algorithms/blob/main/Sources/Algorithms/Chunked.swift) | 
 [Tests](https://github.com/apple/swift-algorithms/blob/main/Tests/SwiftAlgorithmsTests/ChunkedTests.swift)]

Break a collection into nonoverlapping subsequences:

* `chunked(by:)` forms chunks of consecutive elements that pass a binary predicate,
* `chunked(on:)` forms chunks of consecutive elements that project to equal values,
* `chunks(ofCount:)` forms chunks of a given size, and
* `evenlyChunked(in:)` forms a given number of equally-sized chunks.

`chunked(by:)` uses a binary predicate to test consecutive elements, separating
chunks where the predicate returns `false`. For example, you can chunk a
collection into ascending sequences using this method:

```swift
let numbers = [10, 20, 30, 10, 40, 40, 10, 20]
let chunks = numbers.chunked(by: { $0 <= $1 })
// [[10, 20, 30], [10, 40, 40], [10, 20]]
```

The `chunked(on:)` method, by contrast, takes a projection of each element and
separates chunks where the projection of two consecutive elements is not equal.
The result includes both the projected value and the subsequence that groups
elements with that projected value:

```swift
let names = ["David", "Kyle", "Karoy", "Nate"]
let chunks = names.chunked(on: \.first!)
// [("D", ["David"]), ("K", ["Kyle", "Karoy"]), ("N", ["Nate"])] 
```

The `chunks(ofCount:)` method takes a `count` parameter (required to be > 0) and
separates the collection into chunks of this given count. If the length of the
collection is a multiple of the `count` parameter, all chunks will have the
a count equal to the parameter. Otherwise, the last chunk will contain the remaining elements.
 
```swift
let names = ["David", "Kyle", "Karoy", "Nate"]
let evenly = names.chunks(ofCount: 2)
// equivalent to [["David", "Kyle"], ["Karoy", "Nate"]] 

let remaining = names.chunks(ofCount: 3)
// equivalent to [["David", "Kyle", "Karoy"], ["Nate"]]
```

The `chunks(ofCount:)` method was previously [proposed](proposal) for inclusion
in the standard library.

The `evenlyChunked(in:)` method takes a `count` parameter and divides the
collection into `count` number of equally-sized chunks. If the length of the
collection is not a multiple of the `count` parameter, the chunks at the start
will be longer than the chunks at the end.

```swift
let evenChunks = (0..<15).evenlyChunked(in: 3)
// equivalent to [0..<5, 5..<10, 10..<15]

let nearlyEvenChunks = (0..<15).evenlyChunked(in: 4)
// equivalent to [0..<4, 4..<8, 8..<12, 12..<15]
```

When "chunking" a collection, the entire collection is included in the result,
unlike the `split` family of methods, where separators are dropped.
Joining the result of a chunking method call results in a collection equivalent
to the original.

```swift
c.elementsEqual(c.chunked(...).joined())
// true
```

[proposal]: https://github.com/apple/swift-evolution/pull/935

## Detailed Design

The four methods are added to `Collection`, with matching versions of
`chunked(by:)` and `chunked(on:)` that return a lazy wrapper added to
`LazyCollectionProtocol`.

```swift
extension Collection {
    public func chunked(
        by belongInSameGroup: (Element, Element) -> Bool
    ) -> [SubSequence]

    public func chunked<Subject: Equatable>(
      on projection: (Element) -> Subject
    ) -> [SubSequence]
      
    public func chunks(ofCount count: Int) -> ChunkedByCount<Self>
      
    public func evenlyChunked(in count: Int) -> EvenlyChunkedCollection<Self>
}

extension LazyCollectionProtocol {
    public func chunked(
        by belongInSameGroup: @escaping (Element, Element) -> Bool
    ) -> ChunkedByCollection<Elements>

    public func chunked<Subject: Equatable>(
        on projection: @escaping (Element) -> Subject
    ) -> ChunkedOnCollection<Elements, Subject>
}
```

Each of the "chunked" collection types are bidirectional when the wrapped
collection is bidirectional. `ChunksOfCountCollection` and 
`EvenlyChunkedCollection` also conform to `RandomAccessCollection` and 
`LazySequenceProtocol` when their base collections conform.

### Complexity

The eager methods are O(_n_) where _n_ is the number of elements in the
collection. The lazy methods are O(_n_) because the start index is pre-computed.

### Naming

The operation performed by these methods is similar to other ways of breaking a 
collection up into subsequences. In particular, the predicate-based 
`split(where:)` method looks similar to `chunked(on:)`. You can draw a 
distinction between these different operations based on the resulting 
subsequences:

- `split`: *In the standard library.* Breaks a collection into subsequences, 
removing any elements that are considered "separators". The original collection 
cannot be recovered from the result of splitting.
- `chunked`: *In this package.* Breaks a collection into subsequences, 
preserving each element in its initial ordering. Joining the resulting 
subsequences re-forms the original collection.
- `sliced`: *Not included in this package or the stdlib.* Breaks a collection 
into potentially overlapping subsequences.

### Comparison with other languages

**Ruby:** Ruby’s `Enumerable` class defines `chunk_while` and `chunk`, which map
to the proposed `chunked(by:)` and `chunked(on:)` methods.

**Rust:** Rust defines a variety of size-based `chunks` methods, of which the
standard version corresponds to the `chunks(ofCount:)` method defined here.
