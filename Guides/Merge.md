#  Merge

- Between Partitions: 
  [[Source](https://github.com/apple/swift-algorithms/blob/main/Sources/Algorithms/MergePartitions.swift) |
  [Tests](https://github.com/apple/swift-algorithms/blob/main/Tests/SwiftAlgorithmsTests/MergePartitionsTests.swift)]
- Between Arbitrary Sequences:
  [[Source](https://github.com/apple/swift-algorithms/blob/main/Sources/Algorithms/Merge.swift) |
  [Tests](https://github.com/apple/swift-algorithms/blob/main/Tests/SwiftAlgorithmsTests/MergeTests.swift)]

Splice two sequences that use the same sorting criteria into a sequence that
is also sorted with that criteria.

If the sequences are sorted with something besides the less-than operator (`<`),
then a predicate can be supplied:

```swift
let merged = merge([10, 4, 0, 0, -3], [20, 6, 1, -1, -5], keeping: .sum, sortedBy: >)
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
print(merge(first, second, into: Array.self, keeping: .union))
print(merge(first, second, into: Array.self, keeping: .intersection))
print(merge(first, second, into: Array.self, keeping: .secondWithoutFirst))
print(merge(first, second, into: Array.self, keeping: .sum))  // Standard merge!
/*
[-1, 0, 1, 1, 2, 2, 5, 7, 10, 20]
[0, 1, 2, 10]
[-1, 2, 7, 20]
[-1, 0, 0, 1, 1, 1, 2, 2, 2, 5, 7, 10, 10, 20]
*/
```

## Detailed Design

The merging algorithm can be applied in two domains:

- Free functions taking the source sequences.
- Functions over a `MutableCollection & BidirectionalCollection`,
  where the two sources are adjancent partitions of the collection.

Besides the optional ordering predicate,
the partition-merging methods' other parameter is the index to the
first element of the second partition,
or `endIndex` if that partition is empty.

Besides the optional ordering predicate,
the free functions take the two operand sequences and the desired set operation
(intersection, union, symmetric difference, *etc.*).
Use `.sum` for a conventional merge.
Half of those functions take an extra parameter taking a reference to
a collection type.
These functions create an object of that type and eagerly fill it with the
result of the merger.
The functions without that parameter return a special sequence that lazily
generates the result of the merger.

```swift
// Merging two adjacent partitions.

extension MutableCollection where Self : BidirectionalCollection {
    /// Assuming that both this collection's slice before the given index and
    /// the slice at and past that index are both sorted according to
    /// the given predicate,
    /// rearrange the slices' elements until the collection as
    /// a whole is sorted according to the predicate.
    public mutating func mergePartitions<Fault>(
                       across pivot: Index,
      sortedBy areInIncreasingOrder: (Element, Element) throws(Fault) -> Bool
    ) throws(Fault) where Fault : Error
}

extension MutableCollection where Self : BidirectionalCollection, Self.Element : Comparable {
    /// Assuming that both this collection's slice before the given index and
    /// the slice at and past that index are both sorted,
    /// rearrange the slices' elements until the collection as
    /// a whole is sorted.
    public mutating func mergePartitions(across pivot: Index)
}

// Merging two sequences with free functions, applying a set operation.
// Has lazy and eager variants.

/// Given two sequences treated as (multi)sets, both sorted according to
/// a given predicate,
/// return a sequence that lazily vends the also-sorted result of applying a
/// given set operation to the sequence operands.
public func merge<First, Second>(
  _ first: First, _ second: Second, keeping filter: MergerSubset,
  sortedBy areInIncreasingOrder: @escaping (First.Element, Second.Element) -> Bool
) -> MergedSequence<First, Second, Never>
where First : Sequence, Second : Sequence, First.Element == Second.Element

/// Given two sorted sequences treated as (multi)sets,
/// return a sequence that lazily vends the also-sorted result of applying a
/// given set operation to the sequence operands.
public func merge<First, Second>(
  _ first: First, _ second: Second, keeping filter: MergerSubset
) -> MergedSequence<First, Second, Never>
where First : Sequence, Second : Sequence, First.Element : Comparable,
      First.Element == Second.Element

/// Given two sequences treated as (multi)sets, both sorted according to
/// a given predicate,
/// eagerly apply a given set operation to the sequences then copy the
/// also-sorted result into a collection of a given type.
public func merge<First, Second, Result, Fault>(
  _ first: First, _ second: Second, into type: Result.Type, keeping filter: MergerSubset,
  sortedBy areInIncreasingOrder: (First.Element, Second.Element) throws(Fault) -> Bool
) throws(Fault) -> Result
where First : Sequence, Second : Sequence, Result : RangeReplaceableCollection,
      Fault : Error, First.Element == Second.Element, Second.Element == Result.Element

/// Given two sorted sequences treated as (multi)sets,
/// eagerly apply a given set operation to the sequences then copy the
/// also-sorted result into a collection of a given type.
public func merge<First, Second, Result>(
  _ first: First, _ second: Second, into type: Result.Type, keeping filter: MergerSubset
) -> Result
where First : Sequence, Second : Sequence, Result : RangeReplaceableCollection,
      First.Element : Comparable, First.Element == Second.Element,
      Second.Element == Result.Element
```

Target subsets are described by a new type.

```swift
/// Description of which elements of a merger will be retained.
public enum MergerSubset : UInt, CaseIterable
{
    case none, firstWithoutSecond, secondWithoutFirst, symmetricDifference,
         intersection, first, second, union,
         sum

    //...
}
```

Every set-operation combination is provided, although some are degenerate.

The merging free-functions use these support types:

```swift
/// A sequence that reads from two sequences treated as (multi)sets,
/// where both sequences' elements are sorted according to some predicate,
/// and emits a sorted merger,
/// excluding any elements barred by a set operation.
public struct MergedSequence<First, Second, Fault>
 : Sequence, LazySequenceProtocol
   where First : Sequence, Second : Sequence, Fault : Error,
         First.Element == Second.Element
{
    //...
}

/// An iterator that reads from two virtual sequences treated as (multi)sets,
/// where both sequences' elements are sorted according to some predicate,
/// and emits a sorted merger,
/// excluding any elements barred by a set operation.
public struct MergingIterator<First, Second, Fault>
 : IteratorProtocol
   where First : IteratorProtocol, Second : IteratorProtocol, Fault : Error,
         First.Element == Second.Element
{
    //...
}
```

The partition merger operates **O(** 1 **)** in space;
for time it works at _???_ for random-access collections and
_???_ for bidirectional collections.

The eager merging free functions operate at **O(** _n_ `+` _m_ **)** in
space and time,
where *n* and *m* are the lengths of the source sequences.
The lazy merging free functions operate at **O(** 1 **)** in space and time.
Actually generating the entire merged sequence will take 
**O(** _n_ `+` _m_ **)** over distributed time.

### Naming

Many merging functions use the word "merge" in their name.

**[C++]:** Provides the `merge` and `inplace_merge` functions.
Set operations are provided by
the `set_union`, `set_intersection`, `set_difference`, and
`set_symmetric_difference` functions.
