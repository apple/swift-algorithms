# Partial Sort (sortedPrefix)

[[Source](https://github.com/apple/swift-algorithms/blob/main/Sources/Algorithms/PartialSort.swift) | 
 [Tests](https://github.com/apple/swift-algorithms/blob/main/Tests/SwiftAlgorithmsTests/PartialSortTests.swift)]

Returns the first k elements of this collection when it's sorted.

If you need to sort a collection but only need access to a prefix of its
elements, using this method can give you a performance boost over sorting 
the entire collection. The order of equal elements is guaranteed to be
preserved.

```swift
let numbers = [7,1,6,2,8,3,9]
let smallestThree = numbers.sortedPrefix(<)
// [1, 2, 3]
```

## Detailed Design

This adds the `Collection` method shown below:

```swift
extension Collection {
    public func sortedPrefix(_ count: Int, by areInIncreasingOrder: (Element, Element) throws -> Bool) rethrows -> [Element]
}
```

Additionally, a version of this method for `Comparable` types is also provided:

```swift
extension Collection where Element: Comparable {
    public func sortedPrefix(_ count: Int) -> [Element]
}
```

### Complexity

The algorithm used is based on [Soroush Khanlou's research on this matter](https://khanlou.com/2018/12/analyzing-complexity/). The total complexity is `O(k log k + nk)`, which will result in a runtime close to `O(n)` if k is a small amount. If k is a large amount (more than 10% of the collection), we fallback to sorting the entire array. Realistically, this means the worst case is actually `O(n log n)`.

Here are some benchmarks we made that demonstrates how this implementation (SmallestM) behaves when k increases (before implementing the fallback):

![Benchmark](https://i.imgur.com/F5UEQnl.png)
![Benchmark 2](https://i.imgur.com/Bm9DKRc.png)

### Comparison with other languages

**C++:** The `<algorithm>` library defines a `partial_sort` function where the entire array is returned using a partial heap sort.

**Python:** Defines a `heapq` priority queue that can be used to manually 
achieve the same result.

