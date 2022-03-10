# Merge

[[Source](https://github.com/apple/swift-algorithms/blob/main/Sources/Algorithms/Merge.swift) | 
 [Tests](https://github.com/apple/swift-algorithms/blob/main/Tests/SwiftAlgorithmsTests/MergeTests.swift)]

A function returning the sorted merger of two already sorted sequences.

```swift
let source1 = "acegg", source2 = "bdfgh"
print(merge(source1, source2))  // Prints "abcdefgggh"

// Is equivalent to:
print(String((source1 + source2).sorted()))
```

A sorted list may be used to implement a set. To aid this, `merge` supports
generating results that are subsets of a full merger, based on standard set
operations.

```swift
print(merge(source1, source2, keeping: .union))         // "abcdefggh"
print(merge(source1, source2, keeping: .intersection))  // "g"
```

## Detailed Design

By default, the `merge` function takes two sequences with a common `Element`
type that conforms to `Comparable`, and returns an `Array`:

```swift
public func merge<Base1: Sequence, Base2: Sequence>(
    _ first: Base1, _ second: Base2, keeping operation: SetOperation = .sum
) -> [Base1.Element]
where Base1.Element == Base2.Element, Base2.Element: Comparable
```

The optional third parameter adjusts the result to exclude elements that would
not match said parameter's set operation, based on shared and/or disjoint
element values. For `Element` types that do not conform to `Comparable`, and/or
when the sequences use a sort order other than `<`, an ordering predicate can be
supplied as a fourth parameter (implemented as an overload):

```swift
public func merge<Base1: Sequence, Base2: Sequence>(
    _ first: Base1, _ second: Base2, keeping operation: SetOperation = .sum,
    along areInIncreasingOrder: (Base1.Element, Base2.Element) throws -> Bool
) rethrows -> [Base1.Element] where Base1.Element == Base2.Element
```

Filtering by set operations is represented by the `SetOperation` enumeration
type. Use `.sum` for a standard merger. For some given element value *x*, its
multiplicity in the merged result is based on the operation chosen and the
value's multiplicities in the operands:

| Operation           | Case                  | Multiplicity of *x* in the Result |
| ---------           | ----                  | --------------------------------- |
| ∅                   | `none`                | 0                                 |
| *First* \\ *Second* | `firstWithoutSecond`  | max(*m*₁(x) - *m*₂(x), 0)         |
| *Second* \\ *First* | `secondWithoutFirst`  | max(*m*₂(x) - *m*₁(x), 0)         |
| *First* ⊖ *Second*  | `symmetricDifference` | \|*m*₁(x) - *m*₂(x)\|             |
| *First* ∩ *Second*  | `intersection`        | min(*m*₁(x), *m*₂(x))             |
| *First*             | `first`               | *m*₁(x)                           |
| *Second*            | `second`              | *m*₂(x)                           |
| *First* ∪ *Second*  | `union`               | max(*m*₁(x), *m*₂(x))             |
| *First* + *Second*  | `sum`                 | *m*₁(x) + *m*₂(x)                 |

Equivalent elements preserve their relative order.

When shared element values are read, which source has their copy passed through
depends on the operation. For `.sum`, all the equivalent elements from the first
sequence are vended before any from the second sequence. For `.second`, the copy
from the second sequence is used. For `.intersection`, `.first`, and `.union`;
the copy from the first sequence is used.

If the two source sequences share a type, and said type conforms to
`RangeReplaceableCollection`, then `merge` will return that type instead.

```swift
public func merge<Base: RangeReplaceableCollection>(
    _ first: Base, _ second: Base, keeping operation: SetOperation = .sum
) -> Base where Base.Element: Comparable

public func merge<Base: RangeReplaceableCollection>(
    _ first: Base, _ second: Base, keeping operation: SetOperation = .sum,
    along areInIncreasingOrder: (Base.Element, Base.Element) throws -> Bool
) rethrows -> Base
```

All versions of `merge` compute the merger eagerly during the function call. If
the result needs to be lazily generated, use the `lazilyMerge` function, which
returns a custom lazy sequence. However, the ordering predicate must be a
non-throwing function. Omitting the predicate sets the default to lexicographic
ordering with the `<` operator.

```swift
public func lazilyMerge<Base1: LazySequenceProtocol, Base2: LazySequenceProtocol>(
    _ first: Base1, _ second: Base2, keeping operation: SetOperation = .sum
) -> Merged2Sequence<Base1.Elements, Base2.Elements>
where Base1.Element == Base2.Element, Base2.Element: Comparable

public func lazilyMerge<Base1: LazySequenceProtocol, Base2: LazySequenceProtocol>(
    _ first: Base1, _ second: Base2, keeping operation: SetOperation = .sum,
    along areInIncreasingOrder: (Base1.Element, Base2.Element) -> Bool
) -> Merged2Sequence<Base1.Elements, Base2.Elements>
where Base1.Element == Base2.Element
```

Variant functions with higher arities are not provided since many set
operations, besides set-sum, are poorly defined for three or more operands.

### Complexity

The `merge` function performs in O(_m \+ n_) time, where *m* and *n* are the
lengths of the source sequences. The `lazilyMerge` function returns its proxy in
O(1) time, but carries out the entire operation in the same time as the eager
version.

### Comparison with other languages

**C++:** For general merging, you can call either the `std::merge` or
`std::ranges::merge` functions with two pairs of iterators, or the
`std::ranges::merge` function with two ranges. For applying non-degenerate set
operations, separate functions are provided instead of a filtering parameter.
Given two pairs of iterators, you can call `std::set_difference`,
`std::set_intersection`, `std::set_symmetric_difference`, `std::set_union`,
`std::ranges::set_difference`, `std::ranges::set_intersection`,
`std::ranges::set_symmetric_difference`, or `std::ranges::set_union`. Given two
ranges, you can call `std::ranges::set_difference`,
`std::ranges::set_intersection`, `std::ranges::set_symmetric_difference`, or
`std::ranges::set_union`.
