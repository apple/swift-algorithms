# Swift Algorithms

**Swift Algorithms** is an open-source package of sequence and collection algorithms, along with their related types.

Read more about the package, and the intent behind it, in the [announcement on swift.org](https://swift.org/blog/swift-algorithms/).

## Contents

#### Combinations / permutations

- [`combinations(ofCount:)`](https://github.com/apple/swift-algorithms/blob/main/Guides/Combinations.md): Combinations of a particular size of the elements in a collection.
- [`permutations(ofCount:)`](https://github.com/apple/swift-algorithms/blob/main/Guides/Permutations.md): Permutations of a particular size of the elements in a collection, or of the full collection.

#### Mutating algorithms

- [`rotate(toStartAt:)`, `rotate(subrange:toStartAt:)`](https://github.com/apple/swift-algorithms/blob/main/Guides/Rotate.md): In-place rotation of elements.
- [`stablePartition(by:)`, `stablePartition(subrange:by:)`](https://github.com/apple/swift-algorithms/blob/main/Guides/Partition.md): A partition that preserves the relative order of the resulting prefix and suffix.
- [`overwrite(prefixWith:)`, `overwrite(suffixWith:)`](./Guides/Copy.md): Copying from a sequence via overwriting elements.

#### Combining collections

- [`chain(_:_:)`](https://github.com/apple/swift-algorithms/blob/main/Guides/Chain.md): Concatenates two collections with the same element type. 
- [`product(_:_:)`](https://github.com/apple/swift-algorithms/blob/main/Guides/Product.md): Iterates over all the pairs of two collections; equivalent to nested `for`-`in` loops.
- [`cycled()`, `cycled(times:)`](https://github.com/apple/swift-algorithms/blob/main/Guides/Cycle.md): Repeats the elements of a collection forever or a set number of times.

#### Subsetting operations

- [`randomSample(count:)`, `randomSample(count:using:)`](https://github.com/apple/swift-algorithms/blob/main/Guides/RandomSampling.md): Randomly selects a specific number of elements from a collection.
- [`randomStableSample(count:)`, `randomStableSample(count:using:)`](https://github.com/apple/swift-algorithms/blob/main/Guides/RandomSampling.md): Randomly selects a specific number of elements from a collection, preserving their original relative order.
- [`uniqued()`, `uniqued(on:)`](https://github.com/apple/swift-algorithms/blob/main/Guides/Unique.md): The unique elements of a collection, preserving their order.

#### Other useful operations

- [`chunked(by:)`, `chunked(on:)`](https://github.com/apple/swift-algorithms/blob/main/Guides/Chunked.md): Eager and lazy operations that break a collection into chunks based on either a binary predicate or when the result of a projection changes.
- [`indexed()`](https://github.com/apple/swift-algorithms/blob/main/Guides/Indexed.md): Iterate over tuples of a collection's indices and elements. 
- [`trimming(where:)`](https://github.com/apple/swift-algorithms/blob/main/Guides/Trim.md): Returns a slice by trimming elements from a collection's start and end. 


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
.package(url: "https://github.com/apple/swift-algorithms", .upToNextMinor(from: "0.0.1")),
```

Finally, include `"Algorithms"` as a dependency for your executable target:

```swift
let package = Package(
    // name, platforms, products, etc.
    dependencies: [
        .package(url: "https://github.com/apple/swift-algorithms", from: "0.0.1"),
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
