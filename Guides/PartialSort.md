# Partial Sort

[[Source](https://github.com/apple/swift-algorithms/blob/main/Sources/Algorithms/PartialSort.swift) | 
 [Tests](https://github.com/apple/swift-algorithms/blob/main/Tests/SwiftAlgorithmsTests/PartialSortTests.swift)]

Returns a collection such that the `0...k` range contains the first k sorted elements of a sequence. 
The order of equal elements is not guaranteed to be preserved, and the order of the remaining elements is unspecified.

If you need to sort a sequence but only need access to a prefix of its elements, 
using this method can give you a performance boost over sorting the entire sequence.

```swift
let numbers = [7,1,6,2,8,3,9]
let almostSorted = numbers.partiallySorted(3, <)
// [1, 2, 3, 9, 7, 6, 8]
```

## Detailed Design

This adds the in place `MutableCollection` method shown below:

```swift
extension Sequence {
    func partiallySort(_ count: Int, by areInIncreasingOrder: (Element, Element) throws -> Bool) rethrows
}
```

Additionally, versions of this method that return a new array and abstractions for `Comparable` types are also provided:

```swift
extension MutableCollection where Self: RandomAccessCollection, Element: Comparable {
    public mutating func partiallySort(_ count: Int)
}

extension Sequence {
    public func partiallySorted(_ count: Int, by areInIncreasingOrder: (Element, Element) throws -> Bool) rethrows -> [Element]
}

extension Sequence where Element: Comparable {
    public func partiallySorted(_ count: Int) -> [Element]
}
```

### Complexity

Partially sorting is a O(_k log n_) operation, where _k_ is the number of elements to sort
and _n_ is the length of the sequence.

`partiallySort(_:by:)` is a slight generalization of a priority queue. It's implemented
as an in line heapsort that stops after _k_ runs.

### Comparison with other languages

**C++:** The `<algorithm>` library defines a `partial_sort` function with similar
semantics to this one.

**Python:** Defines a `heapq` priority queue that can be used to manually 
achieve the same result.

