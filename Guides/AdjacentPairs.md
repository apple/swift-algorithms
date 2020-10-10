# AdjacentPairs

[[Source](https://github.com/apple/swift-algorithms/blob/main/Sources/Algorithms/AdjacentPairs.swift) | 
 [Tests](https://github.com/apple/swift-algorithms/blob/main/Tests/SwiftAlgorithmsTests/AdjacentPairs.swift)]

Considers each pair of elements of a collection iteratively.

This operation is available throught the `adjacentPairs` property on any collection or
lazy collection.

```swift
let pairs = [10, 20, 30, 40].adjacentPairs
// Array(pairs) == [(10, 20), (20, 30), (30, 40)]
```

## Detailed Design

The `adjacentPairs` property is added as an extension method on the `Collection`
and `LazyCollectionProtocol`:

```swift
extension LazyCollectionProtocol {
    public typealias AdjacentPair = (leading: Base.Element, trailing: Base.Element)
    public var adjacentPairs: LazyAdjacentPairs<Self>
}

extension Collection {
    public typealias AdjacentPair = LazyAdjacentPairs<Self>.AdjacentPair
    public var adjacentPairs: [AdjacentPair]
}

```

The resulting `LazyAdjacentPairs` conforms to `LazyCollectionProtocol` with
conditional conformance to the `BidirectionalCollection`, and 
`RandomAccessCollection` protocols when the base type conforms.

`Collection` does not return the  `LazyAdjacentPairs` collection, but instead returns
an Array of the `AdjacentPair` tuples instead.


## Naming

The lower-indexed element of each pair is called the leading element, whereas
the higher-indexed element is referred to as the trailing element.
This is consistent with the naming of leading & trailing alignments in SwiftUI.

Alternatives considered for "leading" & "trailing" were "lower" & "upper", respectively.
