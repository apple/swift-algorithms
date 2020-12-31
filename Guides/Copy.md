# Copy

[[Source](../Sources/Algorithms/Copy.swift) |
 [Tests](../Tests/SwiftAlgorithmsTests/CopyTests.swift)]

Copy a sequence onto an element-mutable collection.

```swift
var destination = Array("abcde")
print(String(destination))  // "abcde"

let source = "123"
let changedEnd = destination.overwrite(prefixWith: source)
print(String(destination))  // "123de"
print(String(destination[changedEnd...]))  // "de"
```

`overwrite(prefixWith:)` takes a source sequence and replaces the first `k`
elements of the receiver with the first `k` elements of the source, where *k*
is the length of the shorter sequence. `overwrite(forwardsWith:)` does the same
thing with a source collection, and `overwrite(prefixUsing:)` with an `inout`
source iterator. To preserve memory exclusivity, the
`overwrite(forwardsFrom:to:)` overload is required to copy between subsequences
of the same collection, where the source and destination are given as index
ranges.

When the receiving element-mutable collection supports bidirectional traversal,
variants of the previous methods are defined that copy the source elements on
top of the receiver's suffix instead. The `overwrite(suffixWith:)` and
`overwrite(suffixUsing:)` methods use their source's prefix, while the
`overwrite(backwardsWith:)` and `overwrite(backwardsFrom:to:)` methods use
their source's suffix.

## Detailed Design

New methods are added to element-mutable collections:

```swift
extension MutableCollection {
  mutating func overwrite<I>(prefixUsing source: inout I) -> Index
   where I : IteratorProtocol, Self.Element == I.Element

  mutating func overwrite<S>(prefixWith source: S) -> Index
   where S : Sequence, Self.Element == S.Element

  mutating func overwrite<C>(forwardsWith source: C)
   -> (readEnd: C.Index, writtenEnd: Index)
   where C : Collection, Self.Element == C.Element

  mutating func overwrite<R, S>(forwardsFrom source: R, to destination: S)
  -> (sourceRead: Range<Index>, destinationWritten: Range<Index>)
  where R : RangeExpression, S : RangeExpression, Self.Index == R.Bound,
        R.Bound == S.Bound
}

extension MutableCollection where Self: BidirectionalCollection {
    mutating func overwrite<I>(suffixUsing source: inout I) -> Index
     where I : IteratorProtocol, Self.Element == I.Element

    mutating func overwrite<S>(suffixWith source: S) -> Index
     where S : Sequence, Self.Element == S.Element

    mutating func overwrite<C>(backwardsWith source: C)
     -> (readStart: C.Index, writtenStart: Index)
     where C : BidirectionalCollection, Self.Element == C.Element

    mutating func overwrite<R, S>(backwardsFrom source: R, to destination: S)
     -> (sourceRead: Range<Index>, destinationWritten: Range<Index>)
     where R : RangeExpression, S : RangeExpression, Self.Index == R.Bound,
           R.Bound == S.Bound
}
```

When the source is an iterator or sequence, the return value from `overwrite`
is a single index value within the receiver that is the non-anchored end of the
range of overwritten elements. The prefix-overwriting methods return the upper
bound, *i.e.* the index after the last touched element, and assume the lower
bound is the receiver's `startIndex`. The suffix-overwriting methods return the
lower bound, *i.e.* the index of the first touched element, and assume the
upper bound is the receiver's `endIndex`. Use of the return value is optional
to support casual use of copying without caring about the precise range of
effect.

When the source is a collection, the return value from `overwrite` has two
components. The second component is the same as the sole value returned from
the overloads with iterator or sequence sources. The first component is the
non-anchored end of the range of the elements actually read from the source.
When the source is a subsequence, the return value's components are index
ranges fully bounding the touched elements instead of ranges implied from
isolated indices.

### Complexity

Calling these methods is O(_k_), where _k_ is the length of the shorter
(virtual) sequence between the receiver (subsequence) and the source.

### Naming

The initial development version of this library used the term-of-art "`copy`"
as the base name of this family of methods. But since the insertion-copying
methods (in `RangeReplaceableCollection`) do not use the term, and the term is
used for object copying in Foundation, a subsitute term was chosen here. The
term "`overwrite`" gives a precise description of the kind of copying employed.

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
