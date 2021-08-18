# Intersperse

[[Source](https://github.com/apple/swift-algorithms/blob/main/Sources/Algorithms/Intersperse.swift) | 
 [Tests](https://github.com/apple/swift-algorithms/blob/main/Tests/SwiftAlgorithmsTests/IntersperseTests.swift)]

Place a given value in between each element of the sequence.

```swift
let numbers = [1, 2, 3].interspersed(with: 0)
// Array(numbers) == [1, 0, 2, 0, 3]

let letters = "ABCDE".interspersed(with: "-")
// String(letters) == "A-B-C-D-E"

let empty = [].interspersed(with: 0)
// Array(empty) == []
```

`interspersed(with:)` takes a separator value and inserts it in between every
element in the sequence.

## Detailed Design

A new method is added to sequence:

```swift
extension Sequence {
    func interspersed(with separator: Element) -> InterspersedSequence<Self>
}
```

The new `InterspersedSequence` type represents the sequence when the separator
is inserted between each element. `InterspersedSequence` conforms to
`Collection`, `BidirectionalCollection`, `RandomAccessCollection`,
`LazySequenceProtocol` and `LazyCollectionProtocol` when the base sequence
conforms to those respective protocols.

### Complexity

Calling these methods is O(_1_).

### Naming

This method’s and type’s name match the term of art used in other languages
and libraries.

### Comparison with other languages

**[Haskell][Haskell]:** Has an `intersperse` function which takes an element
and a list and 'intersperses' that element between the elements of the list.

**[Rust][Rust]:** Has a function called `intersperse` to insert a particular
value between each element. 

<!-- Link references for other languages -->

[Haskell]: https://hackage.haskell.org/package/base-4.14.0.0/docs/Data-List.html#v:intersperse
[Rust]: https://docs.rs/itertools/0.9.0/itertools/trait.Itertools.html#method.intersperse
