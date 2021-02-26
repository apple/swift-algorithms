# CHANGELOG

<!-- 
Add new items at the end of the relevant section under **Unreleased**.
-->

This project follows semantic versioning. While still in major version `0`,
source-stability is only guaranteed within minor versions (e.g. between
`0.0.3` and `0.0.4`). If you want to guard against potentially source-breaking
package updates, you can specify your package dependency using
`.upToNextMinor(from: "0.0.1")` as the requirement.

## [Unreleased]

*No changes yet.*

---

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

[Unreleased]: https://github.com/apple/swift-algorithms/compare/0.0.3...HEAD
[0.0.3]: https://github.com/apple/swift-algorithms/compare/0.0.2...0.0.3
[0.0.2]: https://github.com/apple/swift-algorithms/compare/0.0.1...0.0.2
[0.0.1]: https://github.com/apple/swift-algorithms/releases/tag/0.0.1

<!-- Link references for pull requests -->

[#4]: https://github.com/apple/swift-algorithms/pull/4
[#9]: https://github.com/apple/swift-algorithms/pull/9
[#20]: https://github.com/apple/swift-algorithms/pull/20
[#24]: https://github.com/apple/swift-algorithms/pull/24
[#35]: https://github.com/apple/swift-algorithms/pull/35
[#51]: https://github.com/apple/swift-algorithms/pull/51
[#54]: https://github.com/apple/swift-algorithms/pull/54
[#56]: https://github.com/apple/swift-algorithms/pull/56
[#65]: https://github.com/apple/swift-algorithms/pull/65
[#77]: https://github.com/apple/swift-algorithms/pull/77

<!-- Link references for contributors -->

[AustinConlon]: https://github.com/apple/swift-algorithms/commits?author=AustinConlon
[benrimmington]: https://github.com/apple/swift-algorithms/commits?author=benrimmington
[danielctull]: https://github.com/apple/swift-algorithms/commits?author=danielctull
[dhruvshah8]: https://github.com/apple/swift-algorithms/commits?author=dhruvshah8
[egorzhdan]: https://github.com/apple/swift-algorithms/commits?author=egorzhdan
[IanKeen]: https://github.com/apple/swift-algorithms/commits?author=IanKeen
[iSame7]: https://github.com/apple/swift-algorithms/commits?author=iSame7
[karwa]: https://github.com/apple/swift-algorithms/commits?author=karwa
[kylemacomber]: https://github.com/apple/swift-algorithms/commits?author=kylemacomber
[LucianoPAlmeida]: https://github.com/apple/swift-algorithms/commits?author=LucianoPAlmeida
[markuswntr]: https://github.com/apple/swift-algorithms/commits?author=markuswntr
[mdznr]: https://github.com/apple/swift-algorithms/commits?author=mdznr
[michiboo]: https://github.com/apple/swift-algorithms/commits?author=michiboo
[natecook1000]: https://github.com/apple/swift-algorithms/commits?author=natecook1000
[nordicio]: https://github.com/apple/swift-algorithms/commits?author=nordicio
[ollieatkinson]: https://github.com/apple/swift-algorithms/commits?author=ollieatkinson
[pmtao]: https://github.com/apple/swift-algorithms/commits?author=pmtao
[rakaramos]: https://github.com/apple/swift-algorithms/commits?author=rakaramos
[rockbruno]: https://github.com/apple/swift-algorithms/commits?author=rockbruno
[Roshankumar350]: https://github.com/apple/swift-algorithms/commits?author=Roshankumar350
[schlagelk]: https://github.com/apple/swift-algorithms/commits?author=schlagelk
[sidepelican]: https://github.com/apple/swift-algorithms/commits?author=sidepelican
[stephentyrone]: https://github.com/apple/swift-algorithms/commits?author=stephentyrone
[timvermeulen]: https://github.com/apple/swift-algorithms/commits?author=timvermeulen
