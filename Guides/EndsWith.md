# EndsWith

[[Source](https://github.com/apple/swift-algorithms/blob/main/Sources/Algorithms/EndsWith.swift) |
 [Tests](https://github.com/apple/swift-algorithms/blob/main/Tests/SwiftAlgorithmsTests/EndsWithTests.swift)]

This function checks whether the final elements of the one collection are the same as the elements in another collection.
```

## Detailed Design

The `ends(with:)` and `ends(with:by:)` functions are added as methods on an extension of 
`BidirectionalCollection`.

```swift
extension BidirectionalCollection {
    public func ends<PossibleSuffix: BidirectionalCollection>(
        with possibleSuffix: PossibleSuffix
    ) -> Bool where PossibleSuffix.Element == Element
    
    public func ends<PossibleSuffix: BidirectionalCollection>(
        with possibleSuffix: PossibleSuffix,
        by areEquivalent: (Element, PossibleSuffix.Element) throws -> Bool
    ) rethrows -> Bool
}
```

This method requires `BidirectionalCollection` for being able to traverse back from the end of the collection. It also requires the `possibleSuffix` to be `BidirectionalCollection`, because it too needs to be traverse backwards, to compare its elements against `self` from back to front.

### Complexity

O(*m*), where *m* is the lesser of the length of the collection and the length of `possibleSuffix`.

### Naming

The function's name resembles that of an existing Swift function 
`starts(with:)`, which performs same operation however in the forward direction 
of the collection.
