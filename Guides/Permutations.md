# Permutations

[[Source](https://github.com/apple/swift-algorithms/blob/main/Sources/Algorithms/Permutations.swift) | 
 [Tests](https://github.com/apple/swift-algorithms/blob/main/Tests/SwiftAlgorithmsTests/PermutationsTests.swift)]

A type that computes permutations of a collection’s elements, or of a subset of
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

## Detailed Design

The `permutations(ofCount:)` method is declared as a `Collection` extension,
and returns a `Permutations` type:

```swift
extension Collection {
    public func permutations(ofCount k: Int? = nil) -> Permutations<Self>
}
```

Since the `Permutations` type needs to store an array of the collection’s
indices and mutate the array to generate each permutation, `Permutations` only
has `Sequence` conformance. Adding `Collection` conformance would require
storing the array in the index type, which would in turn lead to copying the
array at every index advancement. `Combinations` does conform to
`LazySequenceProtocol` when the base type conforms.

### Complexity

Calling `permutations()` is an O(1) operation. Creating the iterator for a
`Permutations` instance and each call to `Permutations.Iterator.next()` is an
O(_n_) operation.

### Naming

See the ["Naming" section for `combinations(ofCount:)`](Combinations.md#naming) for detail.

### Comparison with other languages

**C++:** The `<algorithm>` library defines a `next_permutation` function that
advances an array of comparable values through their lexicographic orderings.
This function is tricky to use and understand, so while it’s included in
`swift-algorithms` as an implementation detail of the `Permutations` type, it
isn’t public.

**Rust/Ruby/Python:** Rust, Ruby, and Python all define functions with
essentially the same semantics as the method described here.
