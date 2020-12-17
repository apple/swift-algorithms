# Copy

[[Source](../Sources/Algorithms/Copy.swift) |
 [Tests](../Tests/SwiftAlgorithmsTests/CopyTests.swift)]

Copy a sequence onto an element-mutable collection.

```swift
var destination = [1, 2, 3, 4, 5]
let source = [6, 7, 8, 9, 10]
print(destination)  // "[1, 2, 3, 4, 5]

let (_, sourceSuffix) = destination.copy(from: source)
print(destination)  // "[6, 7, 8, 9, 10]"
print(Array(IteratorSequence(sourceSuffix)))  // "[]"
```

`copy(from:)` takes a source sequence and overlays its first *k* elements'
values over the first `k` elements of the receiver, where `k` is the smaller of
the two sequences' lengths.  The `copy(collection:)` variant uses a collection
for the source sequence.

## Detailed Design

New methods are added to element-mutable collections:

```swift
extension MutableCollection {
  mutating func copy<S: Sequence>(from source: S)
   -> (copyEnd: Index, sourceTail: S.Iterator) where S.Element == Element

  mutating func copy<C>(collection: C)
   -> (copyEnd: Index, sourceTailStart: C.Index)
   where C : Collection, Self.Element == C.Element
}
```

The methods return two values.  The first member is the index of the receiver
defining the non-anchored endpoint of the elements that were actually written
over.  The second member is for reading the suffix of the source that wasn't
actually used.

### Complexity

Calling these methods is O(_k_), where _k_ is the length of the shorter
sequence between the receiver and `source`.

### Naming

This method’s name matches the term of art used in other languages and
libraries.

### Comparison with other languages

**C++:** Has a [`copy`][C++Copy] function in the `algorithm` library that takes
a bounding pair of input iterators for the source and a single output iterator
for the destination, returning one-past the last output iterator written over.
The `copy_if` function does not have an analogue, since it can be simulated by
submitting the result from `filter(_:)` as the source.

<!-- Link references for other languages -->

[C++Copy]: https://en.cppreference.com/w/cpp/algorithm/copy
