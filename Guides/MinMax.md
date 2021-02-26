# Min/Max with Count

[[Source](https://github.com/apple/swift-algorithms/blob/main/Sources/Algorithms/MinMax.swift) | 
 [Tests](https://github.com/apple/swift-algorithms/blob/main/Tests/SwiftAlgorithmsTests/MinMaxTests.swift)]

Returns the smallest or largest elements of this collection, sorted by a predicate or in the order defined by `Comparable` conformance.

If you need to sort a collection but only need access to a prefix or suffix of the sorted elements, using these methods can give you a performance boost over sorting the entire collection. The order of equal elements is guaranteed to be preserved.

```swift
let numbers = [7, 1, 6, 2, 8, 3, 9]
let smallestThree = numbers.min(count: 3, sortedBy: <)
// [1, 2, 3]
```

## Detailed Design

This adds the `Collection` methods shown below:

```swift
extension Collection {
    public func min(
        count: Int, 
        sortedBy areInIncreasingOrder: (Element, Element) throws -> Bool
    ) rethrows -> [Element]
    
    public func max(
        count: Int, 
        sortedBy areInIncreasingOrder: (Element, Element) throws -> Bool
    ) rethrows -> [Element]
}
```

Additionally, versions of these methods for `Comparable` types are also provided:

```swift
extension Collection where Element: Comparable {
    public func min(count: Int) -> [Element]

    public func max(count: Int) -> [Element]
}
```

### Complexity

The algorithm used is based on [Soroush Khanlou's research on this matter](https://khanlou.com/2018/12/analyzing-complexity/). The total complexity is `O(k log k + nk)`, which will result in a runtime close to `O(n)` if *k* is a small amount. If *k* is a large amount (more than 10% of the collection), we fall back to sorting the entire array. Realistically, this means the worst case is actually `O(n log n)`.

Here are some benchmarks we made that demonstrates how this implementation (SmallestM) behaves when *k* increases (before implementing the fallback):

![Benchmark](Resources/SortedPrefix/FewElements.png)
![Benchmark 2](Resources/SortedPrefix/ManyElements.png)

### Comparison with other languages

**C++:** The `<algorithm>` library defines a `partial_sort` function where the entire array is returned using a partial heap sort.

**Python:** Defines a `heapq` priority queue that can be used to manually achieve the same result.

