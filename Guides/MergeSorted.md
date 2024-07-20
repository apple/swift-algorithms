#  Merge Sorted

[[Source](https://github.com/apple/swift-algorithms/blob/main/Sources/Algorithms/MergeSorted.swift) | 
 [Tests](https://github.com/apple/swift-algorithms/blob/main/Tests/SwiftAlgorithmsTests/MergeSortedTests.swift)]

Splice two sequences that use the same sorting criteria into a sequence that
is also sorted with that criteria.

If the sequences are sorted with something besides the less-than operator (`<`),
then a predicate can be supplied:

```swift
let merged = mergeSorted([10, 4, 0, 0, -3], [20, 6, 1, -1, -5], sortedBy: >)
print(Array(merged))
// [20, 10, 6, 4, 1, 0, 0, -1, -3, -5]
```

Sorted sequences can be treated as (multi-)sets.
Due to being sorted,
distinguishing elements that are shared between sequences or
are exclusive to a sequence can be determined in a resonable time frame.
Set operations take advantage of the catagories of sharing,
so applying operations can be done in-line during the merging:

```swift
let first = [0, 1, 1, 2, 5, 10], second = [-1, 0, 1, 2, 2, 7, 10, 20]
print(Array(mergeSorted(first, second, retaining: .union)))
print(Array(mergeSorted(first, second, retaining: .intersection)))
print(Array(mergeSorted(first, second, retaining: .secondWithoutFirst)))
print(Array(mergeSorted(first, second, retaining: .sum)))  // Standard merge!
/*
[-1, 0, 1, 1, 2, 2, 5, 7, 10, 20]
[0, 1, 2, 10]
[-1, 2, 7, 20]
[-1, 0, 0, 1, 1, 1, 2, 2, 2, 5, 7, 10, 10, 20]
*/
```

## Detailed Design

The merging algorithm can be applied in three domains:

- A free function taking the source sequences.
- An initializer for `RangeReplaceableCollection`,
  that takes the source sequences and then
  creates the result in-place.
- A function over a `MutableCollection`,
  where the two sources are adjancent partitions of the collection.

The free-function and initializer forms can take an optional parameter,
that indicates which subset of the merge will be kept.
For instance, when using `.intersection`, only elements that appear in
both sources will be returned, any non-matches will be skipped over.
If a subset argument is not given, it defaults to `.sum`,
which represents a conventional merge.
The form for adjancent partitions cannot use subsetting,
always performing with a subset of `.sum`.
All of the forms take a parameter for the ordering predicate.
If the element type conforms to `Comparable`,
a predicate can be omitted to use a default of the less-than operator (`<`).

```swift
// Free-function form. Also used for lazy evaluation.

public func mergeSorted<T, U>(_ first: T, _ second: U, retaining filter: MergerSubset = .sum, sortedBy areInIncreasingOrder: @escaping (T.Element, U.Element) -> Bool) -> MergeSortedSequence<LazySequence<T>, LazySequence<U>> where T : Sequence, U : Sequence, T.Element == U.Element

@inlinable public func mergeSorted<T, U>(_ first: T, _ second: U, retaining filter: MergerSubset = .sum) -> MergeSortedSequence<LazySequence<T>, LazySequence<U>> where T : Sequence, U : Sequence, T.Element : Comparable, T.Element == U.Element

// Initializer form.

extension RangeReplaceableCollection {
    public init<T, U>(mergeSorted first: T, and second: U, retaining filter: MergerSubset = .sum, sortedBy areInIncreasingOrder: (Element, Element) throws -> Bool) rethrows where T : Sequence, U : Sequence, Self.Element == T.Element, T.Element == U.Element
}

extension RangeReplaceableCollection where Self.Element : Comparable {
    @inlinable public init<T, U>(mergeSorted first: T, and second: U, retaining filter: MergerSubset = .sum) where T : Sequence, U : Sequence, Self.Element == T.Element, T.Element == U.Element
}

// Two-partition merging, optimizing for speed.

extension MutableCollection {
    public mutating func mergeSortedPartitions(across pivot: Index, sortedBy areInIncreasingOrder: (Element, Element) throws -> Bool) rethrows
}

extension MutableCollection where Self.Element : Comparable {
    @inlinable public mutating func mergeSortedPartitions(across pivot: Index)
}

// Two-partition merging, optimizing for space.

extension MutableCollection where Self : BidirectionalCollection {
    public mutating func mergeSortedPartitionsInPlace(across pivot: Index, sortedBy areInIncreasingOrder: (Element, Element) throws -> Bool) rethrows
}

extension MutableCollection where Self : BidirectionalCollection, Self.Element : Comparable {
    @inlinable public mutating func mergeSortedPartitionsInPlace(across pivot: Index)
}
```

Target subsets are described by a new type.

```swift
public enum MergerSubset : UInt, CaseIterable {
    case none, firstWithoutSecond, secondWithoutFirst, symmetricDifference,
         intersection, first, second, union,
         sum

    //...
}
```

Every set-operation combination is provided, although some are degenerate.

Most of the merging functions use these support types:

```swift
public struct MergeSortedSequence<First, Second>
 : Sequence, LazySequenceProtocol
where First : Sequence,
      Second : Sequence,
      First.Element == Second.Element
{ /*...*/ }

public struct MergeSortedIterator<First, Second>
 : IteratorProtocol
where First : IteratorProtocol,
      Second : IteratorProtocol,
      First.Element == Second.Element
{ /*...*/ }
```

The merges via:

- The free functions
- The initializers
- The speed-optimized partition-merge

Operate in **O(** _n_ `+` _m_ **)** for both space and time,
where *n* and *m* are the lengths of the two operand sequences/partitions.
The space-optimized partition merge for a collection of length *n* operates in
**O(** 1 **)** for space,
**O(** _n_ **)** for time when the collection is not random-access,
and *???* for time in random-access collections.

### Naming

Many merging functions use the word "merge" in their name.

**[C++]:** Provides the `merge` and `inplace_merge` functions.
Set operations are provided by
the `set_union`, `set_intersection`, `set_difference`, and
`set_symmetric_difference` functions.
