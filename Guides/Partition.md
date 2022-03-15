# Partition

[[Source](https://github.com/apple/swift-algorithms/blob/main/Sources/Algorithms/Partition.swift) | 
 [Tests](https://github.com/apple/swift-algorithms/blob/main/Tests/SwiftAlgorithmsTests/PartitionTests.swift)]

Methods for performing a stable partition on mutable collections, and for 
finding the partitioning index in an already partitioned collection.

The standard library’s existing `partition(by:)` method, which re-orders the
elements in a collection into two partitions based on a given predicate, doesn’t
guarantee stability for either partition. That is, the order of the elements in
each partition doesn’t necessarily match their relative order in the original
collection. These new methods expand on the existing `partition(by:)` by
providing stability for one or both partitions.

```swift
// existing partition(by:) - unstable ordering
var numbers = [10, 20, 30, 40, 50, 60, 70, 80]
let p1 = numbers.partition(by: { $0.isMultiple(of: 20) })
// p1 == 4
// numbers == [10, 70, 30, 50, 40, 60, 20, 80]

// new stablePartition(by:) - keeps the relative order of both partitions
numbers = [10, 20, 30, 40, 50, 60, 70, 80]
let p2 = numbers.stablePartition(by: { $0.isMultiple(of: 20) })
// p2 == 4
// numbers == [10, 30, 50, 70, 20, 40, 60, 80]
```

Since partitioning is frequently used in divide-and-conquer algorithms, we also
include a variant that accepts a range parameter to avoid copying when mutating
slices, as well as a range-based variant of the existing standard library
partition.

The  `partitioningIndex(where:)` method returns the index of the start of the
second partition when called on an already partitioned collection.

```swift
let numbers = [10, 30, 50, 70, 20, 40, 60]
let p = numbers.partitioningIndex(where: { $0.isMultiple(of: 20) })
// numbers[..<p] == [10, 30, 50, 70]
// numbers[p...] = [20, 40, 60]
```

The standard library’s existing `filter(_:)` method provides functionality to
get the elements that do match a given predicate. `partitioned(by:)` returns
both the elements that match the predicate as well as those that don’t, as a
tuple.

```swift
let cast = ["Vivien", "Marlon", "Kim", "Karl"]
let (longNames, shortNames) = cast.partitioned(by: { $0.count < 5 })
print(longNames)
// Prints "["Vivien", "Marlon"]"
print(shortNames)
// Prints "["Kim", "Karl"]"
```

## Detailed Design

All mutating methods are declared as extensions to `MutableCollection`.
The `partitioningIndex(where:)` method is available on any `Collection` type.

```swift
extension MutableCollection {
    mutating func stablePartition(
        by belongsInSecondPartition: (Element) throws -> Bool
    ) rethrows -> Index

    mutating func stablePartition(
        subrange: Range<Index>,
        by belongsInSecondPartition: (Element) throws -> Bool
    ) rethrows -> Index

    mutating func partition(
        subrange: Range<Index>,
        by belongsInSecondPartition: (Element) throws -> Bool
    ) rethrows -> Index
}

extension Collection {
    func partitioningIndex(
        where belongsInSecondPartition: (Element) throws -> Bool
    ) rethrows -> Index
}

extension Sequence {
    public func partitioned(
        by predicate: (Element) throws -> Bool
    ) rethrows -> (falseElements: [Element], trueElements: [Element])
}
```

### Complexity

The existing partition is an O(_n_) operation, where _n_ is the length of the
range to be partitioned, while the stable partition is O(_n_ log _n_). Both
partitions have algorithms with improved performance for bidirectional
collections, so it would be ideal for those to be customization points were they
to eventually land in the standard library.

`partitioningIndex(where:)` is a slight generalization of a binary search, and
is an O(log _n_) operation for random-access collections; O(_n_) otherwise.

`partitioned(by:)` is an O(_n_) operation, where _n_ is the number of elements
in the original sequence.

### Comparison with other languages

**C++:** The `<algorithm>` library defines `partition`, `stable_partition`, and
`partition_point` functions with similar semantics to these. Notably, in the C++
implementation, the result of partitioning has the opposite polarity, with the
passing elements in the first partition and failing elements in the second.

**Rust:** Rust includes the `partition` method, which returns separate
collections of passing and failing elements, and `partition_in_place`, which
matches the Swift standard library’s existing `partition(by:)` method.
