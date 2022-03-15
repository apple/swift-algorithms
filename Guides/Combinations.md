# Combinations

[[Source](https://github.com/apple/swift-algorithms/blob/main/Sources/Algorithms/Combinations.swift) | 
 [Tests](https://github.com/apple/swift-algorithms/blob/main/Tests/SwiftAlgorithmsTests/CombinationsTests.swift)]

A type that computes combinations of a collection’s elements.

The `combinations(ofCount:)` method returns a sequence of all the different
combinations of a collection’s elements, with each combination in the order of
the original collection.

```swift
let numbers = [10, 20, 30, 40]
for combo in numbers.combinations(ofCount: 2) {
    print(combo)
}
// [10, 20]
// [10, 30]
// [10, 40]
// [20, 30]
// [20, 40]
// [30, 40]
```

The combinations of elements are presented in increasing lexicographic order of
the collection’s original ordering. Values that are repeated in the original
collection are always treated as separate values in the resulting combinations:

```swift
let numbers2 = [20, 10, 10]
for combo in numbers2.combinations(ofCount: 2) {
    print(combo)
}
// [20, 10]
// [20, 10]
// [10, 10]
```

Given a range, the `combinations(ofCount:)` method returns a sequence of all
the different combinations of the given sizes of a collection’s elements in
increasing order of size.

```swift
let numbers = [10, 20, 30, 40]
for combo in numbers.combinations(ofCount: 2...3) {
    print(combo)
}
// [10, 20]
// [10, 30]
// [10, 40]
// [20, 30]
// [20, 40]
// [30, 40]
// [10, 20, 30]
// [10, 20, 40]
// [10, 30, 40]
// [20, 30, 40]
```

## Detailed Design

The `combinations(ofCount:)` method is declared as a  `Collection` extension,
and returns a `CombinationsSequence` type:

```swift
extension Collection {
    public func combinations(ofCount k: Int) -> CombinationsSequence<Self>
}
```

Since the `CombinationsSequence` type needs to store an array of the
collection’s indices and mutate the array to generate each permutation,
`CombinationsSequence` only has `Sequence` conformance. Adding `Collection` 
conformance would require storing the array in the index type, which would in 
turn lead to copying the array at every index advancement.
`CombinationsSequence` does conform to `LazySequenceProtocol` when the base type
conforms.

### Complexity

Calling `combinations(ofCount:)` accesses the count of the collection, so it’s
an O(1) operation for random-access collections, or an O(_n_) operation
otherwise. Creating the iterator for a `CombinationsSequence` instance and each
call to `CombinationsSequence.Iterator.next()` is an O(_n_) operation.

### Naming

The parameter label in `combination(ofCount:)` is the best match for the
Swift API guidelines. A few other options were considered:

- When the standard library uses `of` as a label, the parameter is generally 
  the object of the operation, as in `type(of:)` and `firstIndex(of:)`, and
  not a configuration detail.
- The `count` label typically indicates the count of the resulting collection,
  as in the `repeatElement(_:count:)` function or the `String(repeating:count:)`
  initializer.
- `k` is used a term of art for combinations and permutations, but isn't 
  widely used in programming contexts.

### Comparison with other languages

**Rust/Ruby/Python:** Rust, Ruby, and Python all define functions with
essentially the same semantics as the method described here.
