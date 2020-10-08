# Unique

[[Source](https://github.com/apple/swift-algorithms/blob/main/Sources/Algorithms/Unique.swift) | 
 [Tests](https://github.com/apple/swift-algorithms/blob/main/Tests/SwiftAlgorithmsTests/UniqueTests.swift)]

Methods to strip repeated elements from a sequence or collection.

The `uniqued()` method returns an array, dropping duplicate elements
from a sequence. The `uniqued(on:)` method does the same, using 
the result of the given closure to determine the "uniqueness" of each 
element.

```swift
let numbers = [1, 2, 3, 3, 2, 3, 3, 2, 2, 2, 1]

let unique = numbers.uniqued()
// unique == [1, 2, 3]
```

## Detailed Design

Both methods are available for sequences, with the simplest limited to
when the element type conforms to `Hashable`. Both methods preserve
the relative order of the elements.

```swift
extension Sequence where Element: Hashable {
    func uniqued() -> [Element]
}

extension Sequence {
    func uniqued<T>(on: (Element) throws -> T) rethrows -> [Element]
        where T: Hashable
}
```

### Complexity

The `uniqued` methods are O(_n_) in both time and space complexity.

### Comparison with other langauges

**C+\+:** The `<algorithm>` library defines a `unique` function that removes
consecutive equal elements.

**Ruby:** Ruby defines a `uniq()` method that acts like `uniqued()`, as well as
a variant that takes a mapping block to a property that should be unique,
matching `uniqued(on:)`.

**Rust:** Rust includes `unique()` and `unique_by()` methods that lazily 
compute the unique elements of a collection, storing the set of already seen
elements in the iterator.

