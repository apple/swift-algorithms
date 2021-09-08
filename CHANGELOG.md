# CHANGELOG

<!-- 
Add new items at the end of the relevant section under **Unreleased**.
-->

This project follows semantic versioning.

## [Unreleased]

*No new changes.*

---

## [1.0.0] - 2021-09-08

### Changes

- Most sequence and collection types have been renamed, following a more
  consistent naming structure:
  - The `Lazy` prefix was dropped.
  - Either a `Sequence` or `Collection` suffix was added depending on whether or
    not the type is unconditionally a collection.
  - The base name was derived from the name of the method that produces it,
    including an argument label to disambiguate if necessary.
  ```
  Chain2              -> Chain2Sequence
  ChunkedBy           -> ChunkedByCollection
  ChunkedOn           -> ChunkedOnCollection
  ChunkedByCount      -> ChunksOfCountCollection
  Combinations        -> CombinationsSequence
  Cycle               -> CycledSequence
  FiniteCycle         -> CycledTimesCollection
  Indexed             -> IndexedCollection
  Intersperse         -> InterspersedSequence
  LazySplitSequence   -> SplitSequence
  LazySplitCollection -> SplitCollection
  Permutations        -> PermutationsSequence
  UniquePermutations  -> UniquePermutationsSequence
  Product2            -> Product2Sequence
  ExclusiveReductions -> ExclusiveReductionsSequence
  InclusiveReductions -> InclusiveReductionsSequence
  StrideSequence      -> StridingSequence
  StrideCollection    -> StridingCollection
  Uniqued             -> UniquedSequence
  Windows             -> WindowsOfCountCollection
  ```
- Types that can only be produced from a lazy sequence chain now unconditionally
  conform to `LazySequenceProtocol` and wrap the base sequence instead of the
  lazy wrapper, making some return types slightly simpler.
  - e.g. `[1, 2, 3].lazy.reductions(+)` now returns
    `ExclusiveReductionsSequence<[Int]>`, not
    `ExclusiveReductionsSequence<LazySequence<[Int]>>`.
  - This concerns `JoinedByClosureSequence`, `JoinedByClosureCollection`,
    `ExclusiveReductionsSequence`, `InclusiveReductionsSequence`.
- The generic parameters of the `ExclusiveReductions` type have been swapped,
  putting the base collection first and the result type second.
- The `Indices` associated type of `IndexedCollection` now matches
  `Base.Indices`.

### Removals

- Previously deprecated type and method names have been removed:
  - The `Chain` type alias for `Chain2Sequence`
  - The `chained(with:)` method which was replaced with the `chain(_:_:)` free
    function
  - The `LazyChunked` and `Chunked` type aliases for `ChunkedByCollection`
  - The `rotate(subrange:at:)` and `rotate(at:)` methods which were renamed to 
    `rotate(subrange:toStartAt:)` and `rotate(toStartAt:)` respectively

### Fixes

- The `StridingSequence` and `StridingCollection` types now conditionally
  conform to `LazySequenceProtocol`, allowing the `striding(by:)` method to
  properly propagate laziness in a lazy sequence chain.
