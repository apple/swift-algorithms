# Unique

[[Source](https://github.com/apple/swift-algorithms/blob/main/Sources/Algorithms/Unique.swift) | 
 [Tests](https://github.com/apple/swift-algorithms/blob/main/Tests/SwiftAlgorithmsTests/UniqueTests.swift)]

Methods to strip repeated elements from a sequence or collection.

The `uniqued()` method returns a sequence, dropping duplicate elements from a 
sequence. The `uniqued(on:)` method does the same, using the result of the given 
closure to determine the "uniqueness" of each element.

```swift
let numbers = [1, 2, 3, 3, 2, 3, 3, 2, 2, 2, 1]

let unique = numbers.uniqued()
// Array(unique) == [1, 2, 3]
```

## Detailed Design

Both methods are available for sequences, with the simplest limited to when the 
element type conforms to `Hashable`. Both methods preserve the relative order of 
the elements. `uniqued(on:)` has a matching lazy version that is added to 
`LazySequenceProtocol`.

```swift
extension Sequence where Element: Hashable {
    func uniqued() -> UniquedSequence<Self, Element>
}

extension Sequence {
    func uniqued<Subject>(on projection: (Element) throws -> Subject) rethrows -> [Element]
        where Subject: Hashable
}

extension LazySequenceProtocol {
    func uniqued<Subject>(on projection: @escaping (Element) -> Subject) -> UniquedSequence<Self, Subject>
        where Subject: Hashable
}
```

### Complexity

The eager `uniqued(on:)` method is O(_n_) in both time and space complexity. The 
lazy versions are O(_1_).

### Comparison with other languages

**C+\+:** The `<algorithm>` library defines a `unique` function that removes
consecutive equal elements.

**Ruby:** Ruby defines a `uniq()` method that acts like `uniqued()`, as well as
a variant that takes a mapping block to a property that should be unique,
matching `uniqued(on:)`.

**Rust:** Rust includes `unique()` and `unique_by()` methods that lazily 
compute the unique elements of a collection, storing the set of already seen
elements in the iterator.

