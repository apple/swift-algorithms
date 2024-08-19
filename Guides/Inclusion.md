#  Inclusion

[[Source](https://github.com/apple/swift-algorithms/blob/main/Sources/Algorithms/Includes.swift) | 
 [Tests](https://github.com/apple/swift-algorithms/blob/main/Tests/SwiftAlgorithmsTests/IncludesTests.swift)]

Check if one sequence includes another with the `includes` function.
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

For a more detailed computation of how much the two sequences intersect,
use the `overlap` function.

```swift
let firstOverlapThird = first.overlap(withSorted: third, sortedBy: >)
assert(firstOverlapThird.elementsFromSelf == .some(true))
assert(firstOverlapThird.sharedElements == .some(true))
assert(firstOverlapThird.elementsFromOther == .some(false))
```

By default, `overlap` returns its result after at least one of the sequences ends.
To immediately end comparisons as soon as an element for a particular category is found,
pass in the appropriate "`bail`" argument.

```swift
let firstOverlapThirdAgain = first.overlap(withSorted: third, bailAfterShared: true, sortedBy: >)
assert(firstOverlapThirdAgain.sharedElements == .some(true))
assert(firstOverlapThirdAgain.elementsFromSelf == .some(true))
assert(firstOverlapThirdAgain.elementsFromOther == .none)
```

When `overlap` ends by a short-circut,
only the flag for the short-circuted category will be `true`.
The returned flags for the other categories may be `nil`.
If multiple categories are flagged for short-circuting,
only the first one found is guaranteed to be `true`.
When no bailing argument is supplied,
none of the returned flags will be `nil`.

If a predicate is not supplied,
then the less-than operator is used,
but only if the `Element` type conforms to `Comparable`.

```swift
(1...3).includes(sorted: 1..<3)  // true
(1...3).overlap(sorted: 1..<3).elementsFromOther  // .some(false)
```

## Detailed Design

Four new methods are added to `Sequence`:

```swift
extension Sequence {
    @inlinable public func
    includes<T>(
                       sorted other: T,
      sortedBy areInIncreasingOrder: (Element, Element) throws -> Bool
    ) rethrows -> Bool
    where T : Sequence, Self.Element == T.Element

    public func
    overlap<T>(
                   withSorted other: T, 
             bailAfterSelfExclusive: Bool = false,
                    bailAfterShared: Bool = false,
            bailAfterOtherExclusive: Bool = false,
      sortedBy areInIncreasingOrder: (Element, Element) throws -> Bool
    ) rethrows -> (elementsFromSelf: Bool?, sharedElements: Bool?, elementsFromOther: Bool?)
    where T : Sequence, Self.Element == T.Element
}

extension Sequence where Self.Element : Comparable {
    @inlinable public func
    includes<T>(
      sorted other: T
    ) -> Bool
    where T : Sequence, Self.Element == T.Element

    @inlinable public func
    overlap<T>(
             withSorted other: T,
       bailAfterSelfExclusive: Bool = false,
              bailAfterShared: Bool = false,
      bailAfterOtherExclusive: Bool = false
    ) -> (elementsFromSelf: Bool?, sharedElements: Bool?, elementsFromOther: Bool?)
    where T : Sequence, Self.Element == T.Element
}
```

The `Sequence.includes(sorted:)` method calls the
`Sequence.includes(sorted:sortedBy:)` method with the less-than operator for
the latter's second argument.
The same relationship applies to both versions of `Sequence.overlap`.

### Complexity

Calling any of these methods is O(_n_),
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
