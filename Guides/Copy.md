# Copy

[[Source](../Sources/Algorithms/Copy.swift) |
 [Tests](../Tests/SwiftAlgorithmsTests/CopyTests.swift)]

Copy a sequence onto an element-mutable collection.

```swift
var destination = [1, 2, 3, 4, 5]
let source = [6, 7, 8, 9, 10]
print(destination)  // "[1, 2, 3, 4, 5]

let (_, sourceSuffix) = destination.overwrite(prefixWith: source)
print(destination)  // "[6, 7, 8, 9, 10]"
print(Array(IteratorSequence(sourceSuffix)))  // "[]"
```

`overwrite(prefixWith:)` takes a source sequence and overlays its first *k* elements'
values over the first `k` elements of the receiver, where `k` is the smaller of
the two sequences' lengths.  The `overwrite(prefixWithCollection:)` variant uses a collection
for the source sequence.  The `overwrite(suffixWith:)` and `overwrite(suffixWithCollection:)`
methods work similar to the first two methods except the last `k` elements of
the receiver are overlaid instead.  The `overwrite(backwards:)` method is like the
previous method, except both the source and destination collections are
traversed from the end.

Since the Swift memory model prevents a collection from being used multiple
times in code where at least one use is mutable, the `overwrite(forwardsFrom:to:)`
and `overwrite(backwardsFrom:to:)` methods permit copying elements across
subsequences of the same collection.

## Detailed Design

New methods are added to element-mutable collections:

```swift
extension MutableCollection {
  mutating func overwrite<S: Sequence>(prefixWith source: S)
   -> (copyEnd: Index, sourceTail: S.Iterator) where S.Element == Element

  mutating func overwrite<C>(prefixWithCollection collection: C)
   -> (copyEnd: Index, sourceTailStart: C.Index)
   where C : Collection, Self.Element == C.Element

  mutating func overwrite<R, S>(forwardsFrom source: R, to destination: S)
  -> (sourceRead: Range<Index>, destinationWritten: Range<Index>)
  where R : RangeExpression, S : RangeExpression, Self.Index == R.Bound,
        R.Bound == S.Bound
}

extension MutableCollection where Self: BidirectionalCollection {
    mutating func overwrite<S>(suffixWith source: S)
     -> (copyStart: Index, sourceTail: S.Iterator)
     where S : Sequence, Self.Element == S.Element

    mutating func overwrite<C>(suffixWithCollection source: C)
     -> (copyStart: Index, sourceTailStart: C.Index)
     where C : Collection, Self.Element == C.Element

    mutating func overwrite<C>(backwards source: C)
     -> (writtenStart: Index, readStart: C.Index)
      where C : BidirectionalCollection, Self.Element == C.Element

    mutating func overwrite<R, S>(backwardsFrom source: R, to destination: S)
     -> (sourceRead: Range<Index>, destinationWritten: Range<Index>)
     where R : RangeExpression, S : RangeExpression, Self.Index == R.Bound,
           R.Bound == S.Bound
}
```

Each method returns two values.  For the two-sequence methods, the first member
is the index for the non-endpoint bound for the destination adfix.  For the
two-sequence methods where the non-receiver is a `Sequence`, the second member
is an iterator for the elements of the source's suffix that were never read in
for copying.  For the two-sequence methods where the non-receiver is a
`Collection`, the second member is the index for the first element of the
source's suffix that was never read in for copying.  For the two-subsequences
methods, the members are the ranges for the parts of the subsequence operands
that were actually touched during copying.

### Complexity

Calling these methods is O(_k_), where _k_ is the length of the shorter
sequence between the receiver and `source`.

### Naming

This method’s name matches the term of art used in other languages and
libraries.

### Comparison with other languages

**C++:** Has a [`copy`][C++Copy] function in the `algorithm` library that takes
a bounding pair of input iterators for the source and a single output iterator
for the destination, returning one-past the last output iterator written over.
The `copy_if` function does not have an analogue, since it can be simulated by
submitting the result from `filter(_:)` as the source.  There is a
[`copy_backward`][C++CopyBackward] function that copies elements backwards from
the far end of the source and destination, returning the near end of the
destination that got written.  These functions take their buffer arguments as
separate iterator/pointer values; as such, the functions can handle the source
and destination buffers having overlap or otherwise being sub-buffers of a
shared collection.  Swift's memory safety model prevents it from doing the
same, necessitating it to use customized methods when the source and
destination buffers subset the same super-buffer.

<!-- Link references for other languages -->

[C++Copy]: https://en.cppreference.com/w/cpp/algorithm/copy
[C++CopyBackward]: https://en.cppreference.com/w/cpp/algorithm/copy_backward