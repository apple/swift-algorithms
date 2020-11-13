# Rotate

[[Source](https://github.com/apple/swift-algorithms/blob/main/Sources/Algorithms/Rotate.swift) | 
 [Tests](https://github.com/apple/swift-algorithms/blob/main/Tests/SwiftAlgorithmsTests/RotateTests.swift)]

A mutating method that rotates the elements of a collection to new positions.

```swift
var numbers = [10, 20, 30, 40, 50, 60]
let p = numbers.rotate(toStartAt: 2)
// numbers == [30, 40, 50, 60, 10, 20]
// p == 4 -- numbers[p] == 10
```

To work around the CoW / slice mutation problem for divide-and-conquer
algorithms, which are the idiomatic use case for rotation, this also includes
variants that take a range:

```swift
var numbers = [10, 20, 30, 40, 50, 60]
numbers.rotate(subrange: 0..<3, toStartAt: 1)
// numbers = [20, 30, 10, 40, 50, 60]
numbers.rotate(subrange: 3..<6, toStartAt: 4)
// numbers = [20, 30, 10, 50, 60, 40]
```

## Detailed Design

This adds the two `MutableCollection` methods shown above:

```swift
extension MutableCollection {
    mutating func rotate(toStartAt p: Index) -> Index

    mutating func rotate(
        subrange: Range<Index>,
        toStartAt p: Index
    ) -> Index
}
```

### Complexity

Rotation is a O(_n_) operation, where _n_ is the length of the range being
rotated. The `BidirectionalCollection` version of rotation significantly lowers
the number of swaps required per element, so `rotate` would need to be a
`MutableCollection` customization point were it adopted by the standard library.

### Naming

The index parameter has been proposed as `shiftingToStart` in the past; this
version uses the `toStartAt` label, instead. `shiftingToStart` introduces the 
idea of a "shift", which can sound like shifting just that single element to the
beginning of the collection.

For the range-based overloads, the label could be omitted. That is, instead of
using `subrange:`, the method could be called as 
`numbers.rotate(0..<3, toStartAt: 2)`. The label is included here for 
consistency with other range-based mutating methods.

### Comparison with other languages

**C++:** The `<algorithm>` library defines a `rotate` function with similar
semantics to this one.

**Ruby:** You can rotate the elements of an array by a number of positions,
either forward or backward (by passing a negative number). For zero-indexed
collections, forward rotation by e.g. 3 elements is equivalent to
`rotate(toStartAt: 3)`.

