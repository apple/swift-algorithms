# Bifurcate

[[Source](https://github.com/apple/swift-algorithms/blob/main/Sources/Algorithms/Bifurcate.swift) | 
 [Tests](https://github.com/apple/swift-algorithms/blob/main/Tests/SwiftAlgorithmsTests/BifurcateTests.swift)]

Methods for splitting a sequence in two.

The standard library’s existing `filter(_:)` method provides similar functionality, but only returns the elements that match the predicate (returning `true`). `bifurcate(_:)` returns both the elements that match the preciate as well as those that don’t, as a tuple.

```swift
let cast = ["Vivien", "Marlon", "Kim", "Karl"]
let (shortNames, longNames) = cast.bifurcate({ $0.count < 5 })
print(shortNames)
// Prints "["Kim", "Karl"]"
print(longNames)
// Prints "["Vivien", "Marlon"]"
```

There’s also a function to bifurcate a collection into a prefix and a suffix, up to but not including a given index:

```swift
let cast = ["Vivien", "Marlon", "Kim", "Karl"]
let (callbacks, alternates) = cast.bifurcate(upTo: 2)
print(callbacks)
// Prints "["Vivien", "Marlon"]"
print(alternates)
// Prints "["Kim", "Karl"]"
```

## Detailed Design

The primary method is declared as an extension to `Sequence`, but has an optimized version for `Collection`.

```swift
extension Sequence {
	public func bifurcate(_ belongsInFirstCollection: (Element) throws -> Bool) rethrows -> ([Element], [Element])
}
```

The other function is an extension to `Collection`, as it works with indices.

```swift
extension Collection {
	public func bifurcate(upTo index: Index) -> (SubSequence, SubSequence)
}
```

### Complexity and Performance

`bifurcate(_:)` is an O(_n_) operation, where _n_ is the number of elements in the original sequence.

`bifurcate(upTo:)` is an O(_1_) operation.

Bifurcate is more efficient than calling `filter(_:)` twice with mutually-exclusive predicates (negatated) for two reasons:

1. It only requires a single pass through the elements.

2. When operating on a `Collection`, since the combined size of the two returned arrays is equal to the size of the original collection, the output buffer can be created and avoid needing to be resized.

If you ever find yourself calling `filter(_:)` and also needing the elements that didn’t match the predicate, `bifurcate(_:)` is the optimal choice. When testing with compiler optimizations enabled (`-O`, `-Ofast`), the results are consistantly faster, taking less than half the time (between 33–45%).
