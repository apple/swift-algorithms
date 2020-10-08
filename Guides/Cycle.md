# Cycle

[[Source](https://github.com/apple/swift-algorithms/blob/main/Sources/Algorithms/Cycle.swift) | 
 [Tests](https://github.com/apple/swift-algorithms/blob/main/Tests/SwiftAlgorithmsTests/CycleTests.swift)]

Iterate over a collection forever, or a set number of times.

```swift
for (odd, n) in zip([true, false].cycled(), 1...) {
    // ...
}

for x in (1...3).cycled(times: 3) {
    print(x)
}
// Prints 1 through 3 three times
```

`cycled(times:)` combines two other existing standard library functions
(`repeatElement` and `joined`) to provide a more expressive way of repeating a
collection's elements a limited number of times.

## Detailed Design

Two new methods are added to collections:

```swift
extension Collection {
    func cycled() -> Cycle<Self>

    func cycled(times: Int) -> FlattenSequence<Repeated<Self>>
}
```

The new `Cycle` type is a sequence only, given that the `Collection` protocol
design makes infinitely large types impossible/impractical. Note that despite
its name, the returned `FlattenSequence` will always have `Collection`
conformance, and will have `BidirectionalCollection` conformance when called on
a bidirectional collection.

### Complexity

Calling these methods is O(_1_).

### Naming

There's a slight off-by-one ambiguity around the naming of `cycled(times:)`,
since one can reasonably interpret the number of cycles as including the first
run-through of elements (the actual semantics) or starting after the first 
set. This ambiguity is present in all the different potential names for this
function: `repeated(times:)`, `cycled(repetitions:)`, etc.

### Comparison with other langauges

**Rust:** The `cycle` method repeats an iterator's elements forever. I don’t see
anything that matches the `cycled(times:)` behavior.

**Ruby:** Passing a number to `cycle` limits the number of repetitions, like the
`cycled(times:)` here.

**Python:** Python’s `itertools` includes a `cycle` method, which caches the
elements of the iterator on the first pass.