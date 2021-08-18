# Swift Algorithms

**Swift Algorithms** is an open-source package of sequence and collection algorithms, along with their related types.

Read more about the package, and the intent behind it, in the [announcement on swift.org](https://swift.org/blog/swift-algorithms/).

## Contents

#### Combinations / permutations

- [`combinations(ofCount:)`](https://github.com/apple/swift-algorithms/blob/main/Guides/Combinations.md): Combinations of particular sizes of the elements in a collection.
- [`permutations(ofCount:)`](https://github.com/apple/swift-algorithms/blob/main/Guides/Permutations.md): Permutations of a particular size of the elements in a collection, or of the full collection.
- [`uniquePermutations(ofCount:)`](https://github.com/apple/swift-algorithms/blob/main/Guides/Permutations.md): Permutations of a collection's elements, skipping any duplicate permutations.

#### Mutating algorithms

- [`rotate(toStartAt:)`, `rotate(subrange:toStartAt:)`](https://github.com/apple/swift-algorithms/blob/main/Guides/Rotate.md): In-place rotation of elements.
- [`stablePartition(by:)`, `stablePartition(subrange:by:)`](https://github.com/apple/swift-algorithms/blob/main/Guides/Partition.md): A partition that preserves the relative order of the resulting prefix and suffix.

#### Combining collections

- [`chain(_:_:)`](https://github.com/apple/swift-algorithms/blob/main/Guides/Chain.md): Concatenates two collections with the same element type. 
- [`cycled()`, `cycled(times:)`](https://github.com/apple/swift-algorithms/blob/main/Guides/Cycle.md): Repeats the elements of a collection forever or a set number of times.
- [`joined(by:)`](https://github.com/apple/swift-algorithms/blob/main/Guides/Joined.md): Concatenate sequences of sequences, using an element or sequence as a separator, or using a closure to generate each separator. 
- [`product(_:_:)`](https://github.com/apple/swift-algorithms/blob/main/Guides/Product.md): Iterates over all the pairs of two collections; equivalent to nested `for`-`in` loops.

#### Subsetting operations

- [`compacted()`](https://github.com/apple/swift-algorithms/blob/main/Guides/Compacted.md): Drops the `nil`s from a sequence or collection, unwrapping the remaining elements.
- [`randomSample(count:)`, `randomSample(count:using:)`](https://github.com/apple/swift-algorithms/blob/main/Guides/RandomSampling.md): Randomly selects a specific number of elements from a collection.
- [`randomStableSample(count:)`, `randomStableSample(count:using:)`](https://github.com/apple/swift-algorithms/blob/main/Guides/RandomSampling.md): Randomly selects a specific number of elements from a collection, preserving their original relative order.
- [`striding(by:)`](https://github.com/apple/swift-algorithms/blob/main/Guides/Stride.md): Returns every nth element of a collection.
- [`suffix(while:)`](https://github.com/apple/swift-algorithms/blob/main/Guides/Suffix.md): Returns the suffix of a collection where all element pass a given predicate.
- [`trimmingPrefix(while:)`, `trimmingSuffix(while)`, `trimming(while:)`](https://github.com/apple/swift-algorithms/blob/main/Guides/Trim.md): Returns a slice by trimming elements from a collection's start, end, or both. The mutating `trim...` methods trim a collection in place.
- [`uniqued()`, `uniqued(on:)`](https://github.com/apple/swift-algorithms/blob/main/Guides/Unique.md): The unique elements of a collection, preserving their order.
- [`minAndMax()`, `minAndMax(by:)`](https://github.com/apple/swift-algorithms/blob/main/Guides/MinMax.md): Returns the smallest and largest elements of a sequence.

#### Partial sorting

- [`min(count:)`, `max(count:)`, `min(count:sortedBy:)`, `max(count:sortedBy:)`](https://github.com/apple/swift-algorithms/blob/main/Guides/MinMax.md): Returns the smallest or largest elements of a collection, sorted by a predicate.

#### Other useful operations

- [`adjacentPairs()`](https://github.com/apple/swift-algorithms/blob/main/Guides/AdjacentPairs.md): Lazily iterates over tuples of adjacent elements.
- [`chunked(by:)`, `chunked(on:)`, `chunks(ofCount:)`](https://github.com/apple/swift-algorithms/blob/main/Guides/Chunked.md): Eager and lazy operations that break a collection into chunks based on either a binary predicate or when the result of a projection changes or chunks of a given count.
- [`firstNonNil(_:)`](https://github.com/apple/swift-algorithms/blob/main/Guides/FirstNonNil.md): Returns the first non-`nil` result from transforming a sequence's elements.
- [`indexed()`](https://github.com/apple/swift-algorithms/blob/main/Guides/Indexed.md): Iterate over tuples of a collection's indices and elements. 
- [`interspersed(with:)`](https://github.com/apple/swift-algorithms/blob/main/Guides/Intersperse.md): Place a value between every two elements of a sequence.
- [`partitioningIndex(where:)`](https://github.com/apple/swift-algorithms/blob/main/Guides/Partition.md): Returns the starting index of the partition of a collection that matches a predicate.
- [`reductions(_:)`, `reductions(_:_:)`](https://github.com/apple/swift-algorithms/blob/main/Guides/Reductions.md): Returns all the intermediate states of reducing the elements of a sequence or collection.
- [`split(maxSplits:omittingEmptySubsequences:whereSeparator)`, `split(separator:maxSplits:omittingEmptySubsequences)`](https://github.com/apple/swift-algorithms/blob/main/Guides/Split.md): Lazy versions of the Standard Library's eager operations that split sequences and collections into subsequences separated by the specified separator element.
- [`windows(ofCount:)`](https://github.com/apple/swift-algorithms/blob/main/Guides/Windows.md): Breaks a collection into overlapping subsequences where elements are slices from the original collection.

## Adding Swift Algorithms as a Dependency

To use the `Algorithms` library in a SwiftPM project, 
add the following line to the dependencies in your `Package.swift` file:

```swift
.package(url: "https://github.com/apple/swift-algorithms", from: "0.0.1"),
```

Because `Algorithms` is under active development,
source-stability is only guaranteed within minor versions (e.g. between `0.0.3` and `0.0.4`).
If you don't want potentially source-breaking package updates,
use this dependency specification instead:

```swift
.package(url: "https://github.com/apple/swift-algorithms", .upToNextMinor(from: "0.1.0")),
```

Finally, include `"Algorithms"` as a dependency for your executable target:

```swift
let package = Package(
    // name, platforms, products, etc.
    dependencies: [
        .package(url: "https://github.com/apple/swift-algorithms", from: "0.1.0"),
        // other dependencies
    ],
    targets: [
        .target(name: "<target>", dependencies: [
            .product(name: "Algorithms", package: "swift-algorithms"),
        ]),
        // other targets
    ]
)
```
