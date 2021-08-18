# Permutations

[[Source](https://github.com/apple/swift-algorithms/blob/main/Sources/Algorithms/Permutations.swift) | 
 [Tests](https://github.com/apple/swift-algorithms/blob/main/Tests/SwiftAlgorithmsTests/PermutationsTests.swift)]

Methods that compute permutations of a collection’s elements, or of a subset of
those elements.

The `permutations(ofCount:)` method, when called without the `ofCount`
parameter, returns a sequence of all the different permutations of a
collection’s elements:

```swift
let numbers = [10, 20, 30]
for perm in numbers.permutations() {
    print(perm)
}
// [10, 20, 30]
// [10, 30, 20]
// [20, 10, 30]
// [20, 30, 10]
// [30, 10, 20]
// [30, 20, 10]
```

Passing a value for `ofCount` generates partial permutations, each with the
specified number of elements:

```swift
for perm in numbers.permutations(ofCount: 2) {
    print(perm)
}
// [10, 20]
// [10, 30]
// [20, 10]
// [20, 30]
// [30, 10]
// [30, 20]
```

The permutations or partial permutations are generated in increasing
lexicographic order of the collection’s original ordering (rather than the order
of the elements themselves). The first permutation will always consist of
elements in their original order, and the last will have the elements in the
reverse of their original order.

Values that are repeated in the original collection are always treated as
separate values in the resulting permutations:

```swift
let numbers2 = [20, 10, 10]
for perm in numbers2.permutations() {
    print(perm)
}
// [20, 10, 10]
// [20, 10, 10]
// [10, 20, 10]
// [10, 10, 20]
// [10, 20, 10]
// [10, 10, 20]
```

To generate only unique permutations, use the `uniquePermutations(ofCount:)` method:

```swift
for perm in numbers2.uniquePermutations() {
    print(perm)
}
// [20, 10, 10]
// [10, 20, 10]
// [10, 10, 20]
```

Given a range, the methods return a sequence of all the different permutations of the given sizes of a collection’s elements in increasing order of size.

```swift
let numbers = [10, 20, 30]
for perm in numbers.permutations(ofCount: 0...) {
    print(perm)
}
// []
// [10]
// [20]
// [30]
// [10, 20]
// [10, 30]
// [20, 10]
// [20, 30]
// [30, 10]
// [30, 20]
// [10, 20, 30]
// [10, 30, 20]
// [20, 10, 30]
// [20, 30, 10]
// [30, 10, 20]
// [30, 20, 10]
```

## Detailed Design

The `permutations(ofCount:)` and `uniquePermutations(ofCount:)` methods are 
declared as `Collection` extensions, and return `PermutationsSequence` and 
`UniquePermutationsSequence` instances, respectively:

```swift
extension Collection {
    public func permutations(ofCount k: Int? = nil) -> PermutationsSequence<Self>
    public func permutations<R>(ofCount kRange: R) -> PermutationsSequence<Self>
        where R: RangeExpression, R.Bound == Int
}

extension Collection where Element: Hashable {
    public func uniquePermutations(ofCount k: Int? = nil) -> UniquePermutationsSequence<Self>
    public func uniquePermutations<R>(ofCount kRange: R) -> UniquePermutationsSequence<Self>
        where R: RangeExpression, R.Bound == Int
}
```

Since both result types need to store an array of the collection’s
indices and mutate the array to generate each permutation, they only
have `Sequence` conformance. Adding `Collection` conformance would require
storing the array in the index type, which would in turn lead to copying the
array at every index advancement. The `PermutationsSequence` type
conforms to `LazySequenceProtocol` when its base type conforms.

### Complexity

Calling `permutations()` is an O(1) operation. Creating the iterator for a
`Permutations` instance and each call to `Permutations.Iterator.next()` is an
O(_n_) operation.

Calling `uniquePermutations()` is an O(_n_) operation, because it preprocesses 
the collection to find duplicate elements. Creating the iterator for and each 
call to `next()` is also an O(_n_) operation.

### Naming

See the ["Naming" section for `combinations(ofCount:)`](Combinations.md#naming) for detail.

### Comparison with other languages

**C++:** The `<algorithm>` library defines a `next_permutation` function that
advances an array of comparable values through their lexicographic orderings.
This function is very similar to the `uniquePermutations(ofCount:)` method.

**Rust/Ruby/Python:** Rust, Ruby, and Python all define functions with
essentially the same semantics as the `permutations(ofCount:)` method 
described here.
