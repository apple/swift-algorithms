# Accumulate

[[Source](../Sources/Algorithms/Accumulate.swift) |
 [Tests](../Tests/SwiftAlgorithmsTests/AccumulateTests.swift)]

Perform `scan(_:)_:)` on a given collection with a given operation, but
overwrite the collection with the results instead of using a separate returned
instance.

```swift
var numbers = Array(1...5)
print(numbers)             // "[1, 2, 3, 4, 5]"
numbers.accumulate(via: +)
print(numbers)             // "[1, 3, 6, 10, 15]"
numbers.disperse(via: -)
print(numbers)             // "[1, 2, 3, 4, 5]"

var empty = Array<Double>()
print(empty)               // "[]"
empty.accumulate(via: *)
print(empty)               // "[]"
empty.disperse(via: /)
print(empty)               // "[]"
```

`accumulate(via:)` takes a closure that fuses the values of two elements.
`disperse(via:)` takes a closure that returns its first argument after the
contribution of the second argument has been removed from it.

## Detailed Design

New methods are added to collections that can do per-element mutations:

```swift
extension MutableCollection {
    mutating func accumulate(
        via combine: (Element, Element) throws -> Element
    ) rethrows

    mutating func disperse(
        via sever: (Element, Element) throws -> Element
    ) rethrows
}
```

Both methods apply their given closures to adjacent pairs of elements, starting
from the first and second elements to the next-to-last and last elements.  The
order the elements are submitted to the closures differ; `combine` takes the
earlier element first and the latter second, while that's reversed for `sever`.

### Complexity

Calling these methods is O(_n_), where _n_ is the length of the collection.

### Naming

The name for `accumulate` was chosen from the similar action category that the
C++ standard library function with the same name.  The name for `disperse` was
taken from a list of antonyms for the first method's name.  Suggestions for
better names would be appreciated.

### Comparison with other languages

**C++:** Has a [`partial_sum`][C++Partial] function from the `<numeric>`
library which takes a bounding input iterator pair, an output iterator and a
combining function (defaulting to `+` if not given), and writes into the output
iterator the progressive combination of all the input values read so far.  The
[`inclusive_scan`][C++Inclusive] function from the same library works the same
way.  That library finally has [`exclusive_scan`][C++Exclusive] which has an
extra parameter for an initial seed value, writing to the output iterator the
progressive combination of the seed value and all the input values prior to the
last-read one.  (The library also has a function named
[`accumulate`][C++Accumulate], but it acts like Swift's `reduce(_:_:)` method.)

<!-- Link references for other languages -->

[C++Partial]: https://en.cppreference.com/w/cpp/algorithm/partial_sum
[C++Inclusive]: https://en.cppreference.com/w/cpp/algorithm/inclusive_scan
[C++Exclusive]: https://en.cppreference.com/w/cpp/algorithm/exclusive_scan
[C++Accumulate]: https://en.cppreference.com/w/cpp/algorithm/accumulate
