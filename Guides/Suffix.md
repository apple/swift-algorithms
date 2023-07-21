# Suffix

[[Source](https://github.com/apple/swift-algorithms/blob/main/Sources/Algorithms/Suffix.swift) |
 [Tests](https://github.com/apple/swift-algorithms/blob/main/Tests/SwiftAlgorithmsTests/SuffixTests.swift)]

This function returns a subsequence containing the elements from the end of the 
collection until predicate returns `false` and skipping the remaining elements.

This example uses `suffix(while: )` to iterate through collection of integers 
from the end until the predicate returns false, in this case when `$0 <= 5`
```swift
(0...10).suffix(while: { $0 > 5 } // == [6,7,8,9,10]
```

## Detailed Design

The `suffix(while:)` function is added as a method on an extension of 
`BidirectionalCollection`.

```swift
extension BidirectionalCollection {
    public func suffix(while predicate: (Element) throws -> Bool) rethrows -> SubSequence
}
```

This method requires `BidirectionalCollection` for an efficient implementation 
which visits as few elements as possible. Swift's protocol allows for backward 
traversal of a collection as well as access to *last* property of a collection.

### Complexity

Calling this method is O(*n*), where *n* is the length of the collection.

### Naming

The function's name resembles that of an existing Swift function 
`prefix(while:)`, which performs same operation however in the forward direction 
of the collection. Hence, as this function traverses from the end of the 
collection, `suffix(while:)` is an appropriate name.
