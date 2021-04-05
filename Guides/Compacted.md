# Compacted

[[Source](https://github.com/apple/swift-algorithms/blob/main/Sources/Algorithms/Compacted.swift) | 
 [Tests](https://github.com/apple/swift-algorithms/blob/main/Tests/SwiftAlgorithmsTests/CompactedTests.swift)]

Convenience method that flatten the `nil`s out of a sequence or collection. 
That behaves exactly one of the most common uses of `compactMap` which is `collection.lazy.compactMap { $0 }` 
which is only remove `nil`s without transforming the elements.

```swift
let array: [Int?] = [10, nil, 30, nil, 2, 3, nil, 5]
let withNoNils = array.compacted()
// Array(withNoNils) == [10, 30, 2, 3, 5]

```

The most convenient part of `compacted()` is that we avoid the usage of a closure.

## Detailed Design

The `compacted()` methods has two overloads:

```swift
extension Sequence {
  public func compacted<Unwrapped>() -> CompactedSequence<Self, Unwrapped> { ... }
}

extension Collection {
  public func compacted<Unwrapped>() -> CompactedCollection<Self, Unwrapped> { ... }
}
```

One is a more general `CompactedSequence` for any `Sequence` base. And the other a more specialized `CompactedCollection` 
where base is a `Collection` and with conditional conformance to `BidirectionalCollection`, `RandomAccessCollection`, 
`LazyCollectionProtocol`, `Equatable` and `Hashable` when base collection conforms to them.

### Naming

The naming method name `compacted()` matches the current method `compactMap` that one of the most common usages `compactMap { $0 }` is abstracted by it.  
