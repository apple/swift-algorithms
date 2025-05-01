# Sorted Duplicates
[[Source](https://github.com/apple/swift-algorithms/blob/main/Sources/Algorithms/SortedDuplicates.swift) |
 [Tests](https://github.com/apple/swift-algorithms/blob/main/Tests/SwiftAlgorithmsTests/SortedDuplicatesTests.swift)]

Being a given a sequence that is already sorted, recognize each run of
identical values.
Use that to determine the length of each identical-value run of
identical values.
Or filter out the duplicate values by removing all occurances of
a given value besides the first.

```swift
// Put examples here
```

## Detailed Design

```swift
extension Sequence {
    public func countSortedDuplicates(
        by areInIncreasingOrder: (Element, Element) throws -> Bool
    ) rethrows -> [(value: Element, count: Int)]

    public func withoutSortedDuplicates(
        by areInIncreasingOrder: (Element, Element) throws -> Bool
    ) rethrows -> [Element]
}

extension Sequence where Self.Element : Comparable {
    public func countSortedDuplicates() -> [(value: Element, count: Int)]

    public func withoutSortedDuplicates() -> [Element]
}

extension LazySequenceProtocol {
    public func countSortedDuplicates(
        by areInIncreasingOrder: @escaping (Element, Element) -> Bool
    ) -> LazyCountDuplicatesSequence<Elements>

    public func withoutSortedDuplicates(
        by areInIncreasingOrder: @escaping (Element, Element) -> Bool
    ) -> some (Sequence<Element> & LazySequenceProtocol)
}

extension LazySequenceProtocol where Self.Element : Comparable {
    public func countSortedDuplicates()
     -> LazyCountDuplicatesSequence<Elements>

    public func withoutSortedDuplicates()
     -> some (Sequence<Element> & LazySequenceProtocol)
}

public struct LazyCountDuplicatesSequence<Base: Sequence>
    : LazySequenceProtocol
{ /*...*/ }

public struct CountDuplicatesIterator<Base: IteratorProtocol>
    : IteratorProtocol
{ /*...*/ }
```

### Complexity

Calling the lazy methods, those defined on `LazySequenceProtocol`, is O(_1_).
Calling the eager methods, those returning an array, is O(_n_).
