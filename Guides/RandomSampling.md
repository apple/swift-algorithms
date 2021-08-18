# Random Sampling

[[Source](https://github.com/apple/swift-algorithms/blob/main/Sources/Algorithms/RandomSample.swift) | 
 [Tests](https://github.com/apple/swift-algorithms/blob/main/Tests/SwiftAlgorithmsTests/RandomSampleTests.swift)]

Operations for randomly selecting `k` elements without replacement from a
sequence or collection.

Use these methods for sampling multiple elements from a collection, optionally
maintaining the relative order of the elements. Each method has an overload that
takes a `RandomNumberGenerator` as a parameter.

```swift
var source = [10, 20, 30, 40, 50, 60, 70, 80, 90, 100]

source.randomSample(count: 4)
// e.g. [30, 10, 70, 50]
source.randomStableSample(count: 4)
// e.g. [20, 30, 80, 100]

var rng = SplitMix64(seed: 0)
source.randomSample(count: 4, using: &rng)
```

## Detailed Design

The four methods are declared as below, as well as an additional overload of the
two `randomSample(count:)` methods for `Collection`.

```swift
extension Sequence {
    func randomSample(count: Int) -> [Element]

    func randomSample<G: RandomNumberGenerator>(
        count: Int, using: inout G
    ) -> [Element]
}

extension Collection {
    func randomStableSample(count: Int) -> [Element]

    func randomStableSample<G: RandomNumberGenerator>(
        count: Int, using: inout G
    ) -> [Element]
}
```

The value passed as `count` must always be non-negative. If `count` is larger 
than the length of the collection it’s called on, then the returned array
contains all the elements of the collection.

### Related types

These methods do not rely on additional types — they eagerly select the required
number of elements and return an array.

### Complexity

The `randomSample` method uses reservoir sampling, which allows the method to be
O(_k_) when called on a random-access collection. When called on a sequence or a
non-random-access collection, the algorithm requires O(_k_) random numbers and 
accesses O(_n_) elements of the collection.

The `randomStableSample` method uses selection sampling, which is an O(_n_)
algorithm. This algorithm requires the count of the collection in advance, which
restricts its use to collections — a sequence-based version would need to save
the elements to a temporary array, which we generally don’t want to do for this
kind of operation.

### Naming

The standard library already declares `randomElement()` on `Sequence`, which
returns a single random element. The `randomSample(count:)` name is chosen to
align with `randomElement`, but be more distinguishable than something like
`randomElements`. Other names considered include `sample` and `choose`.

### Comparison with other languages

**C++:** As of C++17, the `<algorithm>` library includes a `sample` function
that provides linear performance. This algorithm is stable for all source
iterators that conform to `LegacyForwardIterator` (roughly `Collection` in
Swift), but is unstable otherwise.

**Ruby/Python:** Ruby and Python both define `sample` functions that return
either a single random element or, when you pass a count, a list of random
elements. The order of the returned elements is unstable.

## Other Considerations

### Post-sample shuffling

Simple implementations of reservoir sampling tend to return some of the initial
elements in the same order they appear in the array. To avoid this bias, the 
unstable implementation of `randomSample` explicitly shuffles the elements 
before returning them. 

To see the bias without shuffling, consider the following example that uses a
hypothetical `randomSampleUnshuffled` method. When selecting three out of 
four elements from an array, whenever any of the first three elements are 
included in the result, they are always in their original positions. Elements 
selected after the initial `count` are in randomly selected positions.

```swift
// This shows the behavior WITHOUT post-sample shuffling.
// Selecting 3/4 elements, there are only four possible outcomes:
let source = [10, 20, 30, 40]
source.randomSampleUnshuffled(count: 3)  // [10, 20, 30]
source.randomSampleUnshuffled(count: 3)  // [40, 20, 30]
source.randomSampleUnshuffled(count: 3)  // [10, 40, 30]
source.randomSampleUnshuffled(count: 3)  // [10, 20, 40]
```

The proposed `randomSample` method has no positional bias:

```swift
// The current behavior shuffles the elements, erasing the bias:
let source = [10, 20, 30, 40]
source.randomSample(count: 3)  // [20, 30, 10]
source.randomSample(count: 3)  // [40, 20, 30]
// ...several more possible outcomes
```

Since only the resulting array is shuffled, this additional reordering has an
O(_k_) performance cost.

### Reproducibility

This doesn’t address the ongoing issue of versioning RNG algorithms. It poses
the same problem as the existing high-level methods, such as
`randomElement(using:)` and `Int.random(in:using:)`, in that changes to the
sampling algorithm in future versions of the library will change the expected
output for repeatable RNGs. While we don't currently make any guarantees about 
future versions of the stdlib producing identical results, users routinely
make that assumption.

### Index-based overloads

Because none of these methods are mutating or have special behavior based on the
underlying collection type, we don’t need a separate set of methods for working
specifically with indices. A collection’s `indices` typically has the same
performance characteristics as the collection itself, so a user can call
`collection.indices.randomSample(count:)` to get a number of random indices.

### Lazy sampling

The stable version of sampling could theoretically return a lazy wrapper
instead of eagerly creating the sample. However, this isn’t well-motivated and 
poses some challenges, such as needing to store a copy of the random generator 
and potentially needing to cache the randomly-generated values.
