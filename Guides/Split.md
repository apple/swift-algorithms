# Split

[[Source](https://github.com/apple/swift-algorithms/blob/main/Sources/Algorithms/Split.swift) | 
 [Tests](https://github.com/apple/swift-algorithms/blob/main/Tests/SwiftAlgorithmsTests/SplitTests.swift)]

Lazily-evaluating versions of
[`split(maxSplits:omittingEmptySubsequences:whereSeparator:)`](https://developer.apple.com/documentation/swift/sequence/3128814-split)
and [`split(separator:maxSplits:omittingEmptySubsequences:)`](https://developer.apple.com/documentation/swift/sequence/3128818-split),
performing the same operation as their counterparts defined on
`Sequence` and `Collection`, are added to `LazySequence` and
`LazyCollection`. The `LazyCollection` methods allow splitting a
collection without allocating additional storage on the heap.

```swift
// Splitting a lazy sequence.
let numbers = stride(from: 1, through: 16, by: 1)
for subsequence in numbers.lazy.split(
    whereSeparator: { $0 % 3 == 0 || $0 % 5 == 0 }
) {
    print(subsequence)
}
/* Prints:
[1, 2]
[4]
[7, 8]
[11]
[13, 14]
[16]
*/

// Splitting a lazy collection.
let line = "BLANCHE:   I don't want realism. I want magic!"
for subsequence in line.lazy.split(separator: " ") {
    print(subsequence)
}
/* Prints
BLANCHE:
I
don't
want
realism.
I
want
magic!
*/
```

## Detailed Design

`LazySequence` and `LazyCollection` are each extended with
`split(maxSplits:omittingEmptySubsequences:whereSeparator:)` and
`split(separator:maxSplits:omittingEmptySubsequences:)`.

The `LazySequence` versions of those methods return an instance of
`SplitSequence`. The `LazyCollection` versions return an instance of
`SplitCollection`.

`SplitSequence` wraps the sequence to be split, and provides an iterator whose
`next` method returns a newly-allocated array containing the elements of each
subsequence in the split sequence in turn.

`SplitCollection` wraps the collection to be split. Its `Index` wraps a range of 
base collection indices. `startIndex` is computed at initialization.
Subscripting a `SplitCollection` instance returns the slice of the original 
collection which is the subsequence of the split collection at the given index's 
position.

### Complexity

Iterating a `SplitSequence` instance is O(_n_) in time and space, since each 
subsequence returned is a newly-allocated array.

Iterating a `SplitCollection` instance is O(_n_) in time and O(1) in space, 
since each subsequence returned is a slice of the base collection. Since 
`startIndex` is computed at initialization, some or all of the time cost may be 
paid at initialization. For example, if the base collection contains no elements 
determined to be separators, it will be iterated entirely on initialization of 
the split collection, and all subsequent operations on the split collection, 
such as `index(after:)`, will have complexity O(1).
