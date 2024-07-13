#  Inclusion

[[Source](https://github.com/apple/swift-algorithms/blob/main/Sources/Algorithms/Includes.swift) | 
 [Tests](https://github.com/apple/swift-algorithms/blob/main/Tests/SwiftAlgorithmsTests/IncludesTests.swift)]

Check if one sequence includes another.
Both sequences must be sorted along the same criteria,
which must provide a strict weak ordering.

```swift
let first = [4, 3, 2, 1], second = [3, 2, 1, 0], third = [3, 2]
let firstIncludesSecond = first.includes(sorted: second, sortedBy: >)  // false
let secondIncludesThird = second.includes(sorted: third, sortedBy: >)  // true
let thirdIncludesFirst  = third.includes(sorted: first, sortedBy: >)   // false
let firstIncludesThird  = first.includes(sorted: third, sortedBy: >)   // true
let thirdIncludesSecond = third.includes(sorted: second, sortedBy: >)  // false
let secondIncludesFirst = second.includes(sorted: first, sortedBy: >)  // false
```

If a predicate is not supplied,
then the less-than operator is used,
but only if the `Element` type conforms to `Comparable`.

```swift
(1...3).includes(sorted: 1..<3)  // true
```

## Detailed Design

Two new methods are added to `Sequence`:

```swift
extension Sequence {
    public func
    includes<T>(
                       sorted other: T,
      sortedBy areInIncreasingOrder: (Element, Element) throws -> Bool
    ) rethrows -> Bool
    where T : Sequence, Self.Element == T.Element
}

extension Sequence where Self.Element : Comparable {
    @inlinable public func
    includes<T>(
      sorted other: T
    ) -> Bool
    where T : Sequence, Self.Element == T.Element
}
```

The `Sequence.includes(sorted:)` method calls the
`Sequence.includes(sorted:sortedBy:)` method with the less-than operator for
the latter's second argument.

### Complexity

Calling either method is O(_n_),
where *n* is the length of the shorter sequence.

### Naming

These methods' base name is inspired by the C++ function `std::includes`.

### Comparison with Other Languages

**[C++][C++]:** Has an `includes` function family.

**[Haskell][Haskell]:** Has the `isInfixOf` function, plus the `isPrefixOf`,
`isSuffixOf`, and `isSubsequenceOf` functions.

<!-- Link references for other languages -->

[C++]: https://en.cppreference.com/w/cpp/algorithm/includes
[Haskell]: https://hackage.haskell.org/package/base-4.20.0.1/docs/Data-List.html#v:isInfixOf
