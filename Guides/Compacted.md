# Compacted

[[Source](https://github.com/apple/swift-algorithms/blob/main/Sources/Algorithms/Compacted.swift) | 
 [Tests](https://github.com/apple/swift-algorithms/blob/main/Tests/SwiftAlgorithmsTests/CompactedTests.swift)]

A convenience method that lazily flattens the `nil`s out of a sequence 
or collection.

The new method matches one of the most common uses of `compactMap`, 
which is to only remove `nil`s without transforming the elements 
(e.g. `collection.lazy.compactMap { $0 }`).

```swift
let array: [Int?] = [10, nil, 30, nil, 2, 3, nil, 5]
let withNoNils = array.compacted()
// Array(withNoNils) == [10, 30, 2, 3, 5]
```

The type returned by `compacted()` lazily computes the non-`nil` elements
without requiring a user to provide a closure or use the `.lazy` property.  

## Detailed Design

The `compacted()` methods has two overloads:

```swift
extension Sequence {
    public func compacted<Unwrapped>() -> CompactedSequence<Self, Unwrapped>
        where Element == Unwrapped? 
}

extension Collection {
    public func compacted<Unwrapped>() -> CompactedCollection<Self, Unwrapped>
        where Element == Unwrapped?
}
```

The `Sequence` version of `compacted()` returns a `CompactedSequence` type,
while the `Collection` version returns `CompactedCollection`. The collection
has conditional conformance to `BidirectionalCollection` when the base
collection conforms, and both have conditional conformance to 
`LazySequenceProtocol` when the base collection conforms.

### Naming

The name `compacted()` matches the existing method `compactMap`,
which is commonly used to extract only the non-`nil` values
without mapping them to a different type. 