- Fixed `chunked(by:)` to always compare two consecutive elements rather than
  each element with the first element of the current chunk. ([#162])

The 1.0.0 release includes contributions from [iainsmith], [mdznr], and
[timvermeulen]. Thank you!

## [0.2.1] - 2021-06-01

### Additions

Expanded versatility for two existing operations:

- A series of `joined(by:)` overloads concatenate a sequence of sequences using
  an element or a collection, either passed in or generated from consecutive
  elements via a closure. ([#138])
- Additional `trimming(while:)` methods for trimming only the start or end of a
  collection, as well as mutating versions of all three variants. ([#104])

The 0.2.1 release includes contributions from [fedeci] and [timvermeulen]. 
Thank you!

## [0.2.0] - 2021-05-17

### Additions

Two new additions to the list of algorithms:

- `adjacentPairs()` lazily iterates over tuples of adjacent elements of a
  sequence. ([#119])
- `minAndMax()` finds both the smallest and largest elements of a sequence in 
  a single pass. ([#90])

### Changes

- When calling `chunked(on:)`, the resulting collection has an element type of
  `(Subject, SubSequence)` instead of just `SubSequence`, making the subject
  value available when iterating.

    ```swift
    let numbers = [5, 6, -3, -9, -11, 2, 7, 6]
    for (signum, values) in numbers.chunked(on: { $0.signum() }) {
        print(signum, values)
    }
    // 1 [5, 6]
    // -1 [-3, -9, -11]
    // 1 [2, 7, 6]
    ```

### Fixes

- Improvements to the documentation and PR templates.

The 0.2.0 release includes contributions from [CTMacUser], [LemonSpike],
[mpangburn], and [natecook1000]. Thank you!

---

## [0.1.1] - 2021-04-14

### Fixes

- `Product2` associated type inference error in release build ([#130])

## [0.1.0] - 2021-04-13

### Additions

- The `compacted()` method lazily finds the non-`nil` elements of a sequence or
  collection ([#112]).

### Changes

- The `uniqued()` method now lazily computes the unique elements of a sequence
  or a collection ([#71]). Pass this resulting sequence to an `Array`
  initializer to recover the behavior of the previous release.
- Calling `cycled(times:)` now returns a new `FiniteCycle` type, which has the
  same conformances as its underlying collection ([#106]). 
- The base collections of the sequence and collection wrapper types are no
  longer public ([#85], [#125]), and the wrapper types no longer conform to the
  `Equatable` or `Hashable` protocols ([#124]). If you need those conformances,
  convert the wrapper type to an `Array` or other collection currrency type
  before storing. Please file an issue if these changes pose a problem for your
  use case.

The 0.1.0 release includes contributions from [LemonSpike], [LucianoPAlmeida], 
[natecook1000], and [timvermeulen]. Thank you!

---

## [0.0.4] - 2021-03-29

### Additions

More new algorithms to join the party:

- A lazy version of the standard library's two `split` methods. ([#78])
- `firstNonNil(_:)` returns the first non-`nil` element from an
  optional-generating transform. ([#31])
- `uniquePermutations()` skips duplicates when generating permutations of a
  collection. ([#91])
- The `reductions` methods return all the in-between states of reducing a
  sequence or collection. ([#46])

### Fixes

- Methods and computed properties are more consistently marked as inlinable, 
  resolving a performance regression. 
- The `Stride` type now efficiently calculates distances between positions,
  supported by the underlying collection.
- Better test coverage and improved diagnostics for comparing sequences.
- Fixed links and improved documentation.

The 0.0.4 release includes contributions from [bjhomer], [danielctull],
[hashemi], [karwa], [kylemacomber], [LucianoPAlmeida], [mdznr], [natecook1000],
[ollieatkinson], [Qata], [timvermeulen], and [toddthomas]. Thank you!

## [0.0.3] - 2021-02-26

### Additions

An exciting group of new algorithms, contributed by the community:

- `trimming(while:)` returns a subsequence of a bidirectional collection with
  the matching elements removed from the start and end. ([#4])
- `min(ofCount:)` and `max(ofCount:)` find the smallest or largest elements in 
  a collection. ([#9], [#77])
- `windows(ofCount:)` lets you iterate over all the overlapping subsequences of
  a particular length. ([#20])
- `striding(by:)` iterates over every *n*th element of a sequence or collection.
  ([#24])
- `interspersed(with:)` places a new element between every pair of elements in
  a sequence or collection. ([#35])
- `chunks(ofCount:)` breaks a collection into subsequences of the given number
  of elements. ([#54])
- `suffix(while:)` matches the standard library's `prefix(while:)`, by 
  returning the suffix of all matching elements from a bidirectional collection.
  ([#65])
- Variations of `combinations(ofCount:)` and `permutations(ofCount:)` that take
  a range expression as a parameter, returning combinations and permutations of
  multiple lengths. ([#51], [#56])

### Changes

- The `LazyChunked` type now precomputes its `startIndex`, making performance
  more predictable when using the collection. 

### Fixes

- `randomSample(count:)` no longer traps in rare circumstances.
- Index calculations have been improved in a variety of collection wrappers.
- A variety of documentation improvements and corrections.

The 0.0.3 release includes contributions from [benrimmington], [danielctull],
[dhruvshah8], [karwa], [LucianoPAlmeida], [markuswntr], [mdznr], [michiboo],
[natecook1000], [ollieatkinson], [rakaramos], [rockbruno], [Roshankumar350],
[sidepelican], and [timvermeulen]. Thank you!

## [0.0.2] - 2020-10-23

### Changes

- The `rotate(at:)` method has been updated to `rotate(toStartAt:)`, with the
  old name deprecated.
- The `chained(with:)` method has been changed to the free function
  `chain(_:_:)`, with the old version deprecated.
- `Algorithms` now uses `RealModule` from the `swift-numerics` package for its
  cross-platform elementary functions.
- Sequence/collection wrapper types, like `Permutations` and `Indexed`, now
  have conformance to the lazy protocols, so that any following operations
  maintain their laziness.

### Fixes

- `Algorithms` now builds under SwiftPM on Windows.
- A wide variety of errors, misspellings, and ommissions in the documentation
  and guides have been fixed. 
- Index/distance calculations for the `Product2` and `Chain` types have been
  corrected.
- Calling `stablePartition(subrange:by:)` now correctly uses the subrange's
  length instead of the whole collection.

The 0.0.2 release includes contributions from [AustinConlon], [egorzhdan],
[IanKeen], [iSame7], [karwa], [kylemacomber], [natecook1000], [nordicio],
[pmtao], [schlagelk], [stephentyrone], and [timvermeulen]. Thank you!


## [0.0.1] - 2020-10-07

- **Swift Algorithms** initial release.

---

This changelog's format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

<!-- Link references for releases -->

[Unreleased]: https://github.com/apple/swift-algorithms/compare/1.0.0...HEAD
[1.0.0]: https://github.com/apple/swift-algorithms/compare/0.2.1...1.0.0
[0.2.1]: https://github.com/apple/swift-algorithms/compare/0.2.0...0.2.1
[0.2.0]: https://github.com/apple/swift-algorithms/compare/0.1.1...0.2.0
[0.1.1]: https://github.com/apple/swift-algorithms/compare/0.1.0...0.1.1
[0.1.0]: https://github.com/apple/swift-algorithms/compare/0.0.4...0.1.0
[0.0.4]: https://github.com/apple/swift-algorithms/compare/0.0.3...0.0.4
[0.0.3]: https://github.com/apple/swift-algorithms/compare/0.0.2...0.0.3
[0.0.2]: https://github.com/apple/swift-algorithms/compare/0.0.1...0.0.2
[0.0.1]: https://github.com/apple/swift-algorithms/releases/tag/0.0.1

<!-- Link references for pull requests -->

[#4]: https://github.com/apple/swift-algorithms/pull/4
[#9]: https://github.com/apple/swift-algorithms/pull/9
[#20]: https://github.com/apple/swift-algorithms/pull/20
[#24]: https://github.com/apple/swift-algorithms/pull/24
[#31]: https://github.com/apple/swift-algorithms/pull/31
[#35]: https://github.com/apple/swift-algorithms/pull/35
[#46]: https://github.com/apple/swift-algorithms/pull/46
[#51]: https://github.com/apple/swift-algorithms/pull/51
[#54]: https://github.com/apple/swift-algorithms/pull/54
[#56]: https://github.com/apple/swift-algorithms/pull/56
[#65]: https://github.com/apple/swift-algorithms/pull/65
[#71]: https://github.com/apple/swift-algorithms/pull/71
[#77]: https://github.com/apple/swift-algorithms/pull/77
[#78]: https://github.com/apple/swift-algorithms/pull/78
[#85]: https://github.com/apple/swift-algorithms/pull/85
[#90]: https://github.com/apple/swift-algorithms/pull/90
[#91]: https://github.com/apple/swift-algorithms/pull/91
[#104]: https://github.com/apple/swift-algorithms/pull/104
[#106]: https://github.com/apple/swift-algorithms/pull/106
[#112]: https://github.com/apple/swift-algorithms/pull/112
[#119]: https://github.com/apple/swift-algorithms/pull/119
[#124]: https://github.com/apple/swift-algorithms/pull/124
[#125]: https://github.com/apple/swift-algorithms/pull/125
[#130]: https://github.com/apple/swift-algorithms/pull/130
[#138]: https://github.com/apple/swift-algorithms/pull/138
[#162]: https://github.com/apple/swift-algorithms/pull/162

<!-- Link references for contributors -->

[AustinConlon]: https://github.com/apple/swift-algorithms/commits?author=AustinConlon
[benrimmington]: https://github.com/apple/swift-algorithms/commits?author=benrimmington
[bjhomer]: https://github.com/apple/swift-algorithms/commits?author=bjhomer
[CTMacUser]: https://github.com/apple/swift-algorithms/commits?author=CTMacUser
[danielctull]: https://github.com/apple/swift-algorithms/commits?author=danielctull
[dhruvshah8]: https://github.com/apple/swift-algorithms/commits?author=dhruvshah8
[egorzhdan]: https://github.com/apple/swift-algorithms/commits?author=egorzhdan
[fedeci]: https://github.com/apple/swift-algorithms/commits?author=fedeci
[hashemi]: https://github.com/apple/swift-algorithms/commits?author=hashemi
[IanKeen]: https://github.com/apple/swift-algorithms/commits?author=IanKeen
[iainsmith]: https://github.com/apple/swift-algorithms/commits?author=iainsmith
[iSame7]: https://github.com/apple/swift-algorithms/commits?author=iSame7
[karwa]: https://github.com/apple/swift-algorithms/commits?author=karwa
[kylemacomber]: https://github.com/apple/swift-algorithms/commits?author=kylemacomber
[LemonSpike]: https://github.com/apple/swift-algorithms/commits?author=LemonSpike
[LucianoPAlmeida]: https://github.com/apple/swift-algorithms/commits?author=LucianoPAlmeida
[markuswntr]: https://github.com/apple/swift-algorithms/commits?author=markuswntr
[mdznr]: https://github.com/apple/swift-algorithms/commits?author=mdznr
[michiboo]: https://github.com/apple/swift-algorithms/commits?author=michiboo
[mpangburn]: https://github.com/apple/swift-algorithms/commits?author=mpangburn
[natecook1000]: https://github.com/apple/swift-algorithms/commits?author=natecook1000
[nordicio]: https://github.com/apple/swift-algorithms/commits?author=nordicio
[ollieatkinson]: https://github.com/apple/swift-algorithms/commits?author=ollieatkinson
[pmtao]: https://github.com/apple/swift-algorithms/commits?author=pmtao
[Qata]: https://github.com/apple/swift-algorithms/commits?author=Qata
[rakaramos]: https://github.com/apple/swift-algorithms/commits?author=rakaramos
[rockbruno]: https://github.com/apple/swift-algorithms/commits?author=rockbruno
[Roshankumar350]: https://github.com/apple/swift-algorithms/commits?author=Roshankumar350
[schlagelk]: https://github.com/apple/swift-algorithms/commits?author=schlagelk
[sidepelican]: https://github.com/apple/swift-algorithms/commits?author=sidepelican
[stephentyrone]: https://github.com/apple/swift-algorithms/commits?author=stephentyrone
[timvermeulen]: https://github.com/apple/swift-algorithms/commits?author=timvermeulen
[toddthomas]: https://github.com/apple/swift-algorithms/commits?author=toddthomas
