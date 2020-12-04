# Deltas

[[Source](../Sources/Algorithms/Deltas.swift) | 
 [Tests](../Tests/SwiftAlgorithmsTests/DeltasTests.swift)]

Generates a sequence mapping all non-last elements of the source sequence to
the distance between the element and its successor, using a given closure to
evaluate the metric.

```swift
let numbers = [1, 3, 12, 60].deltas(via: /)
// numbers == [3, 4, 5]

let letterSkips = "ABCDE".unicodeScalars.lazy.deltas { $0.value - $1.value }
// Array(letterSkips) == [1, 1, 1, 1]

let empty = CollectionOfOne(3.3).deltas(via: -)
// empty == []
```

To return any distances, the source sequence needs to be at least two elements
in length.

## Detailed Design

A new method is added to sequences, with an overload for laziness:

```swift
extension Sequence {
    func deltas<T>(
        via subtracter: (Element, Element) throws -> T
    ) rethrows -> [T]
}

extension LazySequenceProtocol {
    func deltas<T>(
        via subtracter: @escaping (Element, Element) -> T
    ) -> DeltasSequence<Elements, T>
}
```

The eager version of `deltas(via:)` copies the distances to a standard-library
`Array`.  The lazy version encapsulates the distances into a new
`DeltasSequence` generic value type, parameterized on the source sequence's
type and the distance type.  This type conforms to `Sequence` and
`LazySequenceProtocol`, escalating to `Collection` and `LazyCollectionProtocol`
if the source sequence type is also a collection type, and to
`BidirectionalCollection` and `RandomAccessCollection` if the source type
conforms too.

The standard library contains several protocols that can provide common metric
functions.  Variants of `deltas(via:)` have been made that use the standard
library routines, assuming that the source sequence's element type conforms to
the prerequiste protocol.

```swift
extension Sequence where Element: AdditiveArithmetic {
    func differences() -> DeltasSequence<Self, Element>
}

extension Sequence where Element: SIMD, Element.Scalar: FloatingPoint {
    func differences() -> DeltasSequence<Self, Element>
}

extension Sequence where Element: FixedWidthInteger {
    func wrappedDifferences() -> DeltasSequence<Self, Element>
}

extension Sequence where Element: SIMD, Element.Scalar: FixedWidthInteger {
    func wrappedDifferences() -> DeltasSequence<Self, Element>
}

extension Sequence where Element: Strideable {
    func strides() -> DeltasSequence<Self, Element.Stride>
}
```

The `differences()` methods use the `-` operator.  The `wrappedDifferences()`
methods use the `&-` operator.  And the `strides()` method uses the
`.distance(to:)` method.  Note all of these methods return a lazily generated
sequence/collection, since the core methods are non-throwing.

### Complexity

Calling the eager version of `deltas(via:)` is O(_n_), where _n_ is the length
of the source sequence.  The lazy version, and its protocol-based metric
variants, are all O(_1_) to initially call, but O(_n_) again for running
through a single pass of the results.

### Naming

The name (as of this writing) for the core method is original by the author,
inspired by the use of "delta" in other computer-science contexts related to
changes.  If there are terms-of-art for the concept, suggestions will be
appreciated.  The names for the protocol-based metric variants are based on the
descriptions of their return values or types.

### Comparison with other languages

**Swift:** The `deltas(via:)` method is the counter operation to the `scan(_:)`
method, which acts like `reduce(_:_:)` but provides not only the final
combination but the intermediate results, all packaged as a sequence.  There is
a version of `scan` in the "Combine" library of Apple's SDK, but a non-Reactive
version has not (yet) appeared in the standard library.

**[C++][C++]:** Has an `adjacent_difference` function which takes a bounding
input iterator pair, an output iterator, and optionally a metric function
(which defaults to subtraction when not given), returning the updated output
iterator.  It restricts the metric function to use parameter and return types
that are compatible with the input iterator's element type.  (The output
iterator's element type must also be compatible.)

<!-- Link references for other languages -->

[C++]: https://en.cppreference.com/w/cpp/algorithm/adjacent_difference
