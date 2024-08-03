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
so applying operations can be done in-line during merging:

```swift
let first = [0, 1, 1, 2, 5, 10], second = [-1, 0, 1, 2, 2, 7, 10, 20]
print(Array(mergeSortedSets(first, second, retaining: .union)))
print(Array(mergeSortedSets(first, second, retaining: .intersection)))
print(Array(mergeSortedSets(first, second, retaining: .secondWithoutFirst)))
print(Array(mergeSortedSets(first, second, retaining: .sum)))  // Standard merge!
/*
[-1, 0, 1, 1, 2, 2, 5, 7, 10, 20]
[0, 1, 2, 10]
[-1, 2, 7, 20]
[-1, 0, 0, 1, 1, 1, 2, 2, 2, 5, 7, 10, 10, 20]
*/
```

## Detailed Design

The merging algorithm can be applied in three domains:

- Free functions taking the source sequences.
- Initializers for `RangeReplaceableCollection`,
  that take the source sequences and then
  create the result in-place.
- Functions over a `MutableCollection`,
  where the two sources are adjancent partitions of the collection.

The free-function and initializer forms have variants that
take an extra parameter,
which represent which subset of the merger will be kept.
For instance,
using `.intersection` makes the resulting merger contain only the elements that
appear in both sources,
skipping any elements that appear in exactly one source.
All of the forms take a parameter for the ordering predicate.
If the element type conforms to `Comparable`,
a predicate can be omitted to use a default of the less-than operator (`<`).

```swift
// Free-function form. Also used for lazy evaluation.

/// Given two sequences that are both sorted according to the given predicate, return their merger that is sorted by the predicate and vended lazily.
@inlinable public func mergeSorted<T, U>(_ first: T, _ second: U, sortedBy areInIncreasingOrder: @escaping (T.Element, U.Element) -> Bool) -> MergeSortedSetsSequence<T, U> where T : Sequence, U : Sequence, T.Element == U.Element

/// Given two sorted sequences, return their still-sorted merger, vended lazily.
@inlinable public func mergeSorted<T, U>(_ first: T, _ second: U) -> MergeSortedSetsSequence<T, U> where T : Sequence, U : Sequence, T.Element : Comparable, T.Element == U.Element

/// Given two sequences that are both sorted according to the given predicate and treated as sets, apply the given set operation, returning the result as a sequence sorted by the predicate and that is vended lazily.
public func mergeSortedSets<T, U>(_ first: T, _ second: U, retaining filter: MergerSubset, sortedBy areInIncreasingOrder: @escaping (T.Element, U.Element) -> Bool) -> MergeSortedSetsSequence<T, U> where T : Sequence, U : Sequence, T.Element == U.Element

/// Given two sorted sequences treated as sets, apply the given set operation, returning the result as a sorted sequence that vends lazily.
@inlinable public func mergeSortedSets<T, U>(_ first: T, _ second: U, retaining filter: MergerSubset) -> MergeSortedSetsSequence<T, U> where T : Sequence, U : Sequence, T.Element : Comparable, T.Element == U.Element

// Initializer form.

extension RangeReplaceableCollection {
    /// Given two sequences that are both sorted according to the given predicate, create their sorted merger.
    @inlinable public init<T, U>(mergeSorted first: T, and second: U, sortedBy areInIncreasingOrder: (Element, Element) throws -> Bool) rethrows where T : Sequence, U : Sequence, Self.Element == T.Element, T.Element == U.Element

    /// Given two sequences that are both sorted according to the given predicate, treat them as sets, and create the sorted result of the given set operation.
    public init<T, U>(mergeSorted first: T, and second: U, retaining filter: MergerSubset, sortedBy areInIncreasingOrder: (Element, Element) throws -> Bool) rethrows where T : Sequence, U : Sequence, Self.Element == T.Element, T.Element == U.Element
}

extension RangeReplaceableCollection where Self.Element : Comparable {
    /// Given two sorted sequences, create their sorted merger.
    @inlinable public init<T, U>(mergeSorted first: T, and second: U) where T : Sequence, U : Sequence, Self.Element == T.Element, T.Element == U.Element

    /// Given two sorted sequences, treat them as sets, and create the sorted result of the given set operation.
    @inlinable public init<T, U>(mergeSorted first: T, and second: U, retaining filter: MergerSubset) where T : Sequence, U : Sequence, Self.Element == T.Element, T.Element == U.Element
}

// Two-partition merging, optimizing for speed.

extension MutableCollection {
    /// Given a partition point, where each side is sorted according to the given predicate, rearrange the elements until a single sorted run is formed.
    public mutating func mergeSortedPartitions(across pivot: Index, sortedBy areInIncreasingOrder: (Element, Element) throws -> Bool) rethrows
}

extension MutableCollection where Self.Element : Comparable {
    /// Given a partition point, where each side is sorted, rearrange the elements until a single sorted run is formed.
    @inlinable public mutating func mergeSortedPartitions(across pivot: Index)
}

// Two-partition merging, optimizing for space.

extension MutableCollection where Self : BidirectionalCollection {
    /// Given a partition point, where each side is sorted according to the given predicate, rearrange the elements until a single sorted run is formed, using minimal scratch memory.
    public mutating func mergeSortedPartitionsInPlace(across pivot: Index, sortedBy areInIncreasingOrder: (Element, Element) throws -> Bool) rethrows
}

extension MutableCollection where Self : BidirectionalCollection, Self.Element : Comparable {
    /// Given a partition point, where each side is sorted, rearrange the elements until a single sorted run is formed, using minimal scratch memory.
    @inlinable public mutating func mergeSortedPartitionsInPlace(across pivot: Index)
}
```

Target subsets are described by a new type.

```swift
/// Description of which elements of a merger will be retained.
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
/// A sequence that lazily vends the sorted result of a set operation upon two sorted sequences treated as sets spliced together, using a predicate as the sorting criteria for all three sequences involved.
public struct MergeSortedSequence<First, Second>
 : Sequence
where First : Sequence,
      Second : Sequence,
      First.Element == Second.Element
{ /*...*/ }

extension MergeSortedSetsSequence
 : LazySequenceProtocol
where First : LazySequenceProtocol, Second : LazySequenceProtocol
{ /*...*/ }

/// An iterator that applies a set operation on two virtual sequences, both treated as sets sorted according a predicate, spliced together to vend a virtual sequence that is also sorted.
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
